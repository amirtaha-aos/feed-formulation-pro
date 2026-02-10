import Foundation
import SwiftUI
import AppKit
import UniformTypeIdentifiers

struct NutrientAssessment: Identifiable {
    let id = UUID()
    let key: NutrientKey
    let achieved: Double
    let minTarget: Double?
    let maxTarget: Double?

    var meetsMin: Bool {
        guard let minTarget else { return true }
        return achieved + 1e-6 >= minTarget
    }

    var meetsMax: Bool {
        guard let maxTarget else { return true }
        return achieved - 1e-6 <= maxTarget
    }

    var isGood: Bool {
        meetsMin && meetsMax
    }
}
