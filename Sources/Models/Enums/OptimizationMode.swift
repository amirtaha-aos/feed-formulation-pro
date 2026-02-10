import Foundation

enum OptimizationMode: String, CaseIterable, Identifiable, Codable {
    case leastCost = "Least Cost"
    case profitMax = "Profit Max"

    var id: String { rawValue }
}
