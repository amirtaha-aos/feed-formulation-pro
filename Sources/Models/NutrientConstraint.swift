import Foundation
import SwiftUI
import AppKit
import UniformTypeIdentifiers

struct NutrientConstraint: Identifiable, Hashable, Codable {
    let key: NutrientKey
    var useMin: Bool
    var minValue: Double
    var useMax: Bool
    var maxValue: Double

    var id: String { key.id }

    var isActive: Bool {
        useMin || useMax
    }

    static func preset(for bird: BirdType, goal: FeedingGoal) -> [NutrientConstraint] {
        let minTargets: [NutrientKey: Double]
        let maxTargets: [NutrientKey: Double]

        switch (bird, goal) {
        case (.broiler, .starter):
            minTargets = [
                .crudeProtein: 22.0,
                .metabolizableEnergy: 3200,
                .lysine: 1.10,
                .methionine: 0.50,
                .threonine: 0.80,
                .calcium: 1.00,
                .availablePhosphorus: 0.45,
                .sodium: 0.20,
                .linoleicAcid: 1.00
            ]
            maxTargets = [
                .calcium: 1.20,
                .sodium: 0.25
            ]
        case (.broiler, .grower):
            minTargets = [
                .crudeProtein: 20.0,
                .metabolizableEnergy: 3200,
                .lysine: 1.00,
                .methionine: 0.38,
                .threonine: 0.74,
                .calcium: 0.90,
                .availablePhosphorus: 0.35,
                .sodium: 0.18,
                .linoleicAcid: 1.00
            ]
            maxTargets = [
                .calcium: 1.10,
                .sodium: 0.24
            ]
        case (.broiler, .finisher):
            minTargets = [
                .crudeProtein: 18.0,
                .metabolizableEnergy: 3200,
                .lysine: 0.88,
                .methionine: 0.32,
                .threonine: 0.68,
                .calcium: 0.80,
                .availablePhosphorus: 0.30,
                .sodium: 0.18,
                .linoleicAcid: 1.00
            ]
            maxTargets = [
                .calcium: 1.00,
                .sodium: 0.24
            ]
        case (.layer, _):
            minTargets = [
                .crudeProtein: 16.0,
                .metabolizableEnergy: 2800,
                .lysine: 0.77,
                .methionine: 0.32,
                .threonine: 0.59,
                .calcium: 3.60,
                .availablePhosphorus: 0.35,
                .sodium: 0.16,
                .linoleicAcid: 1.00
            ]
            maxTargets = [
                .calcium: 4.20,
                .sodium: 0.22
            ]
        default:
            minTargets = [
                .crudeProtein: 14.0,
                .metabolizableEnergy: 2700,
                .lysine: 0.60,
                .methionine: 0.25,
                .threonine: 0.50,
                .calcium: 1.20,
                .availablePhosphorus: 0.30,
                .sodium: 0.15,
                .linoleicAcid: 0.80
            ]
            maxTargets = [
                .calcium: 1.60,
                .sodium: 0.21
            ]
        }

        return NutrientKey.allCases.map { key in
            NutrientConstraint(
                key: key,
                useMin: minTargets[key] != nil,
                minValue: minTargets[key] ?? 0,
                useMax: maxTargets[key] != nil,
                maxValue: maxTargets[key] ?? 0
            )
        }
    }

    static func presetFromDayRange(
        for bird: BirdType,
        goal: FeedingGoal,
        dayFrom: Int,
        dayTo: Int
    ) -> [NutrientConstraint] {
        switch bird {
        case .broiler:
            let day = max(1.0, min(42.0, Double(dayFrom + dayTo) / 2.0))
            return broilerWorkbookPreset(day: day)
        case .layer:
            return layerWorkbookPreset(goal: goal)
        case .rooster:
            return roosterWorkbookPreset(goal: goal)
        }
    }

    private struct WorkbookRequirement {
        let metabolizableEnergy: Double
        let crudeProtein: Double
        let lysine: Double
        let methioninePlusCystine: Double
        let threonine: Double
        let calcium: Double
        let availablePhosphorus: Double
        let sodium: Double
        let linoleicAcid: Double
    }

    private static func buildConstraints(
        from target: WorkbookRequirement,
        sodiumMax: Double
    ) -> [NutrientConstraint] {
        let methionineFromMetCys = target.methioninePlusCystine * 0.55
        let minTargets: [NutrientKey: Double] = [
            .crudeProtein: target.crudeProtein,
            .metabolizableEnergy: target.metabolizableEnergy,
            .lysine: target.lysine,
            .methionine: methionineFromMetCys,
            .threonine: target.threonine,
            .calcium: target.calcium,
            .availablePhosphorus: target.availablePhosphorus,
            .sodium: target.sodium,
            .linoleicAcid: target.linoleicAcid
        ]
        let maxTargets: [NutrientKey: Double] = [
            .calcium: max(target.calcium + 0.20, target.calcium * 1.1),
            .sodium: sodiumMax
        ]

        return NutrientKey.allCases.map { key in
            NutrientConstraint(
                key: key,
                useMin: minTargets[key] != nil,
                minValue: minTargets[key] ?? 0,
                useMax: maxTargets[key] != nil,
                maxValue: maxTargets[key] ?? 0
            )
        }
    }

    private static func broilerWorkbookPreset(day: Double) -> [NutrientConstraint] {
        // Broiler equations imported from workbook "Dynamic Model" (X5, X7, X8, X9, X14, X15).
        let lysine =
            0.0000000003674287 * pow(day, 6)
            - 0.00000006227310833 * pow(day, 5)
            + 0.00000412854698776 * pow(day, 4)
            - 0.00014031019021032 * pow(day, 3)
            + 0.0028103429548989 * pow(day, 2)
            - 0.0435462829680875 * day
            + 1.43827279762856
        let metabolizableEnergy =
            (
                -0.0036963 * pow(day, 3)
                + 0.1605779 * pow(day, 2)
                + 5.9348078 * day
                + 2966.7735466
            ) * 0.95
        let calcium =
            0.000107037617168617 * pow(day, 2)
            - 0.0121508210423812 * day
            + 1.01373450997689
        let requirement = WorkbookRequirement(
            metabolizableEnergy: max(2750, metabolizableEnergy),
            crudeProtein: max(17.0, min(23.0, lysine * 18.0)),
            lysine: max(0.85, lysine),
            methioninePlusCystine: max(0.62, lysine * 0.74),
            threonine: max(0.56, lysine * 0.66),
            calcium: max(0.72, calcium),
            availablePhosphorus: max(0.34, calcium / 2.0),
            sodium: 0.16,
            linoleicAcid: 1.00
        )
        return buildConstraints(from: requirement, sodiumMax: 0.24)
    }

    private static func layerWorkbookPreset(goal: FeedingGoal) -> [NutrientConstraint] {
        // Imported from layer workbook sheets: Starter, Grower, PreLayer, Hy-Line W80.
        let requirement: WorkbookRequirement
        switch goal {
        case .starter:
            requirement = WorkbookRequirement(
                metabolizableEnergy: 2860,
                crudeProtein: 19.0,
                lysine: 1.00,
                methioninePlusCystine: 0.75,
                threonine: 0.66,
                calcium: 1.05,
                availablePhosphorus: 0.48,
                sodium: 0.16,
                linoleicAcid: 1.00
            )
        case .grower:
            requirement = WorkbookRequirement(
                metabolizableEnergy: 2750,
                crudeProtein: 17.5,
                lysine: 0.86,
                methioninePlusCystine: 0.688,
                threonine: 0.602,
                calcium: 1.00,
                availablePhosphorus: 0.45,
                sodium: 0.16,
                linoleicAcid: 1.00
            )
        case .finisher:
            requirement = WorkbookRequirement(
                metabolizableEnergy: 2700,
                crudeProtein: 17.5,
                lysine: 0.70,
                methioninePlusCystine: 0.63,
                threonine: 0.49,
                calcium: 2.00,
                availablePhosphorus: 0.40,
                sodium: 0.16,
                linoleicAcid: 1.00
            )
        case .maintenance:
            requirement = WorkbookRequirement(
                metabolizableEnergy: 2960.08,
                crudeProtein: 17.6,
                lysine: 0.82,
                methioninePlusCystine: 0.7462,
                threonine: 0.574,
                calcium: 4.00,
                availablePhosphorus: 0.447,
                sodium: 0.18,
                linoleicAcid: 1.00
            )
        }
        return buildConstraints(from: requirement, sodiumMax: 0.22)
    }

    private static func roosterWorkbookPreset(goal: FeedingGoal) -> [NutrientConstraint] {
        // Imported from breeder workbook sheets: Starter1, Grower, Breeder1, Rooster.
        let requirement: WorkbookRequirement
        switch goal {
        case .starter:
            requirement = WorkbookRequirement(
                metabolizableEnergy: 2800,
                crudeProtein: 19.0,
                lysine: 0.95,
                methioninePlusCystine: 0.74005,
                threonine: 0.66025,
                calcium: 1.00,
                availablePhosphorus: 0.45,
                sodium: 0.16,
                linoleicAcid: 0.90
            )
        case .grower:
            requirement = WorkbookRequirement(
                metabolizableEnergy: 2800,
                crudeProtein: 14.0,
                lysine: 0.52,
                methioninePlusCystine: 0.52,
                threonine: 0.43992,
                calcium: 0.90,
                availablePhosphorus: 0.42,
                sodium: 0.16,
                linoleicAcid: 0.90
            )
        case .finisher:
            requirement = WorkbookRequirement(
                metabolizableEnergy: 2750,
                crudeProtein: 15.0,
                lysine: 0.62,
                methioninePlusCystine: 0.60946,
                threonine: 0.50654,
                calcium: 3.00,
                availablePhosphorus: 0.35,
                sodium: 0.16,
                linoleicAcid: 0.90
            )
        case .maintenance:
            requirement = WorkbookRequirement(
                metabolizableEnergy: 2700,
                crudeProtein: 11.5,
                lysine: 0.44,
                methioninePlusCystine: 0.4202,
                threonine: 0.33,
                calcium: 0.70,
                availablePhosphorus: 0.35,
                sodium: 0.16,
                linoleicAcid: 0.80
            )
        }
        return buildConstraints(from: requirement, sodiumMax: 0.20)
    }

    private static func interpolate(day: Double, anchors: [(Double, Double)]) -> Double {
        guard let first = anchors.first, let last = anchors.last else { return 0 }
        if day <= first.0 { return first.1 }
        if day >= last.0 { return last.1 }

        for index in 0..<(anchors.count - 1) {
            let a = anchors[index]
            let b = anchors[index + 1]
            if day >= a.0, day <= b.0 {
                let span = max(b.0 - a.0, 1e-9)
                let t = (day - a.0) / span
                return a.1 + ((b.1 - a.1) * t)
            }
        }
        return last.1
    }

    static func micronutrientMinimums() -> [NutrientKey: Double] {
        [
            .vitaminA: 3300,
            .vitaminD3: 660,
            .vitaminE: 11,
            .manganese: 26,
            .zinc: 22,
            .copper: 4,
            .iron: 40,
            .selenium: 0.10
        ]
    }
}
