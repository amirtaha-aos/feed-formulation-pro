import Foundation

enum FeedingGoal: String, CaseIterable, Identifiable, Codable {
    case starter = "Starter"
    case grower = "Grower"
    case finisher = "Finisher"
    case maintenance = "Maintenance"

    var id: String { rawValue }
}
