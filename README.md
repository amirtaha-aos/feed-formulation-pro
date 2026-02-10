# Feed Formulation Pro - PHD Khaleghi

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![macOS](https://img.shields.io/badge/macOS-13.0+-blue.svg)](https://www.apple.com/macos)
[![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)](https://swift.org)
[![SwiftUI](https://img.shields.io/badge/SwiftUI-4.0-green.svg)](https://developer.apple.com/xcode/swiftui/)

Professional-grade least-cost feed formulation software designed for poultry and livestock nutritionists. Built with Swift and SwiftUI for macOS, featuring WPSA energy calculations, SID amino acid values, and advanced optimization algorithms.

![Feed Formulation Pro](https://img.shields.io/badge/version-2.1-brightgreen.svg)

## Features

### Core Functionality
- **77 Ingredients** across 5 major categories
  - Grains (14 items)
  - Plant By-Products (32 items)
  - Animal Sources (3 items)
  - Fats & Oils (3 items)
  - Supplements & Additives (25 items)

### Advanced Nutrition
- **WPSA-based AMEn** (Apparent Metabolizable Energy) calculations
- **SID Amino Acid** digestibility coefficients for precise formulation
- Complete proximate analysis (DM, CP, EE, CF, Ash)
- Comprehensive mineral and vitamin profiles

### Strain-Specific Requirements
- **Ross** - Industry standard, high breast yield
- **Cobb** - Fast growth, excellent feed conversion
- **Aviagen** - Premium meat quality
- **Amino Chick** - Regional adaptation
- **Dynamic Model** - Age-based polynomial calculations

### Optimization Engine
- Linear programming (Simplex algorithm) for least-cost formulations
- Real-time constraint validation
- Shadow price analysis
- Multiple objective functions

### User Experience
- Light/Dark mode interface
- Intuitive drag-and-drop ingredient selection
- Real-time nutrient analysis
- Cost per kg calculations
- Professional reporting

## Screenshots

*Coming soon*

## Installation

### macOS (Apple Silicon)

Download the latest release for Apple Silicon Macs (M1, M2, M3, M4):

```bash
# Download from releases page
curl -L https://github.com/amirtaha-aos/feed-formulation-pro/releases/latest/download/FeedFormulationPro-macOS-arm64.zip -o FeedFormulationPro.zip

# Extract
unzip FeedFormulationPro.zip

# Move to Applications
mv "Feed Formulation Pro.app" /Applications/

# Open the app
open "/Applications/Feed Formulation Pro.app"
```

### macOS (Intel x86_64)

For Intel-based Macs:

```bash
# Download from releases page
curl -L https://github.com/amirtaha-aos/feed-formulation-pro/releases/latest/download/FeedFormulationPro-macOS-x86_64.zip -o FeedFormulationPro.zip

# Extract and install
unzip FeedFormulationPro.zip
mv "Feed Formulation Pro.app" /Applications/
```

### Windows

Download the Windows installer from the [releases page](https://github.com/amirtaha-aos/feed-formulation-pro/releases/latest).

```powershell
# Run the installer
FeedFormulationPro-Windows-Setup.exe
```

## Building from Source

### Prerequisites

- macOS 13.0 or later (for macOS builds)
- Xcode 15.0 or later
- Swift 5.9 or later

### Build Instructions

```bash
# Clone the repository
git clone https://github.com/amirtaha-aos/feed-formulation-pro.git
cd feed-formulation-pro

# Build for release
swift build -c release

# Create app bundle
swift build -c release --arch arm64
# or for Intel Macs
swift build -c release --arch x86_64

# Run
.build/release/FeedFormulationPro
```

## Usage

### Quick Start

1. **Select Your Strain**: Choose from Ross, Cobb, Aviagen, Amino Chick, or Dynamic Model
2. **Add Ingredients**: Browse categories and click to add ingredients to your formulation
3. **Set Constraints**: Define min/max values for each ingredient and nutrient requirements
4. **Enter Prices**: Input current market prices per kilogram
5. **Calculate**: Click the Calculate button to run the optimizer
6. **Review Results**: Analyze the optimized formula, nutrient profile, and cost

### Diet Types

#### Broiler Chickens
- **Starter** (0-10 days): 3000 kcal/kg, 22-23% CP, 1.28% Lys SID
- **Grower** (11-24 days): 3100 kcal/kg, 20-21% CP, 1.15% Lys SID
- **Finisher** (25+ days): 3200 kcal/kg, 18-19% CP, 1.03% Lys SID

#### Layer Hens
- **Production**: 2800 kcal/kg, 16-17% CP, 0.75% Lys SID, 3.8-4.2% Ca

#### Turkeys
- **Starter**: 2900 kcal/kg, 28-30% CP, 1.65% Lys SID
- **Grower**: 3050 kcal/kg, 22-24% CP, 1.30% Lys SID

#### Swine
- **Starter**: 3450 kcal/kg DE, 20-22% CP, 1.25% Lys SID
- **Grower**: 3350 kcal/kg DE, 18% CP, 1.0% Lys SID
- **Finisher**: 3300 kcal/kg DE, 15-16% CP, 0.85% Lys SID

### Documentation

Complete user guide is available in the [User Guide PDF](https://github.com/amirtaha-aos/feed-formulation-pro/releases/latest/download/Feed-Formulation-Pro-User-Guide.pdf).

## Technical Details

### Architecture

- **Language**: Swift 5.9
- **Framework**: SwiftUI 4.0
- **Minimum OS**: macOS 13.0+
- **Optimization**: Linear Programming (Simplex Algorithm)
- **Build System**: Swift Package Manager

### Project Structure

```
feed-formulation-pro/
├── Sources/
│   ├── App.swift                 # Main entry point
│   ├── Models/                   # Data models
│   │   ├── Enums/               # Enumerations
│   │   ├── Ingredient.swift     # 77-ingredient library
│   │   ├── IngredientDatabase.swift
│   │   ├── NutrientConstraint.swift
│   │   ├── RationSolution.swift
│   │   └── StrainPresets.swift  # Strain requirements
│   ├── ViewModels/              # Business logic
│   │   └── FeedFormViewModel.swift
│   ├── Views/                   # UI components
│   │   ├── ContentView.swift    # Main interface
│   │   └── Components/          # Reusable components
│   ├── Services/                # Core services
│   │   └── RationSolver.swift   # Optimization engine
│   ├── Styles/                  # Theme and styling
│   └── Extensions/              # Utility extensions
├── Package.swift                # SPM configuration
└── README.md
```

### Algorithms

#### WPSA Energy Calculation

```swift
AMEn (kcal/kg) = 37.13×CP + 81.68×EE + 35.56×NFE - 12.82×CF - 8.22×CP
```

Where:
- CP = Crude Protein (%)
- EE = Ether Extract (%)
- CF = Crude Fiber (%)
- NFE = Nitrogen-Free Extract = 100 - CP - EE - CF - Ash

#### Dietary Electrolyte Balance (DEB)

```swift
DEB (mEq/kg) = (Na% × 434.98) + (K% × 255.74) - (Cl% × 282.06)
```

#### Linear Programming Objective

```
Minimize: Σ(Ingredient_% × Price_per_kg)
Subject to:
  - Nutrient_min ≤ Σ(Ingredient_% × Nutrient_content) ≤ Nutrient_max
  - Ingredient_min ≤ Ingredient_% ≤ Ingredient_max
  - Σ Ingredient_% = 100%
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

### Development Setup

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes with conventional commits
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Code Style

- Follow Swift API Design Guidelines
- Use SwiftLint for code formatting
- Write clear, descriptive commit messages
- Add tests for new features

## Roadmap

- [ ] Cloud synchronization
- [ ] Export to Excel/CSV
- [ ] Batch formulation
- [ ] Cost history tracking
- [ ] Ingredient price alerts
- [ ] Multi-language support (Persian, Arabic, Spanish)
- [ ] Mobile companion app (iOS/Android)
- [ ] Web version
- [ ] Database of local ingredient prices
- [ ] Integration with feed mill management systems

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Citations & References

### Nutritional Standards
- World's Poultry Science Association (WPSA) - AME calculation methods
- National Research Council (NRC) - Nutrient Requirements of Poultry
- Aviagen - Ross Broiler Nutrition Specifications
- Cobb-Vantress - Cobb Broiler Management Guide
- Hy-Line International - Layer Management Guides

### Scientific Publications
- Emmans, G.C. (1994). Effective energy: a concept of energy utilization
- Baker, D.H. (1997). Ideal amino acid profiles for swine and poultry
- Lemme, A. et al. (2004). Ideal amino acid ratios in broiler nutrition
- Rostagno, H.S. et al. (2017). Brazilian Tables for Poultry and Swine

## Support

For issues, questions, or suggestions:

- Open an [Issue](https://github.com/amirtaha-aos/feed-formulation-pro/issues)
- Check the [User Guide](https://github.com/amirtaha-aos/feed-formulation-pro/releases/latest/download/Feed-Formulation-Pro-User-Guide.pdf)
- Email: [phd.khaleghi@example.com](mailto:phd.khaleghi@example.com)

## Acknowledgments

- PHD Khaleghi - Lead researcher and nutritionist
- World's Poultry Science Association (WPSA) - Energy calculation standards
- Genetic companies (Aviagen, Cobb-Vantress) - Strain requirements
- Open source community - Swift and SwiftUI ecosystem

## Disclaimer

This software is intended as a tool for professional nutritionists. Always verify formulations with:
- Feeding trials
- Laboratory analysis
- Expert consultation
- Regulatory compliance

---

**Feed Formulation Pro - PHD Khaleghi v2.1**

*Built with Swift, powered by science, designed for professionals.*

🤖 *Developed with assistance from [Claude Code](https://claude.com/claude-code)*
