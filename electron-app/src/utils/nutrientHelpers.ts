import { NutrientKey, NutrientConstraint } from '../types';

export interface BasicConstraint {
  key: NutrientKey;
  min: number | null;
  max: number | null;
}

const NUTRIENT_INFO: Record<NutrientKey, { name: string; unit: string }> = {
  [NutrientKey.CRUDE_PROTEIN]: { name: 'Crude Protein', unit: '%' },
  [NutrientKey.METABOLIZABLE_ENERGY]: { name: 'Metabolizable Energy', unit: 'kcal/kg' },
  [NutrientKey.LYSINE]: { name: 'Lysine (SID)', unit: '%' },
  [NutrientKey.METHIONINE]: { name: 'Methionine (SID)', unit: '%' },
  [NutrientKey.THREONINE]: { name: 'Threonine (SID)', unit: '%' },
  [NutrientKey.CALCIUM]: { name: 'Calcium', unit: '%' },
  [NutrientKey.AVAILABLE_PHOSPHORUS]: { name: 'Available Phosphorus', unit: '%' },
  [NutrientKey.SODIUM]: { name: 'Sodium', unit: '%' },
  [NutrientKey.LINOLEIC_ACID]: { name: 'Linoleic Acid', unit: '%' },
};

export function enrichConstraint(basic: BasicConstraint): NutrientConstraint {
  const info = NUTRIENT_INFO[basic.key];
  return {
    ...basic,
    name: info.name,
    unit: info.unit,
  };
}

export function enrichConstraints(basics: BasicConstraint[]): NutrientConstraint[] {
  return basics.map(enrichConstraint);
}
