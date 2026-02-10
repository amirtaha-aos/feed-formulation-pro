import Foundation
import SwiftUI
import AppKit
import UniformTypeIdentifiers

private struct SolverCandidate {
    let inclusions: [Double]
    let profile: [NutrientKey: Double]
    let cost: Double
    let penalty: Double
    let maxViolation: Double
    let objective: Double
}

enum RationSolver {
    static func solve(
        ingredients: [Ingredient],
        constraints: [NutrientConstraint],
        mode: OptimizationMode = .leastCost,
        profitWeight: Double = 0.16
    ) -> RationSolution {
        guard !ingredients.isEmpty else {
            return .empty(message: "No ingredients available for optimization.")
        }

        for constraint in constraints {
            if constraint.useMin, constraint.useMax, constraint.minValue > constraint.maxValue {
                return .empty(message: "One or more nutrient constraints have Min greater than Max.")
            }
        }

        let lowerBounds = ingredients.map { max(0.0, $0.minPercent / 100.0) }
        let upperBounds = ingredients.map { min(1.0, $0.maxPercent / 100.0) }
        let minTotal = lowerBounds.reduce(0, +)
        let maxTotal = upperBounds.reduce(0, +)

        if lowerBounds.indices.contains(where: { lowerBounds[$0] > upperBounds[$0] }) {
            return .empty(message: "One or more ingredients have invalid min/max inclusion limits.")
        }

        if minTotal > 1.00001 {
            return .empty(message: "Ingredient minimum inclusions exceed 100%.")
        }

        if maxTotal < 0.99999 {
            return .empty(message: "Ingredient maximum inclusions are below 100%.")
        }

        let costs = ingredients.map(\.pricePerKg)
        let objectiveCoefficients = ingredients.map { ingredient in
            switch mode {
            case .leastCost:
                return ingredient.pricePerKg
            case .profitMax:
                return ingredient.pricePerKg - (profitWeight * profitPotential(of: ingredient))
            }
        }
        let penaltyWeight = 95.0
        let restartCount = 12
        let maxIterations = 1200
        var bestFeasible: SolverCandidate?
        var bestApprox: SolverCandidate?

        for restart in 0..<restartCount {
            var inclusions = initialGuess(
                restart: restart,
                lowerBounds: lowerBounds,
                upperBounds: upperBounds
            )

            for iteration in 0..<maxIterations {
                let profile = profileFor(inclusions: inclusions, ingredients: ingredients)
                let evaluation = evaluate(profile: profile, constraints: constraints)
                let cost = dot(inclusions, costs)
                let objective = dot(inclusions, objectiveCoefficients) + penaltyWeight * evaluation.penalty

                let candidate = SolverCandidate(
                    inclusions: inclusions,
                    profile: profile,
                    cost: cost,
                    penalty: evaluation.penalty,
                    maxViolation: evaluation.maxViolation,
                    objective: objective
                )

                if evaluation.maxViolation <= 0.0012 {
                    if bestFeasible == nil || candidate.cost < bestFeasible!.cost {
                        bestFeasible = candidate
                    }
                } else if
                    bestApprox == nil
                        || candidate.penalty < bestApprox!.penalty
                        || (
                            abs(candidate.penalty - bestApprox!.penalty) < 1e-9
                                && candidate.objective < bestApprox!.objective
                        )
                {
                    bestApprox = candidate
                }

                var gradient = objectiveCoefficients
                for constraint in constraints where constraint.isActive {
                    let key = constraint.key
                    let achieved = profile[key] ?? 0
                    let nutrientValues = ingredients.map { $0.value(for: key) }

                    if constraint.useMin {
                        let scale = max(abs(constraint.minValue), 1.0)
                        let deficit = max(0, (constraint.minValue - achieved) / scale)
                        if deficit > 0 {
                            let factor = -2.0 * penaltyWeight * deficit / scale
                            for index in gradient.indices {
                                gradient[index] += factor * nutrientValues[index]
                            }
                        }
                    }

                    if constraint.useMax {
                        let scale = max(abs(constraint.maxValue), 1.0)
                        let excess = max(0, (achieved - constraint.maxValue) / scale)
                        if excess > 0 {
                            let factor = 2.0 * penaltyWeight * excess / scale
                            for index in gradient.indices {
                                gradient[index] += factor * nutrientValues[index]
                            }
                        }
                    }
                }

                let step = max(0.009, 0.12 * pow(0.998, Double(iteration)))
                let next = inclusions.indices.map { inclusions[$0] - step * gradient[$0] }
                inclusions = projectToBoundedSimplex(
                    next,
                    lowerBounds: lowerBounds,
                    upperBounds: upperBounds,
                    targetSum: 1.0
                )

                if evaluation.maxViolation < 0.0001, iteration > 260 {
                    break
                }
            }
        }

        guard let best = bestFeasible ?? bestApprox else {
            return .empty(message: "Optimization failed. Please review constraints and ingredient data.")
        }

        let assessments = constraints.map { constraint in
            NutrientAssessment(
                key: constraint.key,
                achieved: best.profile[constraint.key] ?? 0,
                minTarget: constraint.useMin ? constraint.minValue : nil,
                maxTarget: constraint.useMax ? constraint.maxValue : nil
            )
        }

        let allocations = ingredients.enumerated().map { index, ingredient in
            let share = best.inclusions[index]
            return RationAllocation(
                id: ingredient.id,
                name: ingredient.name,
                group: ingredient.group,
                inclusionPercent: share * 100.0,
                costContributionPerKg: share * ingredient.pricePerKg
            )
        }

        if bestFeasible != nil {
            return RationSolution(
                status: .feasible,
                message: mode == .leastCost
                    ? "Feasible least-cost formula found. All enabled constraints are satisfied."
                    : "Feasible profit-oriented formula found. All enabled constraints are satisfied.",
                optimizationMode: mode,
                costPerKg: best.cost,
                objectivePerKg: dot(best.inclusions, objectiveCoefficients),
                maxViolationPercent: 0,
                allocations: allocations,
                assessments: assessments
            )
        }

        return RationSolution(
            status: .approximation,
            message: "No fully feasible solution under current limits. Showing best approximation.",
            optimizationMode: mode,
            costPerKg: best.cost,
            objectivePerKg: dot(best.inclusions, objectiveCoefficients),
            maxViolationPercent: best.maxViolation * 100.0,
            allocations: allocations,
            assessments: assessments
        )
    }

    private static func profitPotential(of ingredient: Ingredient) -> Double {
        // Heuristic nutrient value proxy to support profit-oriented optimization.
        let energyScore = ingredient.metabolizableEnergy / 1000.0
        let proteinScore = ingredient.crudeProtein * 0.35
        let aminoScore =
            ingredient.lysine * 2.8
            + ingredient.methionine * 3.3
            + ingredient.threonine * 1.9
        let microScore =
            min(ingredient.vitaminA / 1_000_000.0, 2.0)
            + min(ingredient.vitaminD3 / 400_000.0, 2.0)
            + min(ingredient.vitaminE / 10_000.0, 2.0)
        return max(0, energyScore + proteinScore + aminoScore + microScore)
    }

    private static func evaluate(
        profile: [NutrientKey: Double],
        constraints: [NutrientConstraint]
    ) -> (penalty: Double, maxViolation: Double) {
        var penalty = 0.0
        var maxViolation = 0.0

        for constraint in constraints where constraint.isActive {
            let achieved = profile[constraint.key] ?? 0

            if constraint.useMin {
                let scale = max(abs(constraint.minValue), 1.0)
                let deficit = max(0, (constraint.minValue - achieved) / scale)
                penalty += deficit * deficit
                maxViolation = max(maxViolation, deficit)
            }

            if constraint.useMax {
                let scale = max(abs(constraint.maxValue), 1.0)
                let excess = max(0, (achieved - constraint.maxValue) / scale)
                penalty += excess * excess
                maxViolation = max(maxViolation, excess)
            }
        }

        return (penalty, maxViolation)
    }

    private static func initialGuess(
        restart: Int,
        lowerBounds: [Double],
        upperBounds: [Double]
    ) -> [Double] {
        let guess: [Double]
        if restart == 0 {
            guess = lowerBounds.indices.map { (lowerBounds[$0] + upperBounds[$0]) / 2.0 }
        } else {
            guess = lowerBounds.indices.map { Double.random(in: lowerBounds[$0]...upperBounds[$0]) }
        }

        return projectToBoundedSimplex(
            guess,
            lowerBounds: lowerBounds,
            upperBounds: upperBounds,
            targetSum: 1.0
        )
    }

    private static func profileFor(
        inclusions: [Double],
        ingredients: [Ingredient]
    ) -> [NutrientKey: Double] {
        var profile = Dictionary(uniqueKeysWithValues: NutrientKey.allCases.map { ($0, 0.0) })

        for (index, inclusion) in inclusions.enumerated() {
            let ingredient = ingredients[index]
            for key in NutrientKey.allCases {
                profile[key, default: 0] += inclusion * ingredient.value(for: key)
            }
        }

        return profile
    }

    private static func projectToBoundedSimplex(
        _ values: [Double],
        lowerBounds: [Double],
        upperBounds: [Double],
        targetSum: Double
    ) -> [Double] {
        let minSum = lowerBounds.reduce(0, +)
        let maxSum = upperBounds.reduce(0, +)

        guard minSum <= targetSum + 1e-9, maxSum >= targetSum - 1e-9 else {
            return values.enumerated().map { index, value in
                clamp(value, lowerBounds[index], upperBounds[index])
            }
        }

        var low = zip(values, upperBounds).map { $0 - $1 }.min() ?? -1.0
        var high = zip(values, lowerBounds).map { $0 - $1 }.max() ?? 1.0

        for _ in 0..<90 {
            let mid = (low + high) / 2.0
            let sum = values.enumerated().reduce(0.0) { partial, pair in
                partial + clamp(pair.element - mid, lowerBounds[pair.offset], upperBounds[pair.offset])
            }

            if sum > targetSum {
                low = mid
            } else {
                high = mid
            }
        }

        let threshold = (low + high) / 2.0
        var projected = values.enumerated().map { index, value in
            clamp(value - threshold, lowerBounds[index], upperBounds[index])
        }

        var difference = targetSum - projected.reduce(0, +)
        if abs(difference) > 1e-10 {
            for _ in 0..<(projected.count * 2) {
                if abs(difference) <= 1e-10 { break }
                let adjustable = projected.indices.filter { index in
                    difference > 0
                        ? projected[index] < upperBounds[index] - 1e-12
                        : projected[index] > lowerBounds[index] + 1e-12
                }

                if adjustable.isEmpty { break }

                let share = difference / Double(adjustable.count)
                var moved = 0.0
                for index in adjustable {
                    let current = projected[index]
                    projected[index] = clamp(current + share, lowerBounds[index], upperBounds[index])
                    moved += projected[index] - current
                }
                difference -= moved
            }
        }

        return projected
    }

    private static func dot(_ lhs: [Double], _ rhs: [Double]) -> Double {
        zip(lhs, rhs).reduce(0.0) { $0 + ($1.0 * $1.1) }
    }

    private static func clamp(_ value: Double, _ minValue: Double, _ maxValue: Double) -> Double {
        min(max(value, minValue), maxValue)
    }
}
