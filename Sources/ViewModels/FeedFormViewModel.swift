import Foundation
import SwiftUI
import AppKit
import UniformTypeIdentifiers

@MainActor
final class FeedFormViewModel: ObservableObject {
    private let tomanPerDollarBase = 100_000.0
    private let legacyDollarThreshold = 1_000.0

    @Published var formulaName = "House A Broiler Mix"
    @Published var dayFrom = 1
    @Published var dayTo = 35
    @Published var optimizationMode: OptimizationMode = .leastCost
    @Published var profitWeight = 0.16
    @Published var salePricePerLiveKg = 210_000.0
    @Published var birdType: BirdType = .broiler
    @Published var feedingGoal: FeedingGoal = .grower
    @Published var workbookPricePresetName: String
    @Published var ageInWeeks = 4
    @Published var flockSize = 1000
    @Published var dailyFeedPerBirdKg = 0.115
    @Published var batchSizeKg = 1000.0

    @Published var nutrientConstraints: [NutrientConstraint]
    @Published var ingredients: [Ingredient]
    @Published var enabledGroups: Set<IngredientGroup>

    @Published var solution: RationSolution?
    @Published var statusMessage = "Use Formula tab, set options, and run Calculate Formula."
    @Published var isCalculating = false

    @Published var savedDiets: [SavedDiet]
    @Published var selectedDietID: UUID?

    @Published var selectedPremixID: UUID?
    @Published var premixPercent = 0.50
    @Published var premixKg = 5.0
    @Published var selectedIngredientIDs: Set<UUID>
    @Published var inventoryByIngredient: [UUID: InventorySetting]
    @Published var purchaseLeadTimeDays = 7
    @Published var scenarioGroup: IngredientGroup = .grain
    @Published var scenarioPriceChangePercent = 8.0
    @Published var scenarioSolution: RationSolution?
    @Published var scenarioMessage = "Run What-if Scenario to compare baseline vs changed prices."
    @Published var isScenarioRunning = false
    @Published var expectedWeightGainPerBirdKg = 1.90

    private var calculationGeneration = 0
    private var scheduledCalculation: DispatchWorkItem?
    private var scheduledScenario: DispatchWorkItem?
    private let dietsFileURL: URL

    init() {
        dietsFileURL = Self.dietsStoreURL()
        workbookPricePresetName = Ingredient.defaultWorkbookPricePresetName
        nutrientConstraints = NutrientConstraint.presetFromDayRange(
            for: .broiler,
            goal: .grower,
            dayFrom: 1,
            dayTo: 35
        )
        ingredients = Self.convertIngredientPricesToToman(
            Ingredient.defaultLibrary,
            tomanPerDollarBase: 100_000.0,
            threshold: 1_000.0
        )
        enabledGroups = Set(IngredientGroup.allCases)
        selectedIngredientIDs = []
        inventoryByIngredient = [:]
        savedDiets = Self.loadSavedDiets(from: dietsFileURL)
            .map {
                Self.convertSavedDietPricesToToman(
                    $0,
                    tomanPerDollarBase: 100_000.0,
                    threshold: 1_000.0
                )
            }
        selectedDietID = nil
        selectedPremixID = ingredients.first(where: { $0.name.localizedCaseInsensitiveContains("Premix") })?.id
        selectedIngredientIDs = coreIngredientSelectionSet()
        seedInventoryIfNeeded()
        statusMessage = "Ready. Click Calculate Formula when you want to run optimization."
    }

    var minTotalPercent: Double {
        ingredients.reduce(0) { $0 + $1.minPercent }
    }

    var maxTotalPercent: Double {
        ingredients.reduce(0) { $0 + $1.maxPercent }
    }

    var totalDailyFeedKg: Double {
        Double(flockSize) * dailyFeedPerBirdKg
    }

    var estimatedDailyCost: Double {
        guard let solution else { return 0 }
        return solution.costPerKg * totalDailyFeedKg
    }

    var premixCandidates: [Ingredient] {
        ingredients.filter {
            $0.group == .supplementsAdditives && $0.name.localizedCaseInsensitiveContains("premix")
        }
    }

    var activeIngredientCount: Int {
        activeIngredientsForSolver().count
    }

    var selectedIngredientCount: Int {
        ingredients.filter { selectedIngredientIDs.contains($0.id) }.count
    }

    var selectedIngredients: [Ingredient] {
        ingredients
            .filter { selectedIngredientIDs.contains($0.id) }
            .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }

    var formulaPeriodDays: Int {
        max(1, dayTo - dayFrom + 1)
    }

    var periodFeedDemandKg: Double {
        totalDailyFeedKg * Double(formulaPeriodDays)
    }

    var plannedBatchCount: Double {
        guard batchSizeKg > 0 else { return 0 }
        return periodFeedDemandKg / batchSizeKg
    }

    var estimatedFCR: Double {
        let feedIntakePerBird = dailyFeedPerBirdKg * Double(formulaPeriodDays)
        guard expectedWeightGainPerBirdKg > 0 else { return 0 }
        return feedIntakePerBird / expectedWeightGainPerBirdKg
    }

    var feedCostPerBirdInPeriod: Double {
        guard let solution else { return 0 }
        let feedIntakePerBird = dailyFeedPerBirdKg * Double(formulaPeriodDays)
        return solution.costPerKg * feedIntakePerBird
    }

    var grossMarginPerBirdInPeriod: Double {
        let saleRevenue = salePricePerLiveKg * expectedWeightGainPerBirdKg
        return saleRevenue - feedCostPerBirdInPeriod
    }

    var metToLysRatioPercent: Double {
        let lys = achievedValue(for: .lysine)
        guard lys > 1e-9 else { return 0 }
        return (achievedValue(for: .methionine) / lys) * 100.0
    }

    var thrToLysRatioPercent: Double {
        let lys = achievedValue(for: .lysine)
        guard lys > 1e-9 else { return 0 }
        return (achievedValue(for: .threonine) / lys) * 100.0
    }

    var pricePerMcal: Double {
        let me = achievedValue(for: .metabolizableEnergy)
        guard me > 1e-9, let solution else { return 0 }
        return solution.costPerKg / (me / 1000.0)
    }

    var inventoryAlertCount: Int {
        selectedIngredients.filter { reorderRecommendationKg(for: $0.id) > 0.0001 }.count
    }

    var qualityAlerts: [QualityAlert] {
        var alerts: [QualityAlert] = []

        if dayFrom > dayTo {
            alerts.append(
                QualityAlert(
                    severity: .critical,
                    message: "Day From is greater than Day To."
                )
            )
        }

        if batchSizeKg <= 0 {
            alerts.append(
                QualityAlert(
                    severity: .critical,
                    message: "Batch Size must be greater than zero."
                )
            )
        }

        if minTotalPercent > 100.0001 {
            alerts.append(
                QualityAlert(
                    severity: .critical,
                    message: "Total ingredient minimum inclusion exceeds 100%."
                )
            )
        }

        if maxTotalPercent < 99.9999 {
            alerts.append(
                QualityAlert(
                    severity: .critical,
                    message: "Total ingredient maximum inclusion is below 100%."
                )
            )
        }

        if selectedIngredientCount < 2 {
            alerts.append(
                QualityAlert(
                    severity: .critical,
                    message: "At least two selected ingredients are required."
                )
            )
        }

        if nutrientConstraints.contains(where: { $0.useMin && $0.useMax && $0.minValue > $0.maxValue }) {
            alerts.append(
                QualityAlert(
                    severity: .critical,
                    message: "One or more nutrient constraints have Min greater than Max."
                )
            )
        }

        for ingredient in selectedIngredients {
            if ingredient.pricePerKg <= 0 {
                alerts.append(
                    QualityAlert(
                        severity: .warning,
                        message: "\(ingredient.name): price is zero or negative."
                    )
                )
            }

            if ingredient.minPercent > ingredient.maxPercent {
                alerts.append(
                    QualityAlert(
                        severity: .critical,
                        message: "\(ingredient.name): Min% is greater than Max%."
                    )
                )
            }

            if ingredient.maxPercent > 95 {
                alerts.append(
                    QualityAlert(
                        severity: .warning,
                        message: "\(ingredient.name): Max% over 95% may reduce formulation flexibility."
                    )
                )
            }

            if ingredient.metabolizableEnergy < 0 || ingredient.metabolizableEnergy > 9500 {
                alerts.append(
                    QualityAlert(
                        severity: .warning,
                        message: "\(ingredient.name): ME value appears out of range."
                    )
                )
            }
        }

        if alerts.isEmpty {
            alerts.append(QualityAlert(severity: .info, message: "QC checks passed. No data quality issues found."))
        }

        return alerts
    }

    var criticalQualityAlertCount: Int {
        qualityAlerts.filter { $0.severity == .critical }.count
    }

    var mrpOrderLines: [MRPOrderLine] {
        selectedIngredients.map { ingredient in
            let usage = dailyUsageKg(for: ingredient.id)
            let leadDemand = usage * Double(max(1, purchaseLeadTimeDays))
            let safety = safetyStockKg(for: ingredient.id)
            let onHand = onHandKg(for: ingredient.id)
            let reorder = max(0, leadDemand + safety - onHand)
            return MRPOrderLine(
                id: ingredient.id,
                ingredientName: ingredient.name,
                group: ingredient.group,
                dailyUsageKg: usage,
                leadDemandKg: leadDemand,
                safetyKg: safety,
                onHandKg: onHand,
                reorderKg: reorder,
                daysCover: daysCover(for: ingredient.id)
            )
        }
        .sorted { $0.reorderKg > $1.reorderKg }
    }

    func ingredients(in group: IngredientGroup) -> [Ingredient] {
        ingredients
            .filter { $0.group == group }
            .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }

    func onHandKg(for ingredientID: UUID) -> Double {
        inventoryByIngredient[ingredientID]?.onHandKg ?? 0
    }

    func safetyStockKg(for ingredientID: UUID) -> Double {
        inventoryByIngredient[ingredientID]?.safetyStockKg ?? 0
    }

    func setOnHandKg(_ value: Double, for ingredientID: UUID) {
        var row = inventoryByIngredient[ingredientID] ?? InventorySetting(onHandKg: 0, safetyStockKg: 0)
        row.onHandKg = max(0, value)
        inventoryByIngredient[ingredientID] = row
    }

    func setSafetyStockKg(_ value: Double, for ingredientID: UUID) {
        var row = inventoryByIngredient[ingredientID] ?? InventorySetting(onHandKg: 0, safetyStockKg: 0)
        row.safetyStockKg = max(0, value)
        inventoryByIngredient[ingredientID] = row
    }

    func dailyUsageKg(for ingredientID: UUID) -> Double {
        guard let solution else { return 0 }
        guard let allocation = solution.allocations.first(where: { $0.id == ingredientID }) else { return 0 }
        return (allocation.inclusionPercent / 100.0) * totalDailyFeedKg
    }

    func daysCover(for ingredientID: UUID) -> Double {
        let usage = dailyUsageKg(for: ingredientID)
        guard usage > 1e-9 else { return 0 }
        return onHandKg(for: ingredientID) / usage
    }

    func reorderRecommendationKg(for ingredientID: UUID) -> Double {
        let needed = dailyUsageKg(for: ingredientID) * Double(formulaPeriodDays) + safetyStockKg(for: ingredientID)
        return max(0, needed - onHandKg(for: ingredientID))
    }

    private func achievedValue(for key: NutrientKey) -> Double {
        solution?.assessments.first(where: { $0.key == key })?.achieved ?? 0
    }

    func constraint(for key: NutrientKey) -> NutrientConstraint? {
        nutrientConstraints.first(where: { $0.key == key })
    }

    func setConstraintUseMin(_ enabled: Bool, for key: NutrientKey) {
        guard let index = nutrientConstraints.firstIndex(where: { $0.key == key }) else { return }
        nutrientConstraints[index].useMin = enabled
        markDirty()
    }

    func setConstraintMinValue(_ value: Double, for key: NutrientKey) {
        guard let index = nutrientConstraints.firstIndex(where: { $0.key == key }) else { return }
        nutrientConstraints[index].minValue = max(0, value)
        markDirty()
    }

    func setConstraintUseMax(_ enabled: Bool, for key: NutrientKey) {
        guard let index = nutrientConstraints.firstIndex(where: { $0.key == key }) else { return }
        nutrientConstraints[index].useMax = enabled
        markDirty()
    }

    func setConstraintMaxValue(_ value: Double, for key: NutrientKey) {
        guard let index = nutrientConstraints.firstIndex(where: { $0.key == key }) else { return }
        nutrientConstraints[index].maxValue = max(0, value)
        markDirty()
    }

    func nutrientValue(for ingredientID: UUID, key: NutrientKey) -> Double {
        ingredients.first(where: { $0.id == ingredientID })?.value(for: key) ?? 0
    }

    func setNutrientValue(_ value: Double, for ingredientID: UUID, key: NutrientKey) {
        guard let index = ingredients.firstIndex(where: { $0.id == ingredientID }) else { return }
        let safe = max(0, value)
        switch key {
        case .crudeProtein: ingredients[index].crudeProtein = safe
        case .metabolizableEnergy: ingredients[index].metabolizableEnergy = safe
        case .lysine: ingredients[index].lysine = safe
        case .methionine: ingredients[index].methionine = safe
        case .threonine: ingredients[index].threonine = safe
        case .calcium: ingredients[index].calcium = safe
        case .availablePhosphorus: ingredients[index].availablePhosphorus = safe
        case .sodium: ingredients[index].sodium = safe
        case .linoleicAcid: ingredients[index].linoleicAcid = safe
        case .vitaminA: ingredients[index].vitaminA = safe
        case .vitaminD3: ingredients[index].vitaminD3 = safe
        case .vitaminE: ingredients[index].vitaminE = safe
        case .manganese: ingredients[index].manganese = safe
        case .zinc: ingredients[index].zinc = safe
        case .copper: ingredients[index].copper = safe
        case .iron: ingredients[index].iron = safe
        case .selenium: ingredients[index].selenium = safe
        }
        markDirty()
    }

    func workbookNutrientValue(for ingredientID: UUID, id: String) -> Double {
        guard let ingredient = ingredients.first(where: { $0.id == ingredientID }) else { return 0 }
        if let key = Ingredient.workbookCoreKeyMap[id] {
            return ingredient.value(for: key)
        }
        return ingredient.extraNutrients[id] ?? 0
    }

    func setWorkbookNutrientValue(_ value: Double, for ingredientID: UUID, id: String) {
        guard let index = ingredients.firstIndex(where: { $0.id == ingredientID }) else { return }
        let safe = max(0, value)
        if let key = Ingredient.workbookCoreKeyMap[id] {
            setNutrientValue(safe, for: ingredientID, key: key)
        } else {
            if safe == 0 {
                ingredients[index].extraNutrients.removeValue(forKey: id)
            } else {
                ingredients[index].extraNutrients[id] = safe
            }
            markDirty()
        }
    }

    func setIngredientPrice(_ value: Double, for ingredientID: UUID) {
        guard let index = ingredients.firstIndex(where: { $0.id == ingredientID }) else { return }
        ingredients[index].pricePerKg = max(0, value)
        markDirty()
    }

    func setIngredientMinPercent(_ value: Double, for ingredientID: UUID) {
        guard let index = ingredients.firstIndex(where: { $0.id == ingredientID }) else { return }
        ingredients[index].minPercent = max(0, min(100, value))
        markDirty()
    }

    func setIngredientMaxPercent(_ value: Double, for ingredientID: UUID) {
        guard let index = ingredients.firstIndex(where: { $0.id == ingredientID }) else { return }
        ingredients[index].maxPercent = max(0, min(100, value))
        markDirty()
    }

    func runWhatIfScenario() {
        let base = activeIngredientsForSolver()
        guard base.count >= 2 else {
            scenarioMessage = "Need at least two active ingredients before running scenario."
            scenarioSolution = nil
            return
        }

        scheduledScenario?.cancel()
        isScenarioRunning = true
        scenarioMessage = "Running scenario..."

        let constraintsSnapshot = nutrientConstraints
        let factor = max(0.0, 1.0 + (scenarioPriceChangePercent / 100.0))
        let updated = base.map { item -> Ingredient in
            guard item.group == scenarioGroup else { return item }
            var copy = item
            copy.pricePerKg *= factor
            return copy
        }

        scheduledScenario = scheduleRationSolve(
            ingredients: updated,
            constraints: constraintsSnapshot,
            mode: optimizationMode,
            profitWeight: profitWeight,
            delay: 0.0
        ) { [weak self] result in
            guard let self else { return }
            self.scenarioSolution = result
            self.isScenarioRunning = false
            if let baseline = self.solution {
                let delta = result.costPerKg - baseline.costPerKg
                let pct = baseline.costPerKg > 0 ? (delta / baseline.costPerKg * 100.0) : 0
                self.scenarioMessage = "Scenario complete. Cost delta: \(self.number(delta, 0)) Toman/kg (\(self.number(pct, 2))%)."
            } else {
                self.scenarioMessage = "Scenario complete."
            }
        }
    }

    func generateMRPOrders() {
        let lines = mrpOrderLines.filter { $0.reorderKg > 0.001 }
        if lines.isEmpty {
            statusMessage = "MRP check complete: no purchase orders required."
            return
        }
        let totalKg = lines.reduce(0.0) { $0 + $1.reorderKg }
        statusMessage = "MRP generated \(lines.count) purchase lines, total \(number(totalKg, 1)) kg to order."
    }

    @MainActor func exportMRPCSV() {
        let lines = mrpOrderLines
        guard !lines.isEmpty else {
            statusMessage = "No MRP data to export yet."
            return
        }

        guard let url = chooseExportURL(
            defaultName: "\(reportFileStem())-mrp.csv",
            fileExtension: "csv"
        ) else { return }

        var rows: [String] = []
        rows.append(csvRow(["Ingredient", "Group", "Daily Use kg", "Lead Demand kg", "Safety kg", "On Hand kg", "Reorder kg", "Days Cover"]))
        for line in lines {
            rows.append(
                csvRow([
                    line.ingredientName,
                    line.group.rawValue,
                    number(line.dailyUsageKg, 3),
                    number(line.leadDemandKg, 3),
                    number(line.safetyKg, 3),
                    number(line.onHandKg, 3),
                    number(line.reorderKg, 3),
                    number(line.daysCover, 2)
                ])
            )
        }

        do {
            try rows.joined(separator: "\n").write(to: url, atomically: true, encoding: .utf8)
            statusMessage = "MRP CSV saved: \(url.lastPathComponent)"
        } catch {
            statusMessage = "MRP export failed (\(error.localizedDescription))."
        }
    }

    func applyPreset() {
        nutrientConstraints = NutrientConstraint.presetFromDayRange(
            for: birdType,
            goal: feedingGoal,
            dayFrom: dayFrom,
            dayTo: dayTo
        )
        markDirty(message: "Workbook formulas applied (Dynamic Model + strain presets). Click Calculate Formula.")
    }

    func applyWorkbookPricePreset() {
        guard let preset = Ingredient.workbookPricePresets.first(where: { $0.name == workbookPricePresetName }) else {
            statusMessage = "Excel preset not found."
            return
        }
        ingredients = Ingredient.applyWorkbookPricePreset(preset, to: ingredients)
        markDirty(message: "Excel price preset applied. Click Calculate Formula.")
    }

    func enableMicronutrients() {
        let recommendations = NutrientConstraint.micronutrientMinimums()
        nutrientConstraints = nutrientConstraints.map { item in
            var copy = item
            if copy.key.group == .vitamin || copy.key.group == .mineral {
                copy.useMin = true
                copy.minValue = recommendations[copy.key] ?? max(copy.minValue, 0)
            }
            return copy
        }
        markDirty()
    }

    func resetProject() {
        formulaName = "House A Broiler Mix"
        dayFrom = 1
        dayTo = 35
        birdType = .broiler
        feedingGoal = .grower
        workbookPricePresetName = Ingredient.defaultWorkbookPricePresetName
        salePricePerLiveKg = 210_000.0
        ageInWeeks = 4
        flockSize = 1000
        dailyFeedPerBirdKg = 0.115
        batchSizeKg = 1000
        nutrientConstraints = NutrientConstraint.presetFromDayRange(
            for: .broiler,
            goal: .grower,
            dayFrom: 1,
            dayTo: 35
        )
        ingredients = Self.convertIngredientPricesToToman(
            Ingredient.defaultLibrary,
            tomanPerDollarBase: tomanPerDollarBase,
            threshold: legacyDollarThreshold
        )
        enabledGroups = Set(IngredientGroup.allCases)
        selectedIngredientIDs = coreIngredientSelectionSet()
        seedInventoryIfNeeded()
        selectedDietID = nil
        selectedPremixID = ingredients.first(where: { $0.name.localizedCaseInsensitiveContains("Premix") })?.id
        premixPercent = 0.50
        premixKg = 5.0
        markDirty()
    }

    func addIngredient() {
        let newIngredient = Ingredient(
            name: "New Ingredient",
            group: .userFeed,
            minPercent: 0,
            maxPercent: 10,
            pricePerKg: 20_000,
            crudeProtein: 0,
            metabolizableEnergy: 0,
            lysine: 0,
            methionine: 0,
            threonine: 0,
            calcium: 0,
            availablePhosphorus: 0,
            sodium: 0,
            linoleicAcid: 0,
            vitaminA: 0,
            vitaminD3: 0,
            vitaminE: 0,
            manganese: 0,
            zinc: 0,
            copper: 0,
            iron: 0,
            selenium: 0
        )
        ingredients.append(
            newIngredient
        )
        selectedIngredientIDs.insert(newIngredient.id)
        seedInventoryIfNeeded()
        markDirty()
    }

    func removeIngredient(id: UUID) {
        ingredients.removeAll { $0.id == id }
        selectedIngredientIDs.remove(id)
        inventoryByIngredient.removeValue(forKey: id)
        if selectedPremixID == id {
            selectedPremixID = premixCandidates.first?.id
        }
        markDirty()
    }

    func toggleGroup(_ group: IngredientGroup) {
        if enabledGroups.contains(group) {
            enabledGroups.remove(group)
        } else {
            enabledGroups.insert(group)
        }
        markDirty()
    }

    func saveCurrentDiet() {
        let cleanName = formulaName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanName.isEmpty else {
            statusMessage = "Formula Name is empty; cannot save diet."
            return
        }

        let snapshot = SavedDiet(
            id: selectedDietID ?? UUID(),
            name: cleanName,
            birdType: birdType,
            feedingGoal: feedingGoal,
            ageInWeeks: ageInWeeks,
            flockSize: flockSize,
            dailyFeedPerBirdKg: dailyFeedPerBirdKg,
            batchSizeKg: batchSizeKg,
            constraints: nutrientConstraints,
            ingredients: ingredients,
            enabledGroups: Array(enabledGroups)
        )

        if let index = savedDiets.firstIndex(where: { $0.id == snapshot.id }) {
            savedDiets[index] = snapshot
            statusMessage = "Diet updated in Existing Diets."
        } else {
            savedDiets.append(snapshot)
            statusMessage = "Diet saved to Existing Diets."
        }

        selectedDietID = snapshot.id
        persistSavedDiets()
    }

    func loadSelectedDiet() {
        guard
            let selectedDietID,
            let diet = savedDiets.first(where: { $0.id == selectedDietID })
        else {
            statusMessage = "Choose a diet from Existing Diets first."
            return
        }

        formulaName = diet.name
        birdType = diet.birdType
        feedingGoal = diet.feedingGoal
        ageInWeeks = diet.ageInWeeks
        flockSize = diet.flockSize
        dailyFeedPerBirdKg = diet.dailyFeedPerBirdKg
        batchSizeKg = diet.batchSizeKg
        nutrientConstraints = diet.constraints
        ingredients = Self.convertIngredientPricesToToman(
            diet.ingredients,
            tomanPerDollarBase: tomanPerDollarBase,
            threshold: legacyDollarThreshold
        )
        enabledGroups = Set(diet.enabledGroups)
        selectedIngredientIDs = coreIngredientSelectionSet()
        seedInventoryIfNeeded()
        selectedPremixID = premixCandidates.first?.id
        markDirty()
        statusMessage = "Diet loaded from Existing Diets."
    }

    func deleteSelectedDiet() {
        guard let selectedDietID else {
            statusMessage = "No selected diet to delete."
            return
        }

        savedDiets.removeAll { $0.id == selectedDietID }
        self.selectedDietID = nil
        statusMessage = "Selected diet deleted."
        persistSavedDiets()
    }

    func convertPremixPercentToKg() {
        premixKg = batchSizeKg * premixPercent / 100.0
    }

    func convertPremixKgToPercent() {
        guard batchSizeKg > 0 else {
            statusMessage = "Batch size must be greater than zero for conversion."
            return
        }
        premixPercent = premixKg / batchSizeKg * 100.0
    }

    func applyPremixToFormula() {
        guard
            let selectedPremixID,
            let index = ingredients.firstIndex(where: { $0.id == selectedPremixID })
        else {
            statusMessage = "Select a premix ingredient first."
            return
        }

        ingredients[index].minPercent = premixPercent
        ingredients[index].maxPercent = max(ingredients[index].maxPercent, premixPercent)
        statusMessage = "Premix converted and applied as minimum inclusion in formula."
        markDirty()
    }

    func setIngredientSelection(_ ingredientID: UUID, isOn: Bool) {
        if isOn {
            selectedIngredientIDs.insert(ingredientID)
        } else {
            selectedIngredientIDs.remove(ingredientID)
        }
        markDirty()
    }

    func clearSelectedIngredients() {
        selectedIngredientIDs.removeAll()
        markDirty()
    }

    func selectAllIngredients(in group: IngredientGroup) {
        for item in ingredients where item.group == group {
            selectedIngredientIDs.insert(item.id)
        }
        markDirty()
    }

    func clearSelectedIngredients(in group: IngredientGroup) {
        for item in ingredients where item.group == group {
            selectedIngredientIDs.remove(item.id)
        }
        markDirty()
    }

    func selectCoreTemplate() {
        selectedIngredientIDs = coreIngredientSelectionSet()
        markDirty()
    }

    private func coreIngredientSelectionSet() -> Set<UUID> {
        let keywords = [
            "corn",
            "wheat",
            "soybean",
            "fish meal",
            "oil",
            "limestone",
            "dicalcium",
            "salt",
            "premix"
        ]
        var selected = Set(
            ingredients.compactMap { item in
                let normalized = item.name.lowercased()
                return keywords.contains(where: { normalized.contains($0) }) ? item.id : nil
            }
        )
        if selected.count < 2 {
            selected = Set(ingredients.prefix(8).map(\.id))
        }
        return selected
    }

    private func seedInventoryIfNeeded() {
        var rebuilt: [UUID: InventorySetting] = [:]
        for ingredient in ingredients {
            let existing = inventoryByIngredient[ingredient.id]
            rebuilt[ingredient.id] =
                existing
                ?? InventorySetting(
                    onHandKg: max(250, batchSizeKg * 1.8),
                    safetyStockKg: max(100, batchSizeKg * 0.35)
                )
        }
        inventoryByIngredient = rebuilt
    }

    func calculateFormula() {
        requestCalculation(immediate: true, force: true)
    }

    func requestCalculation(immediate: Bool = false, force: Bool = false) {
        guard force else {
            markDirty()
            return
        }
        scheduledCalculation?.cancel()
        scheduledScenario?.cancel()
        scenarioSolution = nil
        scenarioMessage = "Run What-if Scenario to compare baseline vs changed prices."
        isScenarioRunning = false

        calculationGeneration += 1
        let generation = calculationGeneration

        let activeIngredients = activeIngredientsForSolver()

        guard activeIngredients.count >= 2 else {
            statusMessage = "At least two active ingredients are required (check group toggles and names)."
            solution = nil
            isCalculating = false
            return
        }

        if activeIngredients.contains(where: { $0.minPercent > $0.maxPercent }) {
            statusMessage = "Ingredient Min% cannot be greater than Max%."
            solution = nil
            isCalculating = false
            return
        }

        if nutrientConstraints.contains(where: { $0.useMin && $0.useMax && $0.minValue > $0.maxValue }) {
            statusMessage = "Some nutrient constraints have Min > Max."
            solution = nil
            isCalculating = false
            return
        }

        isCalculating = true
        if !immediate {
            statusMessage = "Recalculating formula..."
        }

        let delay = immediate ? 0.0 : 0.22
        let constraintsSnapshot = nutrientConstraints
        scheduledCalculation = scheduleRationSolve(
            ingredients: activeIngredients,
            constraints: constraintsSnapshot,
            mode: optimizationMode,
            profitWeight: profitWeight,
            delay: delay
        ) { [weak self] result in
            guard let self else { return }
            guard generation == self.calculationGeneration else { return }
            self.solution = result
            self.statusMessage = result.message
            self.isCalculating = false
        }
    }

    private func markDirty(message: String = "Changes saved. Click Calculate Formula to run.") {
        scheduledCalculation?.cancel()
        scheduledScenario?.cancel()
        scenarioSolution = nil
        scenarioMessage = "Run What-if Scenario to compare baseline vs changed prices."
        isScenarioRunning = false
        calculationGeneration += 1
        isCalculating = false
        statusMessage = message
    }

    @MainActor func exportExcelReport() {
        guard let solution else {
            statusMessage = "No computed formula to export. Run Calculate Formula first."
            return
        }

        guard let url = chooseExportURL(
            defaultName: "\(reportFileStem())-report.csv",
            fileExtension: "csv"
        ) else { return }

        let csv = buildCSVReport(solution: solution)
        do {
            try csv.write(to: url, atomically: true, encoding: .utf8)
            statusMessage = "Excel export saved: \(url.lastPathComponent)"
        } catch {
            statusMessage = "Excel export failed (\(error.localizedDescription))."
        }
    }

    @MainActor func exportPDFReport() {
        guard let solution else {
            statusMessage = "No computed formula to export. Run Calculate Formula first."
            return
        }

        guard let url = chooseExportURL(
            defaultName: "\(reportFileStem())-report.pdf",
            fileExtension: "pdf"
        ) else { return }

        let document = buildPDFReportDocument(solution: solution)
        let renderer = PDFReportRenderer(document: document)
        let pdfData = renderer.dataWithPDF(inside: renderer.bounds)
        do {
            try pdfData.write(to: url, options: .atomic)
            statusMessage = "PDF export saved: \(url.lastPathComponent)"
        } catch {
            statusMessage = "PDF export failed (\(error.localizedDescription))."
        }
    }

    private func activeIngredientsForSolver() -> [Ingredient] {
        ingredients
            .filter { enabledGroups.contains($0.group) }
            .filter { selectedIngredientIDs.contains($0.id) }
            .map { item in
                var copy = item
                copy.name = item.name.trimmingCharacters(in: .whitespacesAndNewlines)
                return copy
            }
            .filter { !$0.name.isEmpty }
    }

    @MainActor private func chooseExportURL(defaultName: String, fileExtension: String) -> URL? {
        let panel = NSSavePanel()
        panel.canCreateDirectories = true
        panel.nameFieldStringValue = defaultName
        if fileExtension.lowercased() == "pdf" {
            panel.allowedContentTypes = [.pdf]
        } else {
            panel.allowedContentTypes = [.commaSeparatedText]
        }
        panel.isExtensionHidden = false
        panel.canSelectHiddenExtension = true

        guard panel.runModal() == .OK, var url = panel.url else { return nil }
        if url.pathExtension.lowercased() != fileExtension.lowercased() {
            url.deletePathExtension()
            url.appendPathExtension(fileExtension)
        }
        return url
    }

    private func reportFileStem() -> String {
        let cleanName = formulaName
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: " ", with: "_")
        return cleanName.isEmpty ? "formula" : cleanName
    }

    private func buildCSVReport(solution: RationSolution) -> String {
        var lines: [String] = []
        let now = Self.timestampFormatter.string(from: Date())
        let qualitySummary = qualityAlerts
            .filter { $0.severity != .info }
            .prefix(3)
            .map(\.message)
            .joined(separator: " | ")
        lines.append(csvRow([
            "P.H.D khaleghi formula - Formula Report",
            now
        ]))
        lines.append(csvRow(["Report ID", shortReportID()]))
        lines.append(csvRow(["Formula Day Range", "Day \(dayFrom) to \(dayTo)"]))
        lines.append(csvRow(["Formula Name", formulaName]))
        lines.append(csvRow(["Bird Type", birdType.rawValue]))
        lines.append(csvRow(["Feeding Goal", feedingGoal.rawValue]))
        lines.append(csvRow(["Optimization Mode", solution.optimizationMode.rawValue]))
        lines.append(csvRow(["Default Operator", "Nutrition Team"]))
        lines.append(csvRow(["Default Facility", "Feed Mill A"]))
        lines.append(csvRow(["Currency", "Iranian Toman (IRT)"]))
        lines.append(csvRow(["Batch Size (kg)", number(batchSizeKg, 0)]))
        lines.append(csvRow(["Price per kg (Toman)", number(solution.costPerKg, 0)]))
        lines.append(csvRow(["Objective per kg (Toman)", number(solution.objectivePerKg, 0)]))
        lines.append(csvRow(["Estimated FCR", number(estimatedFCR, 3)]))
        lines.append(csvRow(["Met/Lys Ratio (%)", number(metToLysRatioPercent, 2)]))
        lines.append(csvRow(["Thr/Lys Ratio (%)", number(thrToLysRatioPercent, 2)]))
        lines.append(csvRow(["Price per Mcal (Toman)", number(pricePerMcal, 0)]))
        lines.append(csvRow(["Feed Cost per Bird (Toman)", number(feedCostPerBirdInPeriod, 0)]))
        lines.append(csvRow(["Gross Margin per Bird (Toman)", number(grossMarginPerBirdInPeriod, 0)]))
        lines.append(csvRow(["Quality Summary", qualitySummary.isEmpty ? "QC checks passed" : qualitySummary]))
        lines.append("")

        lines.append("Formula Output")
        lines.append(csvRow(["Ingredient", "Group", "Inclusion %", "Batch kg", "Cost/kg share (Toman)"]))
        for allocation in solution.allocations
            .filter({ $0.inclusionPercent > 0.03 })
            .sorted(by: { $0.inclusionPercent > $1.inclusionPercent })
        {
            lines.append(csvRow([
                allocation.name,
                allocation.group.rawValue,
                number(allocation.inclusionPercent, 3),
                number((allocation.inclusionPercent / 100.0) * batchSizeKg, 3),
                number(allocation.costContributionPerKg, 0)
            ]))
        }

        lines.append("")
        lines.append("Constraint Verification")
        lines.append(csvRow(["Nutrient", "Achieved", "Unit", "Min Target", "Max Target", "Status"]))
        for assessment in solution.assessments {
            lines.append(csvRow([
                assessment.key.title,
                number(assessment.achieved, assessment.key.decimals),
                assessment.key.unit,
                assessment.minTarget.map { number($0, assessment.key.decimals) } ?? "-",
                assessment.maxTarget.map { number($0, assessment.key.decimals) } ?? "-",
                assessment.isGood ? "PASS" : "OUT OF RANGE"
            ]))
        }

        return lines.joined(separator: "\n")
    }

    private func buildPDFReportDocument(solution: RationSolution) -> PDFReportDocument {
        let rows = solution.allocations
            .filter { $0.inclusionPercent > 0.03 }
            .sorted { $0.inclusionPercent > $1.inclusionPercent }
            .prefix(18)
            .map { allocation in
                PDFIngredientRow(
                    name: allocation.name,
                    group: allocation.group.rawValue,
                    inclusionPercent: allocation.inclusionPercent,
                    batchKg: (allocation.inclusionPercent / 100.0) * batchSizeKg,
                    costSharePerKg: allocation.costContributionPerKg
                )
            }

        let constraints = solution.assessments.map { assessment in
            PDFConstraintRow(
                nutrient: assessment.key.title,
                achieved: "\(number(assessment.achieved, assessment.key.decimals)) \(assessment.key.unit)",
                minTarget: assessment.minTarget.map { number($0, assessment.key.decimals) } ?? "-",
                maxTarget: assessment.maxTarget.map { number($0, assessment.key.decimals) } ?? "-",
                status: assessment.isGood ? "PASS" : "OUT"
            )
        }

        let warningSummary = qualityAlerts
            .filter { $0.severity != .info }
            .prefix(3)
            .map(\.message)
            .joined(separator: " | ")

        let pageHeight: CGFloat = max(
            1080,
            860 + CGFloat(rows.count) * 24 + CGFloat(constraints.count) * 21
        )

        return PDFReportDocument(
            reportTitle: "P.H.D khaleghi formula",
            reportSubtitle: "Formulation & Optimization Report",
            generatedAt: Self.timestampFormatter.string(from: Date()),
            reportID: shortReportID(),
            formulaName: formulaName,
            dayRange: "Day \(dayFrom) to \(dayTo)",
            birdType: birdType.rawValue,
            feedingGoal: feedingGoal.rawValue,
            optimizationMode: solution.optimizationMode.rawValue,
            operatorName: "Nutrition Team",
            facilityName: "Feed Mill A",
            currency: "Iranian Toman (IRT)",
            statusText: solution.message,
            qualitySummary: warningSummary.isEmpty ? "QC checks passed" : warningSummary,
            batchSizeKg: batchSizeKg,
            costPerKg: solution.costPerKg,
            objectivePerKg: solution.objectivePerKg,
            dailyFeedKg: totalDailyFeedKg,
            dailyCost: estimatedDailyCost,
            metToLysRatioPercent: metToLysRatioPercent,
            thrToLysRatioPercent: thrToLysRatioPercent,
            pricePerMcal: pricePerMcal,
            feedCostPerBird: feedCostPerBirdInPeriod,
            grossMarginPerBird: grossMarginPerBirdInPeriod,
            estimatedFCR: estimatedFCR,
            ingredientRows: Array(rows),
            chartRows: Array(rows.prefix(8)),
            constraintRows: constraints,
            pageHeight: pageHeight
        )
    }

    private func csvRow(_ values: [String]) -> String {
        values.map(csvEscaped).joined(separator: ",")
    }

    private func csvEscaped(_ value: String) -> String {
        let escaped = value.replacingOccurrences(of: "\"", with: "\"\"")
        return "\"\(escaped)\""
    }

    private func number(_ value: Double, _ decimals: Int) -> String {
        String(format: "%.\(decimals)f", value)
    }

    private func shortReportID() -> String {
        "RPT-\(UUID().uuidString.prefix(8).uppercased())"
    }

    private static let timestampFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }()

    private static func convertIngredientPricesToToman(
        _ ingredients: [Ingredient],
        tomanPerDollarBase: Double,
        threshold: Double
    ) -> [Ingredient] {
        ingredients.map { ingredient in
            var copy = ingredient
            if copy.pricePerKg > 0, copy.pricePerKg < threshold {
                copy.pricePerKg *= tomanPerDollarBase
            }
            return copy
        }
    }

    private static func convertSavedDietPricesToToman(
        _ diet: SavedDiet,
        tomanPerDollarBase: Double,
        threshold: Double
    ) -> SavedDiet {
        var copy = diet
        copy.ingredients = convertIngredientPricesToToman(
            copy.ingredients,
            tomanPerDollarBase: tomanPerDollarBase,
            threshold: threshold
        )
        return copy
    }

    private func scheduleRationSolve(
        ingredients: [Ingredient],
        constraints: [NutrientConstraint],
        mode: OptimizationMode,
        profitWeight: Double,
        delay: TimeInterval,
        completion: @MainActor @escaping @Sendable (RationSolution) -> Void
    ) -> DispatchWorkItem {
        let item = DispatchWorkItem {
            let result = RationSolver.solve(
                ingredients: ingredients,
                constraints: constraints,
                mode: mode,
                profitWeight: profitWeight
            )
            Task { @MainActor in
                completion(result)
            }
        }

        DispatchQueue.global(qos: .userInitiated)
            .asyncAfter(deadline: .now() + delay, execute: item)
        return item
    }

    private static func dietsStoreURL() -> URL {
        let fileManager = FileManager.default
        let baseURL =
            fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        let appFolder = baseURL.appendingPathComponent("PhdKhaleghiFormola", isDirectory: true)
        try? fileManager.createDirectory(
            at: appFolder,
            withIntermediateDirectories: true,
            attributes: nil
        )
        return appFolder.appendingPathComponent("saved_diets.json")
    }

    private static func loadSavedDiets(from url: URL) -> [SavedDiet] {
        guard let data = try? Data(contentsOf: url) else { return [] }
        let decoder = JSONDecoder()
        return (try? decoder.decode([SavedDiet].self, from: data)) ?? []
    }

    private func persistSavedDiets() {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        guard let data = try? encoder.encode(savedDiets) else { return }
        do {
            try data.write(to: dietsFileURL, options: .atomic)
        } catch {
            statusMessage = "Could not write diets to disk (\(error.localizedDescription))."
        }
    }
}

private struct PDFIngredientRow {
    let name: String
    let group: String
    let inclusionPercent: Double
    let batchKg: Double
    let costSharePerKg: Double
}

private struct PDFConstraintRow {
    let nutrient: String
    let achieved: String
    let minTarget: String
    let maxTarget: String
    let status: String
}

private struct PDFReportDocument {
    let reportTitle: String
    let reportSubtitle: String
    let generatedAt: String
    let reportID: String
    let formulaName: String
    let dayRange: String
    let birdType: String
    let feedingGoal: String
    let optimizationMode: String
    let operatorName: String
    let facilityName: String
    let currency: String
    let statusText: String
    let qualitySummary: String
    let batchSizeKg: Double
    let costPerKg: Double
    let objectivePerKg: Double
    let dailyFeedKg: Double
    let dailyCost: Double
    let metToLysRatioPercent: Double
    let thrToLysRatioPercent: Double
    let pricePerMcal: Double
    let feedCostPerBird: Double
    let grossMarginPerBird: Double
    let estimatedFCR: Double
    let ingredientRows: [PDFIngredientRow]
    let chartRows: [PDFIngredientRow]
    let constraintRows: [PDFConstraintRow]
    let pageHeight: CGFloat
}

private final class PDFReportRenderer: NSView {
    private let document: PDFReportDocument

    override var isFlipped: Bool { true }

    init(document: PDFReportDocument) {
        self.document = document
        super.init(frame: NSRect(x: 0, y: 0, width: 840, height: document.pageHeight))
        wantsLayer = true
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ dirtyRect: NSRect) {
        NSColor.white.setFill()
        bounds.fill()

        let margin: CGFloat = 34
        let contentWidth = bounds.width - (margin * 2)
        var y: CGFloat = 0

        y = drawHeader(margin: margin, contentWidth: contentWidth)
        y = drawInfoBlock(y: y, margin: margin, contentWidth: contentWidth)
        y = drawMetricCards(y: y, margin: margin, contentWidth: contentWidth)
        y = drawInclusionChart(y: y, margin: margin, contentWidth: contentWidth)
        y = drawIngredientTable(y: y, margin: margin, contentWidth: contentWidth)
        y = drawConstraintTable(y: y, margin: margin, contentWidth: contentWidth)
        drawFooter(y: y, margin: margin, contentWidth: contentWidth)
    }

    private func drawHeader(margin: CGFloat, contentWidth: CGFloat) -> CGFloat {
        let headerRect = NSRect(x: 0, y: 0, width: bounds.width, height: 116)
        let gradient = NSGradient(
            colors: [
                NSColor(calibratedRed: 0.12, green: 0.22, blue: 0.42, alpha: 1),
                NSColor(calibratedRed: 0.11, green: 0.46, blue: 0.58, alpha: 1)
            ]
        )
        gradient?.draw(in: headerRect, angle: 0)

        drawText(
            document.reportTitle,
            in: NSRect(x: margin, y: 20, width: contentWidth * 0.62, height: 34),
            font: .systemFont(ofSize: 28, weight: .bold),
            color: .white
        )
        drawText(
            document.reportSubtitle,
            in: NSRect(x: margin, y: 56, width: contentWidth * 0.62, height: 24),
            font: .systemFont(ofSize: 13, weight: .medium),
            color: NSColor.white.withAlphaComponent(0.92)
        )

        drawText(
            "Generated: \(document.generatedAt)",
            in: NSRect(x: margin + contentWidth * 0.62, y: 28, width: contentWidth * 0.38, height: 20),
            font: .systemFont(ofSize: 11, weight: .medium),
            color: NSColor.white.withAlphaComponent(0.95),
            alignment: .right
        )
        drawText(
            "Report ID: \(document.reportID)",
            in: NSRect(x: margin + contentWidth * 0.62, y: 50, width: contentWidth * 0.38, height: 20),
            font: .systemFont(ofSize: 11, weight: .medium),
            color: NSColor.white.withAlphaComponent(0.95),
            alignment: .right
        )
        drawText(
            "Status: \(document.statusText)",
            in: NSRect(x: margin + contentWidth * 0.62, y: 72, width: contentWidth * 0.38, height: 26),
            font: .systemFont(ofSize: 10, weight: .regular),
            color: NSColor.white.withAlphaComponent(0.90),
            alignment: .right
        )

        return headerRect.maxY + 16
    }

    private func drawInfoBlock(y: CGFloat, margin: CGFloat, contentWidth: CGFloat) -> CGFloat {
        let rect = NSRect(x: margin, y: y, width: contentWidth, height: 178)
        drawRoundedCard(rect, fill: NSColor(calibratedWhite: 0.97, alpha: 1), stroke: NSColor(calibratedWhite: 0.86, alpha: 1))

        let leftLines: [(String, String)] = [
            ("Formula Name", document.formulaName),
            ("Day Range", document.dayRange),
            ("Bird Type", document.birdType),
            ("Feeding Goal", document.feedingGoal),
            ("Optimizer", document.optimizationMode)
        ]
        let rightLines: [(String, String)] = [
            ("Operator", document.operatorName),
            ("Facility", document.facilityName),
            ("Currency", document.currency),
            ("Quality", document.qualitySummary),
            ("Met/Lys", "\(number(document.metToLysRatioPercent, decimals: 2))%"),
            ("Thr/Lys", "\(number(document.thrToLysRatioPercent, decimals: 2))%"),
            ("FCR (Est.)", number(document.estimatedFCR, decimals: 3))
        ]

        var leftY = rect.minY + 14
        for line in leftLines {
            drawInfoLine(key: line.0, value: line.1, x: rect.minX + 14, y: leftY, width: rect.width * 0.48)
            leftY += 26
        }

        var rightY = rect.minY + 14
        for line in rightLines {
            drawInfoLine(key: line.0, value: line.1, x: rect.minX + rect.width * 0.50, y: rightY, width: rect.width * 0.48)
            rightY += 26
        }

        return rect.maxY + 16
    }

    private func drawMetricCards(y: CGFloat, margin: CGFloat, contentWidth: CGFloat) -> CGFloat {
        let spacing: CGFloat = 10
        let cardWidth = (contentWidth - (spacing * 3)) / 4
        let height: CGFloat = 88
        let cards: [(String, String, NSColor)] = [
            ("Batch Size", "\(number(document.batchSizeKg, decimals: 0)) kg", NSColor(calibratedRed: 0.10, green: 0.47, blue: 0.63, alpha: 1)),
            ("Price / kg", toman(document.costPerKg), NSColor(calibratedRed: 0.08, green: 0.60, blue: 0.40, alpha: 1)),
            ("Objective / kg", toman(document.objectivePerKg), NSColor(calibratedRed: 0.85, green: 0.57, blue: 0.15, alpha: 1)),
            ("Gross Margin / Bird", toman(document.grossMarginPerBird), NSColor(calibratedRed: 0.75, green: 0.24, blue: 0.27, alpha: 1))
        ]

        for (index, card) in cards.enumerated() {
            let x = margin + CGFloat(index) * (cardWidth + spacing)
            let rect = NSRect(x: x, y: y, width: cardWidth, height: height)
            drawRoundedCard(rect, fill: NSColor(calibratedWhite: 0.985, alpha: 1), stroke: NSColor(calibratedWhite: 0.88, alpha: 1))
            let accentRect = NSRect(x: rect.minX, y: rect.minY, width: rect.width, height: 4)
            card.2.setFill()
            accentRect.fill()

            drawText(
                card.0,
                in: NSRect(x: rect.minX + 10, y: rect.minY + 16, width: rect.width - 20, height: 18),
                font: .systemFont(ofSize: 11, weight: .medium),
                color: NSColor(calibratedWhite: 0.30, alpha: 1)
            )
            drawText(
                card.1,
                in: NSRect(x: rect.minX + 10, y: rect.minY + 36, width: rect.width - 20, height: 30),
                font: .systemFont(ofSize: 20, weight: .bold),
                color: NSColor(calibratedWhite: 0.14, alpha: 1)
            )
        }

        drawText(
            "Daily Feed: \(number(document.dailyFeedKg, decimals: 1)) kg   |   Daily Cost: \(toman(document.dailyCost))   |   Feed Cost/Bird: \(toman(document.feedCostPerBird))   |   Price/Mcal: \(toman(document.pricePerMcal))",
            in: NSRect(x: margin, y: y + height + 8, width: contentWidth, height: 18),
            font: .systemFont(ofSize: 11, weight: .medium),
            color: NSColor(calibratedWhite: 0.32, alpha: 1)
        )

        return y + height + 32
    }

    private func drawInclusionChart(y: CGFloat, margin: CGFloat, contentWidth: CGFloat) -> CGFloat {
        let rect = NSRect(x: margin, y: y, width: contentWidth, height: 252)
        drawRoundedCard(rect, fill: NSColor(calibratedWhite: 0.985, alpha: 1), stroke: NSColor(calibratedWhite: 0.87, alpha: 1))

        drawText(
            "Top Ingredient Inclusion Chart (%)",
            in: NSRect(x: rect.minX + 12, y: rect.minY + 10, width: rect.width - 24, height: 22),
            font: .systemFont(ofSize: 15, weight: .semibold),
            color: NSColor(calibratedWhite: 0.16, alpha: 1)
        )

        guard !document.chartRows.isEmpty else {
            drawText(
                "No chart data available.",
                in: NSRect(x: rect.minX + 12, y: rect.minY + 44, width: rect.width - 24, height: 24),
                font: .systemFont(ofSize: 12, weight: .medium),
                color: NSColor(calibratedWhite: 0.42, alpha: 1)
            )
            return rect.maxY + 16
        }

        let labelWidth: CGFloat = 176
        let barStartX = rect.minX + 18 + labelWidth
        let barMaxWidth = rect.width - labelWidth - 130
        let maxValue = max(document.chartRows.map(\.inclusionPercent).max() ?? 1, 0.001)

        for (index, row) in document.chartRows.enumerated() {
            let lineY = rect.minY + 44 + CGFloat(index) * 24
            drawText(
                row.name,
                in: NSRect(x: rect.minX + 14, y: lineY + 1, width: labelWidth - 6, height: 18),
                font: .systemFont(ofSize: 11, weight: .medium),
                color: NSColor(calibratedWhite: 0.20, alpha: 1)
            )

            let width = CGFloat(row.inclusionPercent / maxValue) * barMaxWidth
            let barRect = NSRect(x: barStartX, y: lineY + 2, width: width, height: 14)
            let barColor = index.isMultiple(of: 2)
                ? NSColor(calibratedRed: 0.12, green: 0.53, blue: 0.69, alpha: 1)
                : NSColor(calibratedRed: 0.12, green: 0.62, blue: 0.41, alpha: 1)
            drawRoundedCard(barRect, fill: barColor, stroke: barColor)

            drawText(
                "\(number(row.inclusionPercent, decimals: 2))%",
                in: NSRect(x: barStartX + barMaxWidth + 10, y: lineY, width: 72, height: 18),
                font: .monospacedDigitSystemFont(ofSize: 11, weight: .semibold),
                color: NSColor(calibratedWhite: 0.16, alpha: 1),
                alignment: .right
            )
        }

        return rect.maxY + 16
    }

    private func drawIngredientTable(y: CGFloat, margin: CGFloat, contentWidth: CGFloat) -> CGFloat {
        let titleRect = NSRect(x: margin, y: y, width: contentWidth, height: 20)
        drawText(
            "Formula Output Table",
            in: titleRect,
            font: .systemFont(ofSize: 15, weight: .semibold),
            color: NSColor(calibratedWhite: 0.16, alpha: 1)
        )

        let columns: [CGFloat] = [250, 118, 90, 100, 120]
        let headerHeight: CGFloat = 28
        let rowHeight: CGFloat = 23
        let tableY = y + 24
        let tableHeight = headerHeight + (CGFloat(document.ingredientRows.count) * rowHeight)
        let tableRect = NSRect(x: margin, y: tableY, width: contentWidth, height: tableHeight)

        drawRoundedCard(tableRect, fill: NSColor(calibratedWhite: 0.985, alpha: 1), stroke: NSColor(calibratedWhite: 0.87, alpha: 1))

        let headerRect = NSRect(x: tableRect.minX, y: tableRect.minY, width: tableRect.width, height: headerHeight)
        NSColor(calibratedRed: 0.13, green: 0.23, blue: 0.42, alpha: 1).setFill()
        headerRect.fill()

        let headers = ["Ingredient", "Group", "Inclusion %", "Batch kg", "Cost Share Tmn/kg"]
        var x = tableRect.minX
        for (index, title) in headers.enumerated() {
            let width = columns[index]
            drawText(
                title,
                in: NSRect(x: x + 6, y: headerRect.minY + 6, width: width - 12, height: 16),
                font: .systemFont(ofSize: 11, weight: .semibold),
                color: .white,
                alignment: index >= 2 ? .right : .left
            )
            x += width
        }

        for (index, row) in document.ingredientRows.enumerated() {
            let rowRect = NSRect(
                x: tableRect.minX,
                y: tableRect.minY + headerHeight + CGFloat(index) * rowHeight,
                width: tableRect.width,
                height: rowHeight
            )
            if index.isMultiple(of: 2) {
                NSColor(calibratedWhite: 0.965, alpha: 1).setFill()
                rowRect.fill()
            }

            let cells = [
                row.name,
                row.group,
                "\(number(row.inclusionPercent, decimals: 3))",
                "\(number(row.batchKg, decimals: 3))",
                "\(number(row.costSharePerKg, decimals: 0))"
            ]

            var colX = rowRect.minX
            for (cellIndex, cell) in cells.enumerated() {
                let width = columns[cellIndex]
                drawText(
                    cell,
                    in: NSRect(x: colX + 6, y: rowRect.minY + 5, width: width - 12, height: 14),
                    font: .systemFont(ofSize: 11, weight: .regular),
                    color: NSColor(calibratedWhite: 0.16, alpha: 1),
                    alignment: cellIndex >= 2 ? .right : .left
                )
                colX += width
            }
        }

        return tableRect.maxY + 18
    }

    private func drawConstraintTable(y: CGFloat, margin: CGFloat, contentWidth: CGFloat) -> CGFloat {
        let titleRect = NSRect(x: margin, y: y, width: contentWidth, height: 20)
        drawText(
            "Constraint Verification",
            in: titleRect,
            font: .systemFont(ofSize: 15, weight: .semibold),
            color: NSColor(calibratedWhite: 0.16, alpha: 1)
        )

        let columns: [CGFloat] = [250, 160, 100, 100, 84]
        let headerHeight: CGFloat = 28
        let rowHeight: CGFloat = 22
        let tableY = y + 24
        let tableHeight = headerHeight + (CGFloat(document.constraintRows.count) * rowHeight)
        let tableRect = NSRect(x: margin, y: tableY, width: contentWidth, height: tableHeight)

        drawRoundedCard(tableRect, fill: NSColor(calibratedWhite: 0.985, alpha: 1), stroke: NSColor(calibratedWhite: 0.87, alpha: 1))

        let headerRect = NSRect(x: tableRect.minX, y: tableRect.minY, width: tableRect.width, height: headerHeight)
        NSColor(calibratedRed: 0.16, green: 0.36, blue: 0.30, alpha: 1).setFill()
        headerRect.fill()

        let headers = ["Nutrient", "Achieved", "Min", "Max", "Status"]
        var x = tableRect.minX
        for (index, title) in headers.enumerated() {
            let width = columns[index]
            drawText(
                title,
                in: NSRect(x: x + 6, y: headerRect.minY + 6, width: width - 12, height: 16),
                font: .systemFont(ofSize: 11, weight: .semibold),
                color: .white,
                alignment: index >= 1 ? .right : .left
            )
            x += width
        }

        for (index, row) in document.constraintRows.enumerated() {
            let rowRect = NSRect(
                x: tableRect.minX,
                y: tableRect.minY + headerHeight + CGFloat(index) * rowHeight,
                width: tableRect.width,
                height: rowHeight
            )
            if index.isMultiple(of: 2) {
                NSColor(calibratedWhite: 0.965, alpha: 1).setFill()
                rowRect.fill()
            }

            let statusColor = row.status == "PASS"
                ? NSColor(calibratedRed: 0.10, green: 0.55, blue: 0.32, alpha: 1)
                : NSColor(calibratedRed: 0.72, green: 0.25, blue: 0.28, alpha: 1)

            let cells = [row.nutrient, row.achieved, row.minTarget, row.maxTarget, row.status]
            var colX = rowRect.minX
            for (cellIndex, cell) in cells.enumerated() {
                let width = columns[cellIndex]
                drawText(
                    cell,
                    in: NSRect(x: colX + 6, y: rowRect.minY + 4, width: width - 12, height: 15),
                    font: .systemFont(ofSize: 11, weight: cellIndex == 4 ? .semibold : .regular),
                    color: cellIndex == 4 ? statusColor : NSColor(calibratedWhite: 0.16, alpha: 1),
                    alignment: cellIndex >= 1 ? .right : .left
                )
                colX += width
            }
        }

        return tableRect.maxY + 18
    }

    private func drawFooter(y: CGFloat, margin: CGFloat, contentWidth: CGFloat) {
        let lineY = min(bounds.height - 26, y + 6)
        NSColor(calibratedWhite: 0.82, alpha: 1).setStroke()
        let line = NSBezierPath()
        line.move(to: NSPoint(x: margin, y: lineY))
        line.line(to: NSPoint(x: margin + contentWidth, y: lineY))
        line.lineWidth = 1
        line.stroke()

        drawText(
            "Generated by P.H.D khaleghi formula | Default Profile: Nutrition Team / Feed Mill A",
            in: NSRect(x: margin, y: lineY + 6, width: contentWidth, height: 18),
            font: .systemFont(ofSize: 10, weight: .regular),
            color: NSColor(calibratedWhite: 0.42, alpha: 1)
        )
    }

    private func drawInfoLine(key: String, value: String, x: CGFloat, y: CGFloat, width: CGFloat) {
        drawText(
            "\(key):",
            in: NSRect(x: x, y: y, width: width * 0.36, height: 18),
            font: .systemFont(ofSize: 11, weight: .semibold),
            color: NSColor(calibratedWhite: 0.28, alpha: 1)
        )
        drawText(
            value,
            in: NSRect(x: x + width * 0.36, y: y, width: width * 0.64, height: 18),
            font: .systemFont(ofSize: 11, weight: .regular),
            color: NSColor(calibratedWhite: 0.16, alpha: 1)
        )
    }

    private func drawRoundedCard(_ rect: NSRect, fill: NSColor, stroke: NSColor) {
        let path = NSBezierPath(roundedRect: rect, xRadius: 10, yRadius: 10)
        fill.setFill()
        path.fill()
        stroke.setStroke()
        path.lineWidth = 1
        path.stroke()
    }

    private func drawText(
        _ text: String,
        in rect: NSRect,
        font: NSFont,
        color: NSColor,
        alignment: NSTextAlignment = .left
    ) {
        let style = NSMutableParagraphStyle()
        style.alignment = alignment
        style.lineBreakMode = .byTruncatingTail
        let attrs: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: color,
            .paragraphStyle: style
        ]
        (text as NSString).draw(in: rect, withAttributes: attrs)
    }

    private func number(_ value: Double, decimals: Int) -> String {
        String(format: "%.\(decimals)f", value)
    }

    private func toman(_ value: Double, decimals: Int = 0) -> String {
        "\(number(value, decimals: decimals)) Toman"
    }
}
