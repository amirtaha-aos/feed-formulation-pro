import Foundation

enum BirdType: String, CaseIterable, Identifiable, Codable {
    case broiler = "Broiler Chicken"
    case layer = "Layer Hen"
    case rooster = "Rooster"

    var id: String { rawValue }
}
