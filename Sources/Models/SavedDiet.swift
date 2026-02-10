import Foundation
import SwiftUI
import AppKit
import UniformTypeIdentifiers

struct SavedDiet: Identifiable, Codable {
    let id: UUID
    var name: String
    var birdType: BirdType
    var feedingGoal: FeedingGoal
    var ageInWeeks: Int
    var flockSize: Int
    var dailyFeedPerBirdKg: Double
    var batchSizeKg: Double
    var constraints: [NutrientConstraint]
    var ingredients: [Ingredient]
    var enabledGroups: [IngredientGroup]
}
