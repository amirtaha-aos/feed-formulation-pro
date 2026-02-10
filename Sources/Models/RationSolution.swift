import Foundation
import SwiftUI
import AppKit
import UniformTypeIdentifiers

struct RationSolution {
    let status: SolutionStatus
    let message: String
    let optimizationMode: OptimizationMode
    let costPerKg: Double
    let objectivePerKg: Double
    let maxViolationPercent: Double
    let allocations: [RationAllocation]
    let assessments: [NutrientAssessment]

    static func empty(message: String) -> RationSolution {
        RationSolution(
            status: .approximation,
            message: message,
            optimizationMode: .leastCost,
            costPerKg: 0,
            objectivePerKg: 0,
            maxViolationPercent: 100,
            allocations: [],
            assessments: []
        )
    }
}
