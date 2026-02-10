// SID (Standardized Ileal Digestible) amino acid digestibility coefficients
export const SID_DIGESTIBILITY = {
  corn: { lysine: 0.60, methionine: 0.88, threonine: 0.66 },
  wheat: { lysine: 0.70, methionine: 0.85, threonine: 0.70 },
  barley: { lysine: 0.72, methionine: 0.83, threonine: 0.68 },
  soybean_meal: { lysine: 0.91, methionine: 0.90, threonine: 0.87 },
  sunflower_meal: { lysine: 0.75, methionine: 0.86, threonine: 0.78 },
  canola_meal: { lysine: 0.79, methionine: 0.88, threonine: 0.77 },
  fish_meal: { lysine: 0.93, methionine: 0.94, threonine: 0.90 },
  meat_bone_meal: { lysine: 0.80, methionine: 0.85, threonine: 0.75 },
  poultry_meal: { lysine: 0.85, methionine: 0.88, threonine: 0.82 }
};

export function getSIDCoefficient(
  ingredientId: string,
  aminoAcid: 'lysine' | 'methionine' | 'threonine'
): number {
  return SID_DIGESTIBILITY[ingredientId as keyof typeof SID_DIGESTIBILITY]?.[aminoAcid] || 0.80;
}
