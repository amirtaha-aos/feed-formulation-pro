import Foundation
import SwiftUI
import AppKit
import UniformTypeIdentifiers

struct MRPOrderLine: Identifiable {
    let id: UUID
    let ingredientName: String
    let group: IngredientGroup
    let dailyUsageKg: Double
    let leadDemandKg: Double
    let safetyKg: Double
    let onHandKg: Double
    let reorderKg: Double
    let daysCover: Double
}
