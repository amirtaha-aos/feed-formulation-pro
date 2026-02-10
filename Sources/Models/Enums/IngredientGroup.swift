import Foundation

enum IngredientGroup: String, CaseIterable, Identifiable, Codable {
    case grain = "Grain"
    case protein = "Protein Sources"
    case plantByProducts = "Plant By-Products"
    case animalSource = "Animal Source"
    case fat = "Fats & Oils"
    case mineral = "Minerals"
    case supplementsAdditives = "Supp & Additives"
    case userFeed = "User Feed"

    var id: String { rawValue }
}
