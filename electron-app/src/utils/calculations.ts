import { Ingredient, NutrientKey } from '../types';

export function calculateWPSAEnergy(ingredient: Ingredient): number {
  const CP = ingredient.nutrients[NutrientKey.CRUDE_PROTEIN];
  const EE = 3.0; // Assumed ether extract
  const CF = 2.5; // Assumed crude fiber
  const NFE = 100 - CP - EE - CF - 5.0; // Nitrogen-free extract

  // WPSA AMEn formula
  const AMEn = 37.13 * CP + 81.68 * EE + 35.56 * NFE - 12.82 * CF - 8.22 * CP;
  
  return Math.round(AMEn);
}

export function calculateFormulaNutrients(
  ingredients: { [id: string]: number },
  ingredientDatabase: Ingredient[]
): { [key in NutrientKey]: number } {
  const nutrients = {} as { [key in NutrientKey]: number };
  
  // Initialize all nutrients to 0
  Object.values(NutrientKey).forEach(key => {
    nutrients[key] = 0;
  });

  // Calculate weighted sum
  Object.entries(ingredients).forEach(([id, percentage]) => {
    const ingredient = ingredientDatabase.find(ing => ing.id === id);
    if (ingredient) {
      Object.entries(ingredient.nutrients).forEach(([key, value]) => {
        nutrients[key as NutrientKey] += value * (percentage / 100);
      });
    }
  });

  return nutrients;
}

export function calculateCost(
  ingredients: { [id: string]: number },
  ingredientDatabase: Ingredient[]
): number {
  let totalCost = 0;
  
  Object.entries(ingredients).forEach(([id, percentage]) => {
    const ingredient = ingredientDatabase.find(ing => ing.id === id);
    if (ingredient) {
      totalCost += ingredient.pricePerKg * (percentage / 100);
    }
  });

  return totalCost;
}
