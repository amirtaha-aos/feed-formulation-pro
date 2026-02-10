import Foundation
import SwiftUI
import AppKit
import UniformTypeIdentifiers

struct ContentView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @StateObject private var viewModel = FeedFormViewModel()
    @State private var tab: WorkspaceTab = .formula
    @State private var catalogGroup: IngredientGroup = .grain
    @State private var selectedNutrientKey: NutrientKey = .crudeProtein
    @State private var selectedIngredientID: UUID?
    @State private var showFullNutrientEditor = true
    @State private var selectedStrain: StrainPresets.BroilerStrain = .ross

    private let dayFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .none
        formatter.minimum = 1
        formatter.maximum = 180
        formatter.allowsFloats = false
        return formatter
    }()

    private var sortedAllocations: [RationAllocation] {
        guard let solution = viewModel.solution else { return [] }
        return solution.allocations
            .filter { $0.inclusionPercent > 0.03 }
            .sorted { $0.inclusionPercent > $1.inclusionPercent }
    }

    private var statusColor: Color {
        guard let solution = viewModel.solution else { return Palette.textMuted }
        return solution.status == .feasible ? Palette.pine : Palette.amber
    }

    private var rangeStatusColor: Color {
        let hasRange = viewModel.minTotalPercent <= 100 && viewModel.maxTotalPercent >= 100
        return hasRange ? Palette.textMuted : Palette.coral
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Palette.midnight, Palette.indigo, Palette.ocean],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            Circle()
                .fill(Palette.pine.opacity(0.30))
                .frame(width: 420, height: 420)
                .blur(radius: 22)
                .offset(x: -520, y: -290)
                .blendMode(.plusLighter)

            Circle()
                .fill(Palette.amber.opacity(0.24))
                .frame(width: 360, height: 360)
                .blur(radius: 24)
                .offset(x: 540, y: -310)
                .blendMode(.plusLighter)

            VStack(spacing: 16) {
                topHeader
                HSplitView {
                    leftPanel
                    resultPanel
                }
            }
            .padding(20)
        }
        .preferredColorScheme(themeManager.isDarkMode ? .dark : .light)
        .onAppear {
            syncNutrientsSelection()
        }
        .onChange(of: viewModel.ingredients.map(\.id)) { _ in
            syncNutrientsSelection()
        }
    }

    private var topHeader: some View {
        HStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Feed Formulation Pro")
                    .font(.custom("AvenirNext-Bold", size: 36))
                    .foregroundStyle(Palette.textPrimary)
                Text("Formula + Nutrients + Ingredients + SID Amino Acids + WPSA Energy + Optimizer")
                    .font(.custom("AvenirNext-Regular", size: 13))
                    .foregroundStyle(Palette.textMuted)
            }

            // Strain Selector
            Picker("Strain", selection: $selectedStrain) {
                ForEach(StrainPresets.BroilerStrain.allCases) { strain in
                    Text(strain.rawValue).tag(strain)
                }
            }
            .pickerStyle(.menu)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                Capsule(style: .continuous)
                    .fill(Palette.ocean.opacity(0.20))
            )
            .overlay(
                Capsule(style: .continuous)
                    .stroke(Palette.ocean.opacity(0.75), lineWidth: 1)
            )

            Text("ADVANCED FORMULATION")
                .font(.custom("AvenirNext-DemiBold", size: 11))
                .kerning(1.1)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(
                    Capsule(style: .continuous)
                        .fill(Palette.pine.opacity(0.20))
                )
                .overlay(
                    Capsule(style: .continuous)
                        .stroke(Palette.pine.opacity(0.75), lineWidth: 1)
                )
                .foregroundStyle(Palette.pine)

            if viewModel.isCalculating {
                HStack(spacing: 6) {
                    ProgressView()
                        .controlSize(.small)
                    Text("Calculating...")
                        .font(.custom("AvenirNext-Medium", size: 12))
                        .foregroundStyle(Palette.textMuted)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(
                    Capsule(style: .continuous)
                        .fill(Palette.cardSoft)
                )
                .overlay(
                    Capsule(style: .continuous)
                        .stroke(Palette.border, lineWidth: 1)
                )
            }

            Spacer(minLength: 12)

            // Theme Toggle Button
            Button {
                themeManager.isDarkMode.toggle()
            } label: {
                Label(
                    themeManager.isDarkMode ? "Light Mode" : "Dark Mode",
                    systemImage: themeManager.isDarkMode ? "sun.max.fill" : "moon.fill"
                )
            }
            .buttonStyle(SecondaryActionStyle())

            Button {
                viewModel.resetProject()
            } label: {
                Label("Reset", systemImage: "arrow.counterclockwise")
            }
            .buttonStyle(SecondaryActionStyle())

            Button {
                viewModel.calculateFormula()
            } label: {
                Label("Calculate Formula", systemImage: "bolt.circle.fill")
            }
            .buttonStyle(PrimaryActionStyle())
            .keyboardShortcut(.return, modifiers: [.command])
            .help("Manual run only (shortcut: Command+Return)")
            .disabled(viewModel.isCalculating)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Palette.panelTop, Palette.panelBottom],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Palette.strongBorder, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.34), radius: 18, y: 10)
    }

    private var leftPanel: some View {
        VStack(spacing: 12) {
            workspaceTabs
            if tab == .formula {
                formulaWorkspace
            } else if tab == .nutrientsAndIngredients {
                nutrientsWorkspace
            } else {
                operationsWorkspace
            }
        }
        .background(panelBackground)
        .frame(minWidth: 950)
    }

    private var workspaceTabs: some View {
        HStack(spacing: 8) {
            ForEach(WorkspaceTab.allCases) { item in
                Button {
                    tab = item
                } label: {
                    Text(item.rawValue)
                        .font(.custom("AvenirNext-DemiBold", size: 13))
                        .foregroundStyle(tab == item ? Palette.textPrimary : Palette.textMuted)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(tab == item ? Palette.ocean.opacity(0.90) : Palette.cardSoft)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .stroke(tab == item ? Palette.strongBorder : Palette.border, lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 12)
        .padding(.top, 12)
    }

    private var formulaWorkspace: some View {
        ScrollView {
            VStack(spacing: 12) {
                SectionCard(
                    title: "Formula Workspace",
                    subtitle: "Diet name, existing diets, and optimizer setup.",
                    accent: Palette.ocean
                ) {
                    VStack(spacing: 10) {
                        HStack {
                            Text("Day Range")
                                .frame(width: 110, alignment: .leading)
                                .foregroundStyle(Palette.textMuted)

                            HStack(spacing: 8) {
                                Text("From")
                                    .font(.custom("AvenirNext-Medium", size: 12))
                                    .foregroundStyle(Palette.textMuted)
                                TextField("1", value: $viewModel.dayFrom, formatter: dayFormatter)
                                    .textFieldStyle(.plain)
                                    .inputChrome()
                                    .frame(width: 70)
                                    .multilineTextAlignment(.trailing)
                                Stepper("", value: $viewModel.dayFrom, in: 1...180)
                                    .labelsHidden()
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)

                            HStack(spacing: 8) {
                                Text("To")
                                    .font(.custom("AvenirNext-Medium", size: 12))
                                    .foregroundStyle(Palette.textMuted)
                                TextField("35", value: $viewModel.dayTo, formatter: dayFormatter)
                                    .textFieldStyle(.plain)
                                    .inputChrome()
                                    .frame(width: 70)
                                    .multilineTextAlignment(.trailing)
                                Stepper("", value: $viewModel.dayTo, in: 1...180)
                                    .labelsHidden()
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }

                        HStack {
                            Text("Use top \"Calculate Formula\" button to run solver.")
                                .font(.custom("AvenirNext-Regular", size: 11))
                                .foregroundStyle(Palette.textMuted)
                            Spacer()
                        }

                        HStack {
                            Text("Diet Name")
                                .frame(width: 110, alignment: .leading)
                                .foregroundStyle(Palette.textMuted)
                            TextField("Diet Name", text: $viewModel.formulaName)
                                .textFieldStyle(.plain)
                                .inputChrome()
                        }

                        HStack(spacing: 8) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Bird Type")
                                    .font(.custom("AvenirNext-Medium", size: 12))
                                    .foregroundStyle(Palette.textMuted)
                                Picker("Bird Type", selection: $viewModel.birdType) {
                                    ForEach(BirdType.allCases) { kind in
                                        Text(kind.rawValue).tag(kind)
                                    }
                                }
                                .pickerStyle(.menu)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                                        .fill(Palette.input)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                                        .stroke(Palette.border, lineWidth: 1)
                                )
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)

                            VStack(alignment: .leading, spacing: 4) {
                                Text("Feeding Goal")
                                    .font(.custom("AvenirNext-Medium", size: 12))
                                    .foregroundStyle(Palette.textMuted)
                                Picker("Feeding Goal", selection: $viewModel.feedingGoal) {
                                    ForEach(FeedingGoal.allCases) { goal in
                                        Text(goal.rawValue).tag(goal)
                                    }
                                }
                                .pickerStyle(.menu)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                                        .fill(Palette.input)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                                        .stroke(Palette.border, lineWidth: 1)
                                )
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }

                        Text("Bird Type + Feeding Goal are used by Apply Stage Preset in Optimizer.")
                            .font(.custom("AvenirNext-Regular", size: 11))
                            .foregroundStyle(Palette.textMuted)

                        HStack(spacing: 8) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Excel Price Preset")
                                    .font(.custom("AvenirNext-Medium", size: 12))
                                    .foregroundStyle(Palette.textMuted)
                                Picker("Excel Price Preset", selection: $viewModel.workbookPricePresetName) {
                                    ForEach(Ingredient.workbookPricePresets, id: \.name) { preset in
                                        Text(preset.name).tag(preset.name)
                                    }
                                }
                                .pickerStyle(.menu)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                                        .fill(Palette.input)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                                        .stroke(Palette.border, lineWidth: 1)
                                )
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)

                            Button("Apply Excel Prices") {
                                viewModel.applyWorkbookPricePreset()
                            }
                            .buttonStyle(SecondaryActionStyle())
                        }

                        HStack(spacing: 8) {
                            Picker("Existing Diets", selection: $viewModel.selectedDietID) {
                                Text("Select Diet").tag(UUID?.none)
                                ForEach(viewModel.savedDiets) { diet in
                                    Text(diet.name).tag(Optional(diet.id))
                                }
                            }
                            .pickerStyle(.menu)
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .fill(Palette.input)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .stroke(Palette.border, lineWidth: 1)
                            )

                            Button("Load") { viewModel.loadSelectedDiet() }
                                .buttonStyle(SecondaryActionStyle())
                            Button("Save") { viewModel.saveCurrentDiet() }
                                .buttonStyle(SecondaryActionStyle())
                            Button("Delete") { viewModel.deleteSelectedDiet() }
                                .buttonStyle(SecondaryActionStyle())
                        }
                    }
                }

                SectionCard(
                    title: "Optimizer",
                    subtitle: "Enable ingredient groups used by solver and apply stage-based presets.",
                    accent: Palette.pine
                ) {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(spacing: 8) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Optimization Mode")
                                    .font(.custom("AvenirNext-Medium", size: 12))
                                    .foregroundStyle(Palette.textMuted)
                                Picker("Optimization Mode", selection: $viewModel.optimizationMode) {
                                    ForEach(OptimizationMode.allCases) { mode in
                                        Text(mode.rawValue).tag(mode)
                                    }
                                }
                                .pickerStyle(.menu)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                                        .fill(Palette.input)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                                        .stroke(Palette.border, lineWidth: 1)
                                )
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)

                            labeledNumeric(
                                title: "Profit Weight",
                                value: $viewModel.profitWeight,
                                fraction: 3
                            )

                            labeledNumeric(
                                title: "Sale Price (Toman/kg)",
                                value: $viewModel.salePricePerLiveKg,
                                fraction: 0
                            )
                        }

                        Text("Ingredient Group Filters")
                            .font(.custom("AvenirNext-Medium", size: 13))
                            .foregroundStyle(Palette.textMuted)

                        ScrollView(.horizontal) {
                            HStack(spacing: 8) {
                                ForEach(IngredientGroup.allCases) { group in
                                    GroupChip(
                                        title: group.rawValue,
                                        isOn: viewModel.enabledGroups.contains(group),
                                        onTap: {
                                            viewModel.toggleGroup(group)
                                        }
                                    )
                                }
                            }
                        }

                        HStack(spacing: 8) {
                            Button("Apply Stage Preset") {
                                viewModel.applyPreset()
                            }
                            .buttonStyle(SecondaryActionStyle())

                            Button("Enable Vitamins + Minerals") {
                                viewModel.enableMicronutrients()
                            }
                            .buttonStyle(SecondaryActionStyle())
                        }

                        Text("Active ingredients for optimizer: \(viewModel.activeIngredientCount)")
                            .font(.custom("AvenirNext-Medium", size: 12))
                            .foregroundStyle(Palette.textMuted)

                        HStack(spacing: 8) {
                            MetricCard(
                                title: "Objective / kg",
                                value: toman(viewModel.solution?.objectivePerKg ?? 0)
                            )
                            MetricCard(
                                title: "Feed Cost / Bird",
                                value: toman(viewModel.feedCostPerBirdInPeriod)
                            )
                            MetricCard(
                                title: "Gross Margin / Bird",
                                value: toman(viewModel.grossMarginPerBirdInPeriod)
                            )
                        }
                    }
                }

                ingredientSelectorSection

                SectionCard(
                    title: "Price (Toman/kg) + Batch",
                    subtitle: "Batch economics and consumption side of Formula screen.",
                    accent: Palette.amber
                ) {
                    VStack(spacing: 10) {
                        HStack {
                            labeledNumeric(title: "Batch Size (kg)", value: $viewModel.batchSizeKg, fraction: 0)
                            labeledNumeric(title: "Daily Feed/Bird (kg)", value: $viewModel.dailyFeedPerBirdKg, fraction: 3)
                        }

                        HStack(spacing: 10) {
                            Stepper("Age: \(viewModel.ageInWeeks) weeks", value: $viewModel.ageInWeeks, in: 1...120)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Stepper("Flock: \(viewModel.flockSize)", value: $viewModel.flockSize, in: 1...300_000)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .foregroundStyle(Palette.textPrimary)

                        HStack(spacing: 8) {
                            MetricCard(title: "Price / kg", value: toman(viewModel.solution?.costPerKg ?? 0))
                            MetricCard(title: "Daily Feed", value: "\(String(format: "%.1f", viewModel.totalDailyFeedKg)) kg")
                            MetricCard(title: "Daily Cost", value: toman(viewModel.estimatedDailyCost))
                        }
                    }
                }

                SectionCard(
                    title: "Premix Convert",
                    subtitle: "Convert premix between % inclusion and kg per batch, then apply to formula.",
                    accent: Palette.coral
                ) {
                    VStack(spacing: 10) {
                        Picker("Premix", selection: $viewModel.selectedPremixID) {
                            Text("Select Premix").tag(UUID?.none)
                            ForEach(viewModel.premixCandidates) { item in
                                Text(item.name).tag(Optional(item.id))
                            }
                        }
                        .pickerStyle(.menu)
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(Palette.input)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .stroke(Palette.border, lineWidth: 1)
                        )

                        HStack {
                            labeledNumeric(title: "Premix %", value: $viewModel.premixPercent, fraction: 3)
                            labeledNumeric(title: "Premix kg", value: $viewModel.premixKg, fraction: 3)
                        }

                        HStack(spacing: 8) {
                            Button("Convert % to kg") {
                                viewModel.convertPremixPercentToKg()
                            }
                            .buttonStyle(SecondaryActionStyle())

                            Button("Convert kg to %") {
                                viewModel.convertPremixKgToPercent()
                            }
                            .buttonStyle(SecondaryActionStyle())

                            Button("Apply to Formula") {
                                viewModel.applyPremixToFormula()
                            }
                            .buttonStyle(SecondaryActionStyle())
                        }
                    }
                }

                HStack {
                    Label(viewModel.statusMessage, systemImage: "waveform.path.ecg")
                        .foregroundStyle(statusColor)
                        .font(.custom("AvenirNext-Medium", size: 13))
                    Spacer()
                }
                .padding(.horizontal, 4)
                .padding(.bottom, 12)
            }
            .padding(12)
        }
    }

    private var ingredientSelectorSection: some View {
        SectionCard(
            title: "Ingredient Selector (AminoFeed-style)",
            subtitle: "Choose category, tick ingredients, and build Selected Ingredients list for the solver.",
            accent: Palette.ocean
        ) {
            HStack(alignment: .top, spacing: 12) {
                selectorGroupColumn
                selectorAvailableColumn
                selectorSelectedColumn
            }
        }
    }

    private var selectorGroupColumn: some View {
        VStack(spacing: 8) {
            ForEach(IngredientGroup.allCases) { group in
                Button {
                    catalogGroup = group
                } label: {
                    HStack {
                        Text(group.rawValue)
                            .lineLimit(1)
                        Spacer()
                        Text("\(viewModel.ingredients(in: group).count)")
                            .font(.custom("AvenirNext-Medium", size: 11))
                            .foregroundStyle(Palette.textMuted)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(catalogGroup == group ? Palette.ocean.opacity(0.75) : Palette.card)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .stroke(
                                catalogGroup == group ? Palette.strongBorder : Palette.border,
                                lineWidth: 1
                            )
                    )
                }
                .buttonStyle(.plain)
            }

            HStack(spacing: 8) {
                Button("Select Group") {
                    viewModel.selectAllIngredients(in: catalogGroup)
                }
                .buttonStyle(SecondaryActionStyle())

                Button("Clear Group") {
                    viewModel.clearSelectedIngredients(in: catalogGroup)
                }
                .buttonStyle(SecondaryActionStyle())
            }
        }
        .frame(width: 205)
    }

    private var selectorAvailableColumn: some View {
        IngredientAvailableColumn(
            group: catalogGroup,
            ingredients: viewModel.ingredients(in: catalogGroup),
            selectedIngredientIDs: viewModel.selectedIngredientIDs,
            onToggle: { ingredientID, isOn in
                viewModel.setIngredientSelection(ingredientID, isOn: isOn)
            }
        )
    }

    private var selectorSelectedColumn: some View {
        IngredientSelectedColumn(
            selectedIngredients: viewModel.selectedIngredients,
            selectedCount: viewModel.selectedIngredientCount,
            onClearAll: { viewModel.clearSelectedIngredients() },
            onUseCoreSet: { viewModel.selectCoreTemplate() }
        )
    }

    private var nutrientsWorkspace: some View {
        ScrollView {
            VStack(spacing: 12) {
                SectionCard(
                    title: "Nutrients & Ingredients (Linked)",
                    subtitle: "Select nutrient on the left, ingredient in center, and edit linked values on the right.",
                    accent: Palette.pine
                ) {
                    HStack(alignment: .top, spacing: 12) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Nutrients")
                                .font(.custom("AvenirNext-DemiBold", size: 15))
                            ScrollView {
                                VStack(spacing: 6) {
                                    ForEach(viewModel.nutrientConstraints) { constraint in
                                        Button {
                                            selectedNutrientKey = constraint.key
                                        } label: {
                                            HStack(spacing: 8) {
                                                VStack(alignment: .leading, spacing: 2) {
                                                    Text(constraint.key.title)
                                                        .font(.custom("AvenirNext-Medium", size: 12))
                                                        .foregroundStyle(Palette.textPrimary)
                                                        .lineLimit(1)
                                                    Text(constraint.key.unit)
                                                        .font(.custom("AvenirNext-Regular", size: 10))
                                                        .foregroundStyle(Palette.textMuted)
                                                }
                                                Spacer()
                                                Text(achievedText(for: constraint.key))
                                                    .font(.custom("AvenirNext-Medium", size: 10))
                                                    .foregroundStyle(Palette.textMuted)
                                                    .monospacedDigit()
                                            }
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 7)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .background(
                                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                                    .fill(
                                                        selectedNutrientKey == constraint.key
                                                            ? Palette.ocean.opacity(0.75)
                                                            : Palette.card
                                                    )
                                            )
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                                    .stroke(
                                                        selectedNutrientKey == constraint.key
                                                            ? Palette.strongBorder
                                                            : Palette.border,
                                                        lineWidth: 1
                                                    )
                                            )
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                            .frame(height: 520)
                        }
                        .frame(width: 260)

                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Ingredients")
                                    .font(.custom("AvenirNext-DemiBold", size: 15))
                                Spacer()
                                Button {
                                    viewModel.addIngredient()
                                    selectedIngredientID = viewModel.ingredients.last?.id
                                } label: {
                                    Label("Add", systemImage: "plus")
                                }
                                .buttonStyle(SecondaryActionStyle())
                            }

                            ScrollView {
                                VStack(spacing: 6) {
                                    ForEach(viewModel.ingredients) { ingredient in
                                        Button {
                                            selectedIngredientID = ingredient.id
                                        } label: {
                                            HStack(spacing: 8) {
                                                VStack(alignment: .leading, spacing: 2) {
                                                    Text(ingredient.name)
                                                        .font(.custom("AvenirNext-Medium", size: 12))
                                                        .foregroundStyle(Palette.textPrimary)
                                                        .lineLimit(1)
                                                    Text(ingredient.group.rawValue)
                                                        .font(.custom("AvenirNext-Regular", size: 10))
                                                        .foregroundStyle(Palette.textMuted)
                                                }
                                                Spacer()
                                                Text(toman(ingredient.pricePerKg))
                                                    .font(.custom("AvenirNext-Medium", size: 10))
                                                    .foregroundStyle(Palette.textMuted)
                                                    .lineLimit(1)
                                            }
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 7)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .background(
                                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                                    .fill(
                                                        activeNutrientIngredientID == ingredient.id
                                                            ? Palette.pine.opacity(0.60)
                                                            : Palette.card
                                                    )
                                            )
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                                    .stroke(
                                                        activeNutrientIngredientID == ingredient.id
                                                            ? Palette.strongBorder
                                                            : Palette.border,
                                                        lineWidth: 1
                                                    )
                                            )
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                            .frame(height: 520)

                            if let activeID = activeNutrientIngredientID {
                                Button(role: .destructive) {
                                    viewModel.removeIngredient(id: activeID)
                                    syncNutrientsSelection()
                                } label: {
                                    Label("Delete Selected", systemImage: "trash.fill")
                                }
                                .buttonStyle(SecondaryActionStyle())
                            }
                        }
                        .frame(width: 300)

                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text("Linked Editor")
                                    .font(.custom("AvenirNext-DemiBold", size: 15))
                                Spacer()
                                Button("Apply Stage Formula") {
                                    viewModel.applyPreset()
                                }
                                .buttonStyle(SecondaryActionStyle())
                            }

                            GroupBox("Selected Nutrient Constraint") {
                                VStack(spacing: 8) {
                                    HStack {
                                        Text(selectedNutrientKey.title)
                                            .font(.custom("AvenirNext-Medium", size: 13))
                                        Spacer()
                                        Text(selectedNutrientKey.unit)
                                            .font(.custom("AvenirNext-Regular", size: 11))
                                            .foregroundStyle(Palette.textMuted)
                                    }
                                    HStack {
                                        Toggle("Min", isOn: constraintUseMinBinding(for: selectedNutrientKey))
                                            .toggleStyle(.checkbox)
                                        TextField(
                                            "",
                                            value: constraintMinValueBinding(for: selectedNutrientKey),
                                            format: .number.precision(.fractionLength(selectedNutrientKey.decimals))
                                        )
                                        .textFieldStyle(.plain)
                                        .inputChrome()
                                        .frame(width: 110)
                                        .multilineTextAlignment(.trailing)

                                        Toggle("Max", isOn: constraintUseMaxBinding(for: selectedNutrientKey))
                                            .toggleStyle(.checkbox)
                                        TextField(
                                            "",
                                            value: constraintMaxValueBinding(for: selectedNutrientKey),
                                            format: .number.precision(.fractionLength(selectedNutrientKey.decimals))
                                        )
                                        .textFieldStyle(.plain)
                                        .inputChrome()
                                        .frame(width: 110)
                                        .multilineTextAlignment(.trailing)
                                    }
                                }
                            }
                            .groupBoxStyle(DashboardGroupBoxStyle())

                            GroupBox("Selected Ingredient") {
                                VStack(alignment: .leading, spacing: 8) {
                                    if let ingredient = activeNutrientIngredient {
                                        Text(ingredient.name)
                                            .font(.custom("AvenirNext-Medium", size: 13))

                                        HStack {
                                            linkedNumeric(
                                                title: "Price",
                                                value: ingredientPriceBinding(for: ingredient.id),
                                                fraction: 0
                                            )
                                            linkedNumeric(
                                                title: "Min %",
                                                value: ingredientMinPercentBinding(for: ingredient.id),
                                                fraction: 2
                                            )
                                            linkedNumeric(
                                                title: "Max %",
                                                value: ingredientMaxPercentBinding(for: ingredient.id),
                                                fraction: 2
                                            )
                                        }

                                        HStack {
                                            linkedNumeric(
                                                title: selectedNutrientKey.short,
                                                value: nutrientValueBinding(
                                                    for: ingredient.id,
                                                    key: selectedNutrientKey
                                                ),
                                                fraction: selectedNutrientKey.decimals
                                            )
                                            Spacer()
                                            Text("Group: \(ingredient.group.rawValue)")
                                                .font(.custom("AvenirNext-Regular", size: 11))
                                                .foregroundStyle(Palette.textMuted)
                                        }

                                        Divider().padding(.vertical, 4)

                                        Toggle("Show Full Nutrient Editor", isOn: $showFullNutrientEditor)
                                            .toggleStyle(.switch)
                                            .font(.custom("AvenirNext-Medium", size: 12))
                                            .foregroundStyle(Palette.textMuted)

                                        if showFullNutrientEditor {
                                            fullNutrientEditor(for: ingredient)
                                        }
                                    } else {
                                        Text("No ingredient selected.")
                                            .foregroundStyle(Palette.textMuted)
                                    }
                                }
                            }
                            .groupBoxStyle(DashboardGroupBoxStyle())

                            GroupBox("Nutrient Value Matrix (\(selectedNutrientKey.short))") {
                                VStack(spacing: 7) {
                                    HStack {
                                        Text("Ingredient")
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        Text("Value")
                                            .frame(width: 110, alignment: .trailing)
                                    }
                                    .font(.custom("AvenirNext-DemiBold", size: 11))
                                    .foregroundStyle(Palette.textMuted)

                                    ScrollView {
                                        VStack(spacing: 6) {
                                            ForEach(viewModel.ingredients) { ingredient in
                                                HStack {
                                                    Button {
                                                        selectedIngredientID = ingredient.id
                                                    } label: {
                                                        Text(ingredient.name)
                                                            .font(.custom("AvenirNext-Medium", size: 12))
                                                            .foregroundStyle(Palette.textPrimary)
                                                            .lineLimit(1)
                                                    }
                                                    .buttonStyle(.plain)

                                                    Spacer()

                                                    TextField(
                                                        "",
                                                        value: nutrientValueBinding(
                                                            for: ingredient.id,
                                                            key: selectedNutrientKey
                                                        ),
                                                        format: .number.precision(
                                                            .fractionLength(selectedNutrientKey.decimals)
                                                        )
                                                    )
                                                    .textFieldStyle(.plain)
                                                    .inputChrome()
                                                    .frame(width: 110)
                                                    .multilineTextAlignment(.trailing)
                                                }
                                                .padding(.horizontal, 6)
                                                .padding(.vertical, 4)
                                                .background(
                                                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                                                        .fill(
                                                            activeNutrientIngredientID == ingredient.id
                                                                ? Palette.ocean.opacity(0.45)
                                                                : Palette.card
                                                        )
                                                )
                                            }
                                        }
                                    }
                                    .frame(height: 170)
                                }
                            }
                            .groupBoxStyle(DashboardGroupBoxStyle())
                        }
                    }
                }

                HStack {
                    Text("Total Min: \(viewModel.minTotalPercent, specifier: "%.1f")%   |   Total Max: \(viewModel.maxTotalPercent, specifier: "%.1f")%")
                        .foregroundStyle(rangeStatusColor)
                        .font(.custom("AvenirNext-Medium", size: 13))
                    Spacer()
                    Label(viewModel.statusMessage, systemImage: "info.circle")
                        .foregroundStyle(statusColor)
                        .font(.custom("AvenirNext-Medium", size: 13))
                }
                .padding(.horizontal, 4)
                .padding(.bottom, 12)
            }
            .padding(12)
        }
    }

    private var activeNutrientIngredientID: UUID? {
        if let selectedIngredientID, viewModel.ingredients.contains(where: { $0.id == selectedIngredientID }) {
            return selectedIngredientID
        }
        return viewModel.ingredients.first?.id
    }

    private var activeNutrientIngredient: Ingredient? {
        guard let activeNutrientIngredientID else { return nil }
        return viewModel.ingredients.first(where: { $0.id == activeNutrientIngredientID })
    }

    private func achievedText(for key: NutrientKey) -> String {
        guard let solution = viewModel.solution else { return "-" }
        guard let assessment = solution.assessments.first(where: { $0.key == key }) else { return "-" }
        return String(format: "%.\(key.decimals)f", assessment.achieved)
    }

    private func syncNutrientsSelection() {
        if viewModel.ingredients.isEmpty {
            selectedIngredientID = nil
            return
        }
        if let selectedIngredientID {
            if !viewModel.ingredients.contains(where: { $0.id == selectedIngredientID }) {
                self.selectedIngredientID = viewModel.ingredients.first?.id
            }
        } else {
            selectedIngredientID = viewModel.ingredients.first?.id
        }
    }

    private func constraintUseMinBinding(for key: NutrientKey) -> Binding<Bool> {
        Binding(
            get: { viewModel.constraint(for: key)?.useMin ?? false },
            set: { viewModel.setConstraintUseMin($0, for: key) }
        )
    }

    private func constraintMinValueBinding(for key: NutrientKey) -> Binding<Double> {
        Binding(
            get: { viewModel.constraint(for: key)?.minValue ?? 0 },
            set: { viewModel.setConstraintMinValue($0, for: key) }
        )
    }

    private func constraintUseMaxBinding(for key: NutrientKey) -> Binding<Bool> {
        Binding(
            get: { viewModel.constraint(for: key)?.useMax ?? false },
            set: { viewModel.setConstraintUseMax($0, for: key) }
        )
    }

    private func constraintMaxValueBinding(for key: NutrientKey) -> Binding<Double> {
        Binding(
            get: { viewModel.constraint(for: key)?.maxValue ?? 0 },
            set: { viewModel.setConstraintMaxValue($0, for: key) }
        )
    }

    private func ingredientPriceBinding(for ingredientID: UUID) -> Binding<Double> {
        Binding(
            get: { viewModel.ingredients.first(where: { $0.id == ingredientID })?.pricePerKg ?? 0 },
            set: { viewModel.setIngredientPrice($0, for: ingredientID) }
        )
    }

    private func ingredientMinPercentBinding(for ingredientID: UUID) -> Binding<Double> {
        Binding(
            get: { viewModel.ingredients.first(where: { $0.id == ingredientID })?.minPercent ?? 0 },
            set: { viewModel.setIngredientMinPercent($0, for: ingredientID) }
        )
    }

    private func ingredientMaxPercentBinding(for ingredientID: UUID) -> Binding<Double> {
        Binding(
            get: { viewModel.ingredients.first(where: { $0.id == ingredientID })?.maxPercent ?? 0 },
            set: { viewModel.setIngredientMaxPercent($0, for: ingredientID) }
        )
    }

    private func nutrientValueBinding(for ingredientID: UUID, key: NutrientKey) -> Binding<Double> {
        Binding(
            get: { viewModel.nutrientValue(for: ingredientID, key: key) },
            set: { viewModel.setNutrientValue($0, for: ingredientID, key: key) }
        )
    }

    private func workbookNutrientBinding(for ingredientID: UUID, id: String) -> Binding<Double> {
        Binding(
            get: { viewModel.workbookNutrientValue(for: ingredientID, id: id) },
            set: { viewModel.setWorkbookNutrientValue($0, for: ingredientID, id: id) }
        )
    }

    private func workbookDisplayTitle(_ definition: WorkbookNutrientDefinition) -> String {
        if definition.unit.isEmpty {
            return definition.title
        }
        return "\(definition.title) (\(definition.unit))"
    }

    private func workbookFraction(_ definition: WorkbookNutrientDefinition) -> Int {
        switch definition.unit {
        case "kcal/kg", "mEq/kg":
            return 0
        default:
            return 3
        }
    }

    private func linkedNumeric(
        title: String,
        value: Binding<Double>,
        fraction: Int
    ) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.custom("AvenirNext-Regular", size: 11))
                .foregroundStyle(Palette.textMuted)
            TextField(
                "",
                value: value,
                format: .number.precision(.fractionLength(fraction))
            )
            .textFieldStyle(.plain)
            .inputChrome()
            .frame(width: 110)
            .multilineTextAlignment(.trailing)
        }
    }

    private func fullNutrientEditor(for ingredient: Ingredient) -> some View {
        let id = ingredient.id
        let columns = [GridItem(.flexible()), GridItem(.flexible())]
        return VStack(alignment: .leading, spacing: 8) {
            Text("Macro + Amino")
                .font(.custom("AvenirNext-DemiBold", size: 12))
                .foregroundStyle(Palette.textMuted)

            LazyVGrid(columns: columns, spacing: 10) {
                linkedNumeric(title: "ME (kcal/kg)", value: nutrientValueBinding(for: id, key: .metabolizableEnergy), fraction: 0)
                linkedNumeric(title: "Crude Protein %", value: nutrientValueBinding(for: id, key: .crudeProtein), fraction: 2)
                linkedNumeric(title: "Lysine %", value: nutrientValueBinding(for: id, key: .lysine), fraction: 3)
                linkedNumeric(title: "Methionine %", value: nutrientValueBinding(for: id, key: .methionine), fraction: 3)
                linkedNumeric(title: "Threonine %", value: nutrientValueBinding(for: id, key: .threonine), fraction: 3)
                linkedNumeric(title: "Calcium %", value: nutrientValueBinding(for: id, key: .calcium), fraction: 3)
                linkedNumeric(title: "Avail. P %", value: nutrientValueBinding(for: id, key: .availablePhosphorus), fraction: 3)
                linkedNumeric(title: "Sodium %", value: nutrientValueBinding(for: id, key: .sodium), fraction: 3)
                linkedNumeric(title: "Linoleic %", value: nutrientValueBinding(for: id, key: .linoleicAcid), fraction: 3)
            }

            Text("Vitamins")
                .font(.custom("AvenirNext-DemiBold", size: 12))
                .foregroundStyle(Palette.textMuted)

            LazyVGrid(columns: columns, spacing: 10) {
                linkedNumeric(title: "Vitamin A (IU/kg)", value: nutrientValueBinding(for: id, key: .vitaminA), fraction: 0)
                linkedNumeric(title: "Vitamin D3 (IU/kg)", value: nutrientValueBinding(for: id, key: .vitaminD3), fraction: 0)
                linkedNumeric(title: "Vitamin E (IU/kg)", value: nutrientValueBinding(for: id, key: .vitaminE), fraction: 0)
            }

            Text("Minerals")
                .font(.custom("AvenirNext-DemiBold", size: 12))
                .foregroundStyle(Palette.textMuted)

            LazyVGrid(columns: columns, spacing: 10) {
                linkedNumeric(title: "Manganese (mg/kg)", value: nutrientValueBinding(for: id, key: .manganese), fraction: 0)
                linkedNumeric(title: "Zinc (mg/kg)", value: nutrientValueBinding(for: id, key: .zinc), fraction: 0)
                linkedNumeric(title: "Copper (mg/kg)", value: nutrientValueBinding(for: id, key: .copper), fraction: 0)
                linkedNumeric(title: "Iron (mg/kg)", value: nutrientValueBinding(for: id, key: .iron), fraction: 0)
                linkedNumeric(title: "Selenium (mg/kg)", value: nutrientValueBinding(for: id, key: .selenium), fraction: 3)
            }

            Text("Workbook Data Bank")
                .font(.custom("AvenirNext-DemiBold", size: 12))
                .foregroundStyle(Palette.textMuted)

            ScrollView {
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(Ingredient.workbookExtraNutrientDefinitions) { definition in
                        linkedNumeric(
                            title: workbookDisplayTitle(definition),
                            value: workbookNutrientBinding(for: id, id: definition.id),
                            fraction: workbookFraction(definition)
                        )
                    }
                }
            }
            .frame(height: 240)
        }
    }

    private var operationsWorkspace: some View {
        ScrollView {
            VStack(spacing: 12) {
                SectionCard(
                    title: "Production Planning + Forecasting",
                    subtitle: "Plan demand, batches, and performance indicators for the selected day range.",
                    accent: Palette.ocean
                ) {
                    VStack(spacing: 10) {
                        HStack(spacing: 8) {
                            MetricCard(title: "Period Days", value: "\(viewModel.formulaPeriodDays)")
                            MetricCard(title: "Feed Demand", value: "\(String(format: "%.1f", viewModel.periodFeedDemandKg)) kg")
                            MetricCard(title: "Planned Batches", value: "\(String(format: "%.2f", viewModel.plannedBatchCount))")
                            MetricCard(title: "Inventory Alerts", value: "\(viewModel.inventoryAlertCount)")
                        }

                        HStack {
                            labeledNumeric(
                                title: "Expected Gain/Bird (kg)",
                                value: $viewModel.expectedWeightGainPerBirdKg,
                                fraction: 2
                            )
                            MetricCard(title: "Estimated FCR", value: "\(String(format: "%.3f", viewModel.estimatedFCR))")
                        }

                        HStack(spacing: 8) {
                            MetricCard(
                                title: "Feed Cost / Bird",
                                value: toman(viewModel.feedCostPerBirdInPeriod)
                            )
                            MetricCard(
                                title: "Sale Revenue / Bird",
                                value: toman(viewModel.salePricePerLiveKg * viewModel.expectedWeightGainPerBirdKg)
                            )
                            MetricCard(
                                title: "Gross Margin / Bird",
                                value: toman(viewModel.grossMarginPerBirdInPeriod)
                            )
                        }
                    }
                }

                SectionCard(
                    title: "Inventory Management (Feed Mill)",
                    subtitle: "Track on-hand stock, safety stock, and smart reorder recommendation per ingredient.",
                    accent: Palette.pine
                ) {
                    VStack(alignment: .leading, spacing: 8) {
                        InventoryHeaderRow()
                        ScrollView {
                            VStack(spacing: 7) {
                                ForEach(viewModel.selectedIngredients.prefix(80)) { ingredient in
                                    InventoryEditorRow(
                                        ingredientName: ingredient.name,
                                        group: ingredient.group.rawValue,
                                        dailyUsageKg: viewModel.dailyUsageKg(for: ingredient.id),
                                        daysCover: viewModel.daysCover(for: ingredient.id),
                                        reorderKg: viewModel.reorderRecommendationKg(for: ingredient.id),
                                        onHand: onHandBinding(for: ingredient.id),
                                        safety: safetyBinding(for: ingredient.id)
                                    )
                                }
                            }
                        }
                        .frame(height: 280)

                        HStack {
                            Text("Reorder alerts in current plan: \(viewModel.inventoryAlertCount)")
                                .font(.custom("AvenirNext-Medium", size: 12))
                                .foregroundStyle(Palette.textMuted)
                            Spacer()
                            Button("Use Core Set") {
                                viewModel.selectCoreTemplate()
                            }
                            .buttonStyle(SecondaryActionStyle())
                        }
                    }
                }

                SectionCard(
                    title: "MRP Auto Ordering",
                    subtitle: "Lead-time demand + safety stock based purchasing list with CSV export.",
                    accent: Palette.pine
                ) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 8) {
                            Stepper(
                                "Purchase Lead Time: \(viewModel.purchaseLeadTimeDays) days",
                                value: $viewModel.purchaseLeadTimeDays,
                                in: 1...90
                            )
                            .frame(maxWidth: .infinity, alignment: .leading)

                            Button("Generate MRP") {
                                viewModel.generateMRPOrders()
                            }
                            .buttonStyle(SecondaryActionStyle())

                            Button("Export MRP CSV") {
                                viewModel.exportMRPCSV()
                            }
                            .buttonStyle(SecondaryActionStyle())
                        }

                        MRPHeaderRow()
                        ScrollView {
                            VStack(spacing: 7) {
                                ForEach(viewModel.mrpOrderLines.prefix(80)) { line in
                                    MRPRow(line: line)
                                }
                            }
                        }
                        .frame(height: 250)
                    }
                }

                SectionCard(
                    title: "What-if Scenario Planning",
                    subtitle: "Simulate ingredient price shocks and compare cost impact before applying decisions.",
                    accent: Palette.amber
                ) {
                    VStack(spacing: 10) {
                        HStack(spacing: 8) {
                            Picker("Scenario Group", selection: $viewModel.scenarioGroup) {
                                ForEach(IngredientGroup.allCases) { group in
                                    Text(group.rawValue).tag(group)
                                }
                            }
                            .pickerStyle(.menu)
                            .frame(width: 220)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .fill(Palette.input)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .stroke(Palette.border, lineWidth: 1)
                            )

                            labeledNumeric(
                                title: "Price Change %",
                                value: $viewModel.scenarioPriceChangePercent,
                                fraction: 2
                            )

                            Button("Run Scenario") {
                                viewModel.runWhatIfScenario()
                            }
                            .buttonStyle(SecondaryActionStyle())
                            .disabled(viewModel.isScenarioRunning)
                        }

                        HStack(spacing: 8) {
                            MetricCard(
                                title: "Baseline Cost / kg",
                                value: toman(viewModel.solution?.costPerKg ?? 0)
                            )
                            MetricCard(
                                title: "Scenario Cost / kg",
                                value: toman(viewModel.scenarioSolution?.costPerKg ?? 0)
                            )
                            MetricCard(
                                title: "Delta / kg",
                                value: scenarioDeltaPerKgText
                            )
                        }

                        HStack {
                            Label(viewModel.scenarioMessage, systemImage: "waveform.path.ecg")
                                .font(.custom("AvenirNext-Medium", size: 12))
                                .foregroundStyle(Palette.textMuted)
                            Spacer()
                        }
                    }
                }

                SectionCard(
                    title: "Quality Control (QC)",
                    subtitle: "Data validations for formulation inputs, nutrient limits, and ingredient quality ranges.",
                    accent: Palette.coral
                ) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 8) {
                            MetricCard(title: "QC Alerts", value: "\(viewModel.qualityAlerts.count)")
                            MetricCard(title: "Critical", value: "\(viewModel.criticalQualityAlertCount)")
                        }

                        ScrollView {
                            VStack(spacing: 7) {
                                ForEach(viewModel.qualityAlerts) { alert in
                                    QualityAlertRow(alert: alert)
                                }
                            }
                        }
                        .frame(height: 210)
                    }
                }

                SectionCard(
                    title: "Open-source + Scientific Sources",
                    subtitle: "Quick links from your research list (Amino Feed, Sysnova/LibreFeed, MaxProfit, GreenFeeding).",
                    accent: Palette.coral
                ) {
                    VStack(alignment: .leading, spacing: 6) {
                        Link("MTech Systems (Amino Feed)", destination: URL(string: "https://mtechsystems.io")!)
                        Link("Amino Support", destination: URL(string: "https://aminosupport.mtech-systems.com")!)
                        Link("SysnovaFeed Win64", destination: URL(string: "https://github.com/sysnovaCTO/SysnovaFeed_Win64bit_V.9")!)
                        Link("SysnovaFeed Linux64", destination: URL(string: "https://github.com/sysnovaCTO/SysnovaFeed_Linux64bit_V.9")!)
                        Link("LibreFeed", destination: URL(string: "https://github.com/rifathim/LibreFeed")!)
                        Link("MaxProfitFeeding", destination: URL(string: "https://github.com/BlackNellore/MaxProfitFeeding")!)
                        Link("GreenFeeding", destination: URL(string: "https://github.com/BlackNellore/GreenFeeding")!)
                        Link("Pearson Square", destination: URL(string: "https://github.com/ecielam/pearson_square")!)
                        Link("Nature 2025 Many-Objective Paper", destination: URL(string: "https://www.nature.com/articles/s41598-025-96633-z")!)
                    }
                    .font(.custom("AvenirNext-Medium", size: 12))
                }
            }
            .padding(12)
        }
    }

    private var resultPanel: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Results + Constraint Checks")
                .font(.custom("AvenirNext-Bold", size: 24))
                .foregroundStyle(Palette.textPrimary)

            if let solution = viewModel.solution, !solution.allocations.isEmpty {
                SolutionBanner(solution: solution)

                HStack(spacing: 8) {
                    MetricCard(title: "Cost / kg", value: toman(solution.costPerKg))
                    MetricCard(title: "Objective / kg", value: toman(solution.objectivePerKg))
                    MetricCard(title: "Daily Feed", value: "\(String(format: "%.1f", viewModel.totalDailyFeedKg)) kg")
                    MetricCard(title: "Daily Cost", value: toman(viewModel.estimatedDailyCost))
                }

                HStack(spacing: 8) {
                    MetricCard(title: "Batch", value: "\(String(format: "%.0f", viewModel.batchSizeKg)) kg")
                    MetricCard(title: "Mode", value: solution.optimizationMode.rawValue)
                    MetricCard(title: "Feed Cost / Bird", value: toman(viewModel.feedCostPerBirdInPeriod))
                    MetricCard(title: "Gross Margin / Bird", value: toman(viewModel.grossMarginPerBirdInPeriod))
                }

                HStack(spacing: 8) {
                    MetricCard(title: "Met/Lys", value: "\(String(format: "%.2f", viewModel.metToLysRatioPercent))%")
                    MetricCard(title: "Thr/Lys", value: "\(String(format: "%.2f", viewModel.thrToLysRatioPercent))%")
                    MetricCard(title: "Price / Mcal", value: toman(viewModel.pricePerMcal))
                }

                GroupBox("Formula Output") {
                    ScrollView {
                        VStack(spacing: 8) {
                            ForEach(sortedAllocations) { allocation in
                                AllocationRow(
                                    allocation: allocation,
                                    batchSizeKg: viewModel.batchSizeKg
                                )
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .frame(maxHeight: 260)
                }
                .groupBoxStyle(DashboardGroupBoxStyle())

                GroupBox("Constraint Verification") {
                    ScrollView {
                        VStack(spacing: 8) {
                            ForEach(solution.assessments) { assessment in
                                NutrientAssessmentRow(assessment: assessment)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .frame(maxHeight: 300)
                }
                .groupBoxStyle(DashboardGroupBoxStyle())

                GroupBox("Export Output") {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Export clean reports for sharing and archives.")
                            .font(.custom("AvenirNext-Regular", size: 12))
                            .foregroundStyle(Palette.textMuted)

                        HStack(spacing: 8) {
                            Button {
                                viewModel.exportExcelReport()
                            } label: {
                                Label("Export Excel", systemImage: "tablecells")
                            }
                            .buttonStyle(SecondaryActionStyle())

                            Button {
                                viewModel.exportPDFReport()
                            } label: {
                                Label("Export PDF", systemImage: "doc.richtext")
                            }
                            .buttonStyle(SecondaryActionStyle())
                        }

                        Text("Excel export uses CSV format for maximum compatibility.")
                            .font(.custom("AvenirNext-Regular", size: 11))
                            .foregroundStyle(Palette.textMuted)
                    }
                    .padding(.vertical, 2)
                }
                .groupBoxStyle(DashboardGroupBoxStyle())

                if solution.status == .approximation {
                    Text("Maximum normalized violation: \(solution.maxViolationPercent, specifier: "%.2f")%")
                        .foregroundStyle(Palette.amber)
                        .font(.custom("AvenirNext-Medium", size: 13))
                }
            } else {
                Spacer()
                Text("No result yet. Configure Formula and Nutrients then run Calculate Formula.")
                    .foregroundStyle(Palette.textMuted)
                    .font(.custom("AvenirNext-Medium", size: 14))
                    .frame(maxWidth: .infinity, alignment: .center)
                Spacer()
            }
        }
        .padding(14)
        .frame(minWidth: 430, maxWidth: 510)
        .background(panelBackground)
    }

    private var scenarioDeltaPerKgText: String {
        guard let baseline = viewModel.solution?.costPerKg, let scenario = viewModel.scenarioSolution?.costPerKg else {
            return "0 Toman"
        }
        return toman(scenario - baseline)
    }

    private func toman(_ value: Double, decimals: Int = 0) -> String {
        "\(String(format: "%.\(decimals)f", value)) Toman"
    }

    private func onHandBinding(for ingredientID: UUID) -> Binding<Double> {
        Binding(
            get: { viewModel.onHandKg(for: ingredientID) },
            set: { viewModel.setOnHandKg($0, for: ingredientID) }
        )
    }

    private func safetyBinding(for ingredientID: UUID) -> Binding<Double> {
        Binding(
            get: { viewModel.safetyStockKg(for: ingredientID) },
            set: { viewModel.setSafetyStockKg($0, for: ingredientID) }
        )
    }

    private func labeledNumeric(
        title: String,
        value: Binding<Double>,
        fraction: Int
    ) -> some View {
        HStack {
            Text(title)
                .foregroundStyle(Palette.textMuted)
            Spacer()
            TextField(
                "",
                value: value,
                format: .number.precision(.fractionLength(fraction))
            )
            .textFieldStyle(.plain)
            .inputChrome()
            .frame(width: 130)
            .multilineTextAlignment(.trailing)
        }
    }

    private var panelBackground: some View {
        RoundedRectangle(cornerRadius: 20, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [Palette.panelTop, Palette.panelBottom],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(Palette.strongBorder, lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.34), radius: 14, y: 8)
    }
}
