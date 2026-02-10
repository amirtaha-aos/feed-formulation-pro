# Feed Formulation Pro - Cross-Platform Edition

Professional-grade least-cost feed formulation software for Windows, macOS, and Linux. Built with Electron, React, and TypeScript.

## 🚀 Features

- **77 Ingredients** across 5 categories (Grains, Plant By-Products, Animal Sources, Fats & Oils, Supplements & Additives)
- **WPSA Energy Calculations** - Industry-standard AMEn formulas
- **SID Amino Acids** - Standardized Ileal Digestible values for precise nutrition
- **Multi-Strain Support** - Ross, Cobb, Aviagen, Amino Chick, Dynamic Model
- **Linear Programming Optimizer** - Least-cost formulation engine
- **Light/Dark Themes** - Comfortable viewing in any environment
- **Cross-Platform** - Works on Windows, macOS, and Linux

## 📋 Requirements

- Node.js 18+
- npm 9+

## 🛠 Installation

### For Development

```bash
# Clone or download the project
cd FeedFormulation-Windows

# Install dependencies
npm install

# Run in development mode
npm run electron:dev
```

### For Production Build

```bash
# Build for Windows
npm run dist:win

# Build for macOS
npm run dist:mac

# Build for Linux
npm run dist:linux

# Build for all platforms
npm run dist:all
```

## 📦 Build Outputs

After building, installers will be in the `release/` folder:

- **Windows**: `Feed Formulation Pro Setup x.x.x.exe`
- **macOS**: `Feed Formulation Pro-x.x.x.dmg`
- **Linux**: `Feed Formulation Pro-x.x.x.AppImage` and `.deb`

## 🎯 Quick Start

1. **Select Strain**: Choose your genetics (Ross, Cobb, etc.) from the header dropdown
2. **Add Ingredients**: Click ingredients from the left panel to add to your formulation
3. **Set Constraints**: Define min/max percentages for ingredients and nutrient requirements
4. **Enter Prices**: Input current market prices per kilogram
5. **Calculate**: Click the Calculate button to optimize
6. **Review Results**: View the optimized formula in the right panel

## 🏗 Project Structure

```
FeedFormulation-Windows/
├── electron/
│   ├── main.ts           # Electron main process
│   └── preload.ts        # Preload script
├── src/
│   ├── components/       # React components
│   │   ├── App.tsx
│   │   ├── Header.tsx
│   │   ├── IngredientPanel.tsx
│   │   ├── NutrientPanel.tsx
│   │   └── ResultsPanel.tsx
│   ├── data/             # Data files
│   │   ├── ingredients.ts    # 77-ingredient database
│   │   └── strainPresets.ts  # Strain requirements
│   ├── utils/            # Utility functions
│   │   ├── optimizer.ts      # LP solver
│   │   ├── calculations.ts   # WPSA formulas
│   │   └── sidDigestibility.ts
│   ├── types/            # TypeScript types
│   │   ├── types.ts
│   │   └── enums.ts
│   ├── styles/           # CSS and theming
│   │   ├── index.css
│   │   └── colors.ts
│   └── main.tsx          # React entry point
├── public/
├── build/                # App icons
├── package.json
├── tsconfig.json
├── vite.config.ts
└── index.html
```

## 🧪 Technology Stack

- **Electron** - Cross-platform desktop framework
- **React** - UI library
- **TypeScript** - Type-safe JavaScript
- **Vite** - Fast build tool and dev server
- **CSS3** - Styling with CSS variables for theming

## 📐 Technical Details

### WPSA Energy Calculation

```typescript
AMEn (kcal/kg) = 37.13×CP + 81.68×EE + 35.56×NFE - 12.82×CF - 8.22×CP
```

Where:
- CP = Crude Protein (%)
- EE = Ether Extract/Fat (%)
- CF = Crude Fiber (%)
- NFE = Nitrogen-Free Extract = 100 - CP - EE - CF - Ash

### Optimization Algorithm

The app uses a linear programming approach to minimize cost:

```
Minimize: Σ(Ingredient% × Price/kg)

Subject to:
  - Nutrient_min ≤ Σ(Ingredient% × Nutrient_value) ≤ Nutrient_max
  - Ingredient_min ≤ Ingredient% ≤ Ingredient_max
  - Σ Ingredient% = 100%
```

### SID Amino Acids

All amino acid requirements use Standardized Ileal Digestible (SID) values, which account for:
- True ileal digestibility
- Endogenous amino acid losses
- More accurate than total amino acid values

## 🎨 Themes

The app supports Light and Dark themes with a carefully designed color palette:

- **Light Theme**: Clean, professional appearance for daylight use
- **Dark Theme**: Reduced eye strain for low-light environments

Toggle between themes using the button in the header.

## 🐔 Supported Animal Types

### Broiler Chickens
- Starter (0-10 days)
- Grower (11-24 days)
- Finisher (25+ days)

### Layer Hens
- Production phase requirements
- High calcium for eggshell formation

### Turkeys
- Starter, Grower, Finisher phases

### Swine
- Starter, Grower, Finisher phases

## 📊 Ingredient Categories

### 1. Grains (14 items)
Corn, Wheat, Barley, Oats, Rye, Rice, Sorghum, Triticale, and more.

### 2. Plant By-Products (32 items)
Soybean Meal, Sunflower Meal, Canola Meal, DDGS, Wheat Bran, Rice Bran, and more.

### 3. Animal Sources (3 items)
Fish Meal, Meat & Bone Meal, Poultry By-Product Meal.

### 4. Fats & Oils (3 items)
Oil, Crystalline Fat, Calcium Salt Fat.

### 5. Supplements & Additives (25 items)
Synthetic amino acids, minerals, vitamins, and feed additives.

## 🔧 Development

### Running Tests

```bash
npm test
```

### Building for Development

```bash
npm run build
```

### Debugging

Open DevTools in the app:
- Windows/Linux: `Ctrl+Shift+I`
- macOS: `Cmd+Option+I`

## 📄 License

MIT License - See [LICENSE](LICENSE) file for details.

## 👥 Credits

- **Original Concept**: PHD Khaleghi
- **Swift/macOS Version**: Feed Formulation Research Team
- **Cross-Platform Port**: Built with [Claude Code](https://claude.com/claude-code)

## 🐛 Known Issues

- First launch may be slow while Electron initializes
- Windows Defender may show a warning on first run (click "More info" → "Run anyway")

## 🤝 Contributing

Contributions are welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## 📧 Support

- **Issues**: Report bugs or request features on GitHub
- **Documentation**: See the included PDF user guide
- **Email**: phd.khaleghi@example.com

## 🗺 Roadmap

- [ ] Add export to Excel/PDF
- [ ] Cloud synchronization
- [ ] Batch formulation mode
- [ ] Price history tracking
- [ ] Multi-language support (Persian, Arabic, Spanish)
- [ ] Mobile companion app
- [ ] Integration with feed mill management systems

---

**Feed Formulation Pro v2.1.0** - Professional nutrition at your fingertips.

🤖 Built with [Claude Code](https://claude.com/claude-code)
