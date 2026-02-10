import Foundation
import SwiftUI
import AppKit
import UniformTypeIdentifiers

struct RationAllocation: Identifiable {
    let id: UUID
    let name: String
    let group: IngredientGroup
    let inclusionPercent: Double
    let costContributionPerKg: Double
}
