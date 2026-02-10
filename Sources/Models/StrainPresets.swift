import Foundation

/// Strain-specific nutrient requirement presets
/// Based on Excel files: Dynamic Model, Ross, Cobb, Aviagen, Lohmann, etc.
struct StrainPresets {

    /// Available broiler strains
    enum BroilerStrain: String, CaseIterable, Identifiable {
        case dynamic = "Dynamic Model (Polynomial)"
        case ross = "Ross & Aviagen"
        case cobb = "Cobb"
        case aminoChick = "Amino Chick"

        var id: String { rawValue }
    }

    /// Available layer strains
    enum LayerStrain: String, CaseIterable, Identifiable {
        case lsl = "Lohmann LSL"
        case superNick = "Super Nick"
        case shaverBovans = "Shaver & Bovans"
        case hyLineW80 = "Hy-Line W80"

        var id: String { rawValue }
    }

    /// Growth phases for broilers
    enum BroilerPhase: String, CaseIterable, Identifiable {
        case starter = "Starter (0-10 days)"
        case grower = "Grower (11-24 days)"
        case finisher1 = "Finisher 1 (25-39 days)"
        case finisher2 = "Finisher 2 (40+ days)"

        var id: String { rawValue }

        var dayRange: ClosedRange<Int> {
            switch self {
            case .starter: return 0...10
            case .grower: return 11...24
            case .finisher1: return 25...39
            case .finisher2: return 40...60
            }
        }
    }

    /// Get broiler requirements based on strain and age
    static func getBroilerRequirements(strain: BroilerStrain, ageInDays: Int) -> NutrientRequirements {
        switch strain {
        case .dynamic:
            return calculateDynamicModelRequirements(ageInDays: ageInDays)
        case .ross:
            return getRossRequirements(ageInDays: ageInDays)
        case .cobb:
            return getCobbRequirements(ageInDays: ageInDays)
        case .aminoChick:
            return getAminoChickRequirements(ageInDays: ageInDays)
        }
    }

    /// Dynamic Model - Polynomial-based requirements from Excel
    private static func calculateDynamicModelRequirements(ageInDays: Int) -> NutrientRequirements {
        let age = Double(ageInDays)

        // Energy (ME) - 3rd degree polynomial with 0.95 safety factor
        let me = (-0.0036963 * pow(age, 3) +
                  0.1605779 * pow(age, 2) +
                  5.9348078 * age +
                  2966.7735466) * 0.95

        // Lysine (SID) - 6th degree polynomial
        let lysine = (0.0000000003674287 * pow(age, 6) -
                      0.00000006227310833 * pow(age, 5) +
                      0.00000412854698776 * pow(age, 4) -
                      0.00014031019021032 * pow(age, 3) +
                      0.0028103429548989 * pow(age, 2) -
                      0.0435462829680875 * age +
                      1.43827279762856)

        // Other amino acids as ratios of lysine
        let metCys = lysine * 0.74
        let methionine = metCys * 0.46 // Approximate met from met+cys
        let threonine = lysine * 0.66
        let tryptophan = lysine * 0.18
        let arginine = lysine * 1.07
        let isoleucine = lysine * 0.68
        let leucine = lysine * 1.20 // Estimated ratio
        let valine = lysine * 0.77

        // Crude protein estimation (based on amino acid profile)
        let crudeProtein = lysine / 0.062 // Approximate CP from lysine

        // Calcium - polynomial
        let calcium = (0.0000001226543 * pow(age, 4) -
                      0.0000125 * pow(age, 3) +
                      0.0004583 * pow(age, 2) -
                      0.0141667 * age +
                      1.125)

        // Available phosphorus - half of calcium
        let availablePhosphorus = calcium / 2.0

        // Fixed minerals
        let sodium = 0.16
        let potassium = 0.70
        let chloride = 0.23

        // Choline - polynomial
        let choline = (-0.0000003968 * pow(age, 4) +
                      0.00004 * pow(age, 3) -
                      0.0015 * pow(age, 2) +
                      0.0004 * age +
                      1.7)

        return NutrientRequirements(
            metabolizableEnergy: me,
            crudeProtein: crudeProtein,
            sidLysine: lysine,
            sidMethionine: methionine,
            sidMetCys: metCys,
            sidThreonine: threonine,
            sidTryptophan: tryptophan,
            sidArginine: arginine,
            sidIsoleucine: isoleucine,
            sidLeucine: leucine,
            sidValine: valine,
            calcium: calcium,
            availablePhosphorus: availablePhosphorus,
            sodium: sodium,
            potassium: potassium,
            chloride: chloride,
            choline: choline
        )
    }

    /// Ross & Aviagen requirements from Excel
    private static func getRossRequirements(ageInDays: Int) -> NutrientRequirements {
        let phase: BroilerPhase
        if ageInDays <= 10 {
            phase = .starter
        } else if ageInDays <= 24 {
            phase = .grower
        } else if ageInDays <= 39 {
            phase = .finisher1
        } else {
            phase = .finisher2
        }

        switch phase {
        case .starter:
            return NutrientRequirements(
                metabolizableEnergy: 2975,
                crudeProtein: 23.0,
                sidLysine: 1.320,
                sidMethionine: 0.528,  // Lys × 0.40
                sidMetCys: 1.003,      // Lys × 0.76
                sidThreonine: 0.880,   // Lys × 0.667
                sidTryptophan: 0.211,  // Lys × 0.16
                sidArginine: 1.449,    // Lys × 1.098
                sidIsoleucine: 0.898,  // Lys × 0.68
                sidLeucine: 1.584,     // Estimated
                sidValine: 1.016,      // Lys × 0.77
                calcium: 0.96,
                availablePhosphorus: 0.48,
                sodium: 0.16,
                potassium: 0.85,
                chloride: 0.23,
                choline: 1.70
            )

        case .grower:
            return NutrientRequirements(
                metabolizableEnergy: 3050,
                crudeProtein: 21.5,
                sidLysine: 1.180,
                sidMethionine: 0.483,  // Lys × 0.409
                sidMetCys: 0.913,      // Lys × 0.774
                sidThreonine: 0.787,   // Lys × 0.667
                sidTryptophan: 0.190,  // Lys × 0.161
                sidArginine: 1.289,    // Lys × 1.092
                sidIsoleucine: 0.803,  // Lys × 0.68
                sidLeucine: 1.416,     // Estimated
                sidValine: 0.909,      // Lys × 0.77
                calcium: 0.87,
                availablePhosphorus: 0.44,
                sodium: 0.16,
                potassium: 0.77,
                chloride: 0.23,
                choline: 1.60
            )

        case .finisher1:
            return NutrientRequirements(
                metabolizableEnergy: 3100,
                crudeProtein: 19.5,
                sidLysine: 1.080,
                sidMethionine: 0.450,  // Lys × 0.417
                sidMetCys: 0.868,      // Lys × 0.804
                sidThreonine: 0.720,   // Lys × 0.667
                sidTryptophan: 0.169,  // Lys × 0.157
                sidArginine: 1.146,    // Lys × 1.061
                sidIsoleucine: 0.734,  // Lys × 0.68
                sidLeucine: 1.296,     // Estimated
                sidValine: 0.832,      // Lys × 0.77
                calcium: 0.78,
                availablePhosphorus: 0.39,
                sodium: 0.16,
                potassium: 0.68,
                chloride: 0.23,
                choline: 1.50
            )

        case .finisher2:
            return NutrientRequirements(
                metabolizableEnergy: 3125,
                crudeProtein: 18.0,
                sidLysine: 1.020,
                sidMethionine: 0.429,  // Lys × 0.421
                sidMetCys: 0.820,      // Lys × 0.804
                sidThreonine: 0.680,   // Lys × 0.667
                sidTryptophan: 0.160,  // Lys × 0.157
                sidArginine: 1.082,    // Lys × 1.061
                sidIsoleucine: 0.694,  // Lys × 0.68
                sidLeucine: 1.224,     // Estimated
                sidValine: 0.785,      // Lys × 0.77
                calcium: 0.71,
                availablePhosphorus: 0.36,
                sodium: 0.16,
                potassium: 0.64,
                chloride: 0.23,
                choline: 1.45
            )
        }
    }

    /// Cobb requirements from Excel
    private static func getCobbRequirements(ageInDays: Int) -> NutrientRequirements {
        let phase: BroilerPhase
        if ageInDays <= 10 {
            phase = .starter
        } else if ageInDays <= 24 {
            phase = .grower
        } else if ageInDays <= 39 {
            phase = .finisher1
        } else {
            phase = .finisher2
        }

        switch phase {
        case .starter:
            return NutrientRequirements(
                metabolizableEnergy: 3000,
                crudeProtein: 23.0,
                sidLysine: 1.260,
                sidMethionine: 0.505,  // Lys × 0.40
                sidMetCys: 0.958,      // Lys × 0.76
                sidThreonine: 0.840,   // Lys × 0.667
                sidTryptophan: 0.202,  // Lys × 0.16
                sidArginine: 1.383,    // Lys × 1.098
                sidIsoleucine: 0.857,  // Lys × 0.68
                sidLeucine: 1.512,     // Estimated
                sidValine: 0.970,      // Lys × 0.77
                calcium: 0.92,
                availablePhosphorus: 0.46,
                sodium: 0.16,
                potassium: 0.82,
                chloride: 0.23,
                choline: 1.60
            )

        case .grower:
            return NutrientRequirements(
                metabolizableEnergy: 3075,
                crudeProtein: 21.0,
                sidLysine: 1.160,
                sidMethionine: 0.475,  // Lys × 0.41
                sidMetCys: 0.898,      // Lys × 0.774
                sidThreonine: 0.774,   // Lys × 0.667
                sidTryptophan: 0.187,  // Lys × 0.161
                sidArginine: 1.267,    // Lys × 1.092
                sidIsoleucine: 0.789,  // Lys × 0.68
                sidLeucine: 1.392,     // Estimated
                sidValine: 0.893,      // Lys × 0.77
                calcium: 0.84,
                availablePhosphorus: 0.42,
                sodium: 0.16,
                potassium: 0.74,
                chloride: 0.23,
                choline: 1.50
            )

        case .finisher1:
            return NutrientRequirements(
                metabolizableEnergy: 3150,
                crudeProtein: 19.0,
                sidLysine: 1.080,
                sidMethionine: 0.450,  // Lys × 0.417
                sidMetCys: 0.868,      // Lys × 0.804
                sidThreonine: 0.720,   // Lys × 0.667
                sidTryptophan: 0.170,  // Lys × 0.157
                sidArginine: 1.146,    // Lys × 1.061
                sidIsoleucine: 0.734,  // Lys × 0.68
                sidLeucine: 1.296,     // Estimated
                sidValine: 0.832,      // Lys × 0.77
                calcium: 0.76,
                availablePhosphorus: 0.38,
                sodium: 0.16,
                potassium: 0.66,
                chloride: 0.23,
                choline: 1.40
            )

        case .finisher2:
            return NutrientRequirements(
                metabolizableEnergy: 3175,
                crudeProtein: 17.5,
                sidLysine: 1.040,
                sidMethionine: 0.438,  // Lys × 0.421
                sidMetCys: 0.836,      // Lys × 0.804
                sidThreonine: 0.694,   // Lys × 0.667
                sidTryptophan: 0.163,  // Lys × 0.157
                sidArginine: 1.103,    // Lys × 1.061
                sidIsoleucine: 0.707,  // Lys × 0.68
                sidLeucine: 1.248,     // Estimated
                sidValine: 0.801,      // Lys × 0.77
                calcium: 0.68,
                availablePhosphorus: 0.34,
                sodium: 0.16,
                potassium: 0.62,
                chloride: 0.23,
                choline: 1.35
            )
        }
    }

    /// Amino Chick requirements from Excel
    private static func getAminoChickRequirements(ageInDays: Int) -> NutrientRequirements {
        let phase: BroilerPhase
        if ageInDays <= 10 {
            phase = .starter
        } else if ageInDays <= 24 {
            phase = .grower
        } else if ageInDays <= 39 {
            phase = .finisher1
        } else {
            phase = .finisher2
        }

        switch phase {
        case .starter:
            return NutrientRequirements(
                metabolizableEnergy: 2950,
                crudeProtein: 22.5,
                sidLysine: 1.280,
                sidMethionine: 0.512,
                sidMetCys: 0.973,
                sidThreonine: 0.854,
                sidTryptophan: 0.205,
                sidArginine: 1.406,
                sidIsoleucine: 0.870,
                sidLeucine: 1.536,
                sidValine: 0.986,
                calcium: 0.94,
                availablePhosphorus: 0.47,
                sodium: 0.16,
                potassium: 0.80,
                chloride: 0.23,
                choline: 1.65
            )

        case .grower:
            return NutrientRequirements(
                metabolizableEnergy: 3025,
                crudeProtein: 20.5,
                sidLysine: 1.070,
                sidMethionine: 0.438,
                sidMetCys: 0.828,
                sidThreonine: 0.714,
                sidTryptophan: 0.172,
                sidArginine: 1.172,
                sidIsoleucine: 0.728,
                sidLeucine: 1.284,
                sidValine: 0.824,
                calcium: 0.81,
                availablePhosphorus: 0.41,
                sodium: 0.16,
                potassium: 0.71,
                chloride: 0.23,
                choline: 1.50
            )

        case .finisher1:
            return NutrientRequirements(
                metabolizableEnergy: 3075,
                crudeProtein: 18.5,
                sidLysine: 0.950,
                sidMethionine: 0.396,
                sidMetCys: 0.764,
                sidThreonine: 0.634,
                sidTryptophan: 0.149,
                sidArginine: 1.008,
                sidIsoleucine: 0.646,
                sidLeucine: 1.140,
                sidValine: 0.732,
                calcium: 0.72,
                availablePhosphorus: 0.36,
                sodium: 0.16,
                potassium: 0.63,
                chloride: 0.23,
                choline: 1.40
            )

        case .finisher2:
            return NutrientRequirements(
                metabolizableEnergy: 3100,
                crudeProtein: 17.0,
                sidLysine: 0.890,
                sidMethionine: 0.375,
                sidMetCys: 0.716,
                sidThreonine: 0.594,
                sidTryptophan: 0.140,
                sidArginine: 0.944,
                sidIsoleucine: 0.605,
                sidLeucine: 1.068,
                sidValine: 0.685,
                calcium: 0.65,
                availablePhosphorus: 0.33,
                sodium: 0.16,
                potassium: 0.58,
                chloride: 0.23,
                choline: 1.30
            )
        }
    }
}

/// Nutrient requirements data structure
struct NutrientRequirements {
    let metabolizableEnergy: Double  // kcal/kg
    let crudeProtein: Double         // %
    let sidLysine: Double            // %
    let sidMethionine: Double        // %
    let sidMetCys: Double            // %
    let sidThreonine: Double         // %
    let sidTryptophan: Double        // %
    let sidArginine: Double          // %
    let sidIsoleucine: Double        // %
    let sidLeucine: Double           // %
    let sidValine: Double            // %
    let calcium: Double              // %
    let availablePhosphorus: Double  // %
    let sodium: Double               // %
    let potassium: Double            // %
    let chloride: Double             // %
    let choline: Double              // g/kg
}
