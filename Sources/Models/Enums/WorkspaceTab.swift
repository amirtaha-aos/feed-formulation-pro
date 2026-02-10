import Foundation

enum WorkspaceTab: String, CaseIterable, Identifiable, Codable {
    case formula = "Formula"
    case nutrientsAndIngredients = "Nutrients & Ingredients"
    case operations = "Operations"

    var id: String { rawValue }
}
