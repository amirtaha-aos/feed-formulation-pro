import { Ingredient, NutrientConstraint, FormulationResult, IngredientResult, NutrientResult } from '../types';
import { calculateFormulaNutrients, calculateCost } from './calculations';

export function optimizeFormulation(
  selectedIngredients: Ingredient[],
  constraints: NutrientConstraint[]
): FormulationResult {
  if (selectedIngredients.length === 0) {
    return {
      ingredients: [],
      nutrients: [],
      totalCost: 0,
      status: 'infeasible',
      message: 'No ingredients selected'
    };
  }

  // Simple gradient descent optimization
  const maxIterations = 1000;
  const learningRate = 0.01;

  // Initialize with equal percentages
  let percentages = new Array(selectedIngredients.length).fill(100 / selectedIngredients.length);

  for (let iter = 0; iter < maxIterations; iter++) {
    // Calculate current nutrients
    const currentIngredients: { [id: string]: number } = {};
    selectedIngredients.forEach((ing, i) => {
      currentIngredients[ing.id] = percentages[i];
    });

    const nutrients = calculateFormulaNutrients(currentIngredients, selectedIngredients);

    // Calculate penalty for constraint violations
    let totalPenalty = 0;
    constraints.forEach(constraint => {
      const value = nutrients[constraint.key];
      if (constraint.min !== null && value < constraint.min) {
        totalPenalty += Math.pow(constraint.min - value, 2);
      }
      if (constraint.max !== null && value > constraint.max) {
        totalPenalty += Math.pow(value - constraint.max, 2);
      }
    });

    // Update percentages to reduce cost and penalty
    const gradient = new Array(selectedIngredients.length).fill(0);

    selectedIngredients.forEach((ing, i) => {
      gradient[i] = ing.pricePerKg + totalPenalty * 0.01;
    });

    // Apply gradient descent
    for (let i = 0; i < percentages.length; i++) {
      percentages[i] -= learningRate * gradient[i];
      percentages[i] = Math.max(selectedIngredients[i].minPercent,
                                 Math.min(selectedIngredients[i].maxPercent, percentages[i]));
    }

    // Normalize to sum to 100%
    const sum = percentages.reduce((a, b) => a + b, 0);
    percentages = percentages.map(p => (p / sum) * 100);
  }

  // Build final result
  const result: { [id: string]: number } = {};
  selectedIngredients.forEach((ing, i) => {
    if (percentages[i] > 0.01) {
      result[ing.id] = Math.round(percentages[i] * 100) / 100;
    }
  });

  const finalNutrients = calculateFormulaNutrients(result, selectedIngredients);
  const cost = calculateCost(result, selectedIngredients);

  // Check feasibility
  let feasible = true;
  const nutrientResults: NutrientResult[] = [];

  constraints.forEach(constraint => {
    const value = finalNutrients[constraint.key];
    let status: 'ok' | 'low' | 'high' = 'ok';

    if (constraint.min !== null && value < constraint.min * 0.95) {
      feasible = false;
      status = 'low';
    }
    if (constraint.max !== null && value > constraint.max * 1.05) {
      feasible = false;
      status = 'high';
    }

    nutrientResults.push({
      name: constraint.name,
      value: value,
      unit: constraint.unit,
      status: status
    });
  });

  // Build ingredient results
  const ingredientResults: IngredientResult[] = Object.entries(result)
    .map(([id, percentage]) => {
      const ing = selectedIngredients.find(i => i.id === id);
      return {
        name: ing?.name || id,
        percentage: percentage
      };
    })
    .filter(r => r.percentage > 0.01)
    .sort((a, b) => b.percentage - a.percentage);

  return {
    ingredients: ingredientResults,
    nutrients: nutrientResults,
    totalCost: cost,
    status: feasible ? 'feasible' : 'infeasible',
    message: feasible
      ? `Optimized formulation found with ${ingredientResults.length} ingredients`
      : 'Formulation approximated - some constraints may not be met exactly'
  };
}
