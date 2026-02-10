import { IngredientGroup, NutrientKey, StrainType } from './enums';

export interface Ingredient {
  id: string;
  name: string;
  group: IngredientGroup;
  minPercent: number;
  maxPercent: number;
  pricePerKg: number;
  nutrients: {
    [NutrientKey.CRUDE_PROTEIN]: number;
    [NutrientKey.METABOLIZABLE_ENERGY]: number;
    [NutrientKey.LYSINE]: number;
    [NutrientKey.METHIONINE]: number;
    [NutrientKey.THREONINE]: number;
    [NutrientKey.CALCIUM]: number;
    [NutrientKey.AVAILABLE_PHOSPHORUS]: number;
    [NutrientKey.SODIUM]: number;
    [NutrientKey.LINOLEIC_ACID]: number;
  };
}

export interface BasicConstraint {
  key: NutrientKey;
  min: number | null;
  max: number | null;
}

export interface NutrientConstraint extends BasicConstraint {
  name: string;
  unit: string;
}

export interface StrainPresetData {
  strain: StrainType;
  phase: string;
  ageRange: string;
  constraints: BasicConstraint[];
}

export interface StrainPreset {
  strain: StrainType;
  phase: string;
  ageRange: string;
  constraints: NutrientConstraint[];
}

export interface IngredientResult {
  name: string;
  percentage: number;
}

export interface NutrientResult {
  name: string;
  value: number;
  unit: string;
  status: 'ok' | 'low' | 'high';
}

export interface FormulationResult {
  ingredients: IngredientResult[];
  nutrients: NutrientResult[];
  totalCost: number;
  status: 'feasible' | 'infeasible';
  message: string;
}

export interface AppState {
  selectedIngredients: Set<string>;
  constraints: NutrientConstraint[];
  selectedStrain: StrainType;
  result: FormulationResult | null;
  isDarkMode: boolean;
}
