import Foundation

enum NutrientKey: String, CaseIterable, Identifiable, Codable {
    case crudeProtein
    case metabolizableEnergy
    case lysine
    case methionine
    case threonine
    case calcium
    case availablePhosphorus
    case sodium
    case linoleicAcid
    case vitaminA
    case vitaminD3
    case vitaminE
    case manganese
    case zinc
    case copper
    case iron
    case selenium

    var id: String { rawValue }

    var title: String {
        switch self {
        case .crudeProtein: return "Crude Protein"
        case .metabolizableEnergy: return "Metabolizable Energy"
        case .lysine: return "Lysine"
        case .methionine: return "Methionine"
        case .threonine: return "Threonine"
        case .calcium: return "Calcium"
        case .availablePhosphorus: return "Available Phosphorus"
        case .sodium: return "Sodium"
        case .linoleicAcid: return "Linoleic Acid"
        case .vitaminA: return "Vitamin A"
        case .vitaminD3: return "Vitamin D3"
        case .vitaminE: return "Vitamin E"
        case .manganese: return "Manganese"
        case .zinc: return "Zinc"
        case .copper: return "Copper"
        case .iron: return "Iron"
        case .selenium: return "Selenium"
        }
    }

    var short: String {
        switch self {
        case .crudeProtein: return "CP"
        case .metabolizableEnergy: return "ME"
        case .lysine: return "Lys"
        case .methionine: return "Met"
        case .threonine: return "Thr"
        case .calcium: return "Ca"
        case .availablePhosphorus: return "AvP"
        case .sodium: return "Na"
        case .linoleicAcid: return "LinA"
        case .vitaminA: return "VitA"
        case .vitaminD3: return "VitD3"
        case .vitaminE: return "VitE"
        case .manganese: return "Mn"
        case .zinc: return "Zn"
        case .copper: return "Cu"
        case .iron: return "Fe"
        case .selenium: return "Se"
        }
    }

    var unit: String {
        switch self {
        case .metabolizableEnergy: return "kcal/kg"
        case .vitaminA, .vitaminD3, .vitaminE: return "IU/kg"
        case .manganese, .zinc, .copper, .iron, .selenium: return "mg/kg"
        default: return "%"
        }
    }

    var group: NutrientGroup {
        switch self {
        case .crudeProtein, .metabolizableEnergy, .calcium, .availablePhosphorus, .sodium, .linoleicAcid:
            return .macro
        case .lysine, .methionine, .threonine:
            return .amino
        case .vitaminA, .vitaminD3, .vitaminE:
            return .vitamin
        case .manganese, .zinc, .copper, .iron, .selenium:
            return .mineral
        }
    }

    var decimals: Int {
        switch self {
        case .metabolizableEnergy:
            return 0
        case .vitaminA, .vitaminD3, .vitaminE, .manganese, .zinc, .copper, .iron, .selenium:
            return 0
        default:
            return 2
        }
    }
}
