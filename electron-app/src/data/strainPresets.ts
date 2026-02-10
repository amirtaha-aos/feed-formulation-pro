import { StrainPresetData, StrainPreset, StrainType, NutrientKey } from '../types';
import { enrichConstraints } from '../utils/nutrientHelpers';

const STRAIN_PRESETS_DATA: Record<StrainType, StrainPresetData[]> = {
  [StrainType.ROSS]: [
    {
      strain: StrainType.ROSS,
      phase: 'Starter',
      ageRange: '0-10 days',
      constraints: [
        { key: NutrientKey.METABOLIZABLE_ENERGY, min: 2950, max: 3050 },
        { key: NutrientKey.CRUDE_PROTEIN, min: 22.0, max: 23.5 },
        { key: NutrientKey.LYSINE, min: 1.28, max: null },
        { key: NutrientKey.METHIONINE, min: 0.51, max: null },
        { key: NutrientKey.THREONINE, min: 0.86, max: null },
        { key: NutrientKey.CALCIUM, min: 0.96, max: 1.05 },
        { key: NutrientKey.AVAILABLE_PHOSPHORUS, min: 0.48, max: 0.52 }
      ]
    },
    {
      strain: StrainType.ROSS,
      phase: 'Grower',
      ageRange: '11-24 days',
      constraints: [
        { key: NutrientKey.METABOLIZABLE_ENERGY, min: 3050, max: 3150 },
        { key: NutrientKey.CRUDE_PROTEIN, min: 20.0, max: 21.5 },
        { key: NutrientKey.LYSINE, min: 1.15, max: null },
        { key: NutrientKey.METHIONINE, min: 0.46, max: null },
        { key: NutrientKey.THREONINE, min: 0.77, max: null },
        { key: NutrientKey.CALCIUM, min: 0.87, max: 0.96 },
        { key: NutrientKey.AVAILABLE_PHOSPHORUS, min: 0.44, max: 0.48 }
      ]
    },
    {
      strain: StrainType.ROSS,
      phase: 'Finisher',
      ageRange: '25+ days',
      constraints: [
        { key: NutrientKey.METABOLIZABLE_ENERGY, min: 3150, max: 3250 },
        { key: NutrientKey.CRUDE_PROTEIN, min: 18.0, max: 19.5 },
        { key: NutrientKey.LYSINE, min: 1.03, max: null },
        { key: NutrientKey.METHIONINE, min: 0.41, max: null },
        { key: NutrientKey.THREONINE, min: 0.69, max: null },
        { key: NutrientKey.CALCIUM, min: 0.78, max: 0.87 },
        { key: NutrientKey.AVAILABLE_PHOSPHORUS, min: 0.39, max: 0.43 }
      ]
    }
  ],
  
  [StrainType.COBB]: [
    {
      strain: StrainType.COBB,
      phase: 'Starter',
      ageRange: '0-10 days',
      constraints: [
        { key: NutrientKey.METABOLIZABLE_ENERGY, min: 2900, max: 3000 },
        { key: NutrientKey.CRUDE_PROTEIN, min: 21.5, max: 23.0 },
        { key: NutrientKey.LYSINE, min: 1.26, max: null },
        { key: NutrientKey.METHIONINE, min: 0.50, max: null },
        { key: NutrientKey.THREONINE, min: 0.84, max: null },
        { key: NutrientKey.CALCIUM, min: 0.90, max: 1.00 },
        { key: NutrientKey.AVAILABLE_PHOSPHORUS, min: 0.45, max: 0.50 }
      ]
    }
  ],

  [StrainType.AVIAGEN]: [
    {
      strain: StrainType.AVIAGEN,
      phase: 'Starter',
      ageRange: '0-10 days',
      constraints: [
        { key: NutrientKey.METABOLIZABLE_ENERGY, min: 2950, max: 3050 },
        { key: NutrientKey.CRUDE_PROTEIN, min: 22.0, max: 23.5 },
        { key: NutrientKey.LYSINE, min: 1.30, max: null },
        { key: NutrientKey.METHIONINE, min: 0.52, max: null },
        { key: NutrientKey.THREONINE, min: 0.87, max: null },
        { key: NutrientKey.CALCIUM, min: 0.96, max: 1.05 },
        { key: NutrientKey.AVAILABLE_PHOSPHORUS, min: 0.48, max: 0.52 }
      ]
    }
  ],

  [StrainType.AMINO_CHICK]: [
    {
      strain: StrainType.AMINO_CHICK,
      phase: 'Starter',
      ageRange: '0-10 days',
      constraints: [
        { key: NutrientKey.METABOLIZABLE_ENERGY, min: 2900, max: 3000 },
        { key: NutrientKey.CRUDE_PROTEIN, min: 21.0, max: 22.5 },
        { key: NutrientKey.LYSINE, min: 1.24, max: null },
        { key: NutrientKey.METHIONINE, min: 0.49, max: null },
        { key: NutrientKey.THREONINE, min: 0.83, max: null },
        { key: NutrientKey.CALCIUM, min: 0.90, max: 1.00 },
        { key: NutrientKey.AVAILABLE_PHOSPHORUS, min: 0.45, max: 0.50 }
      ]
    }
  ],

  [StrainType.DYNAMIC]: [
    {
      strain: StrainType.DYNAMIC,
      phase: 'Custom',
      ageRange: 'Age-based',
      constraints: [
        { key: NutrientKey.METABOLIZABLE_ENERGY, min: 2900, max: 3200 },
        { key: NutrientKey.CRUDE_PROTEIN, min: 18.0, max: 24.0 },
        { key: NutrientKey.LYSINE, min: 1.00, max: 1.35 },
        { key: NutrientKey.METHIONINE, min: 0.40, max: 0.54 },
        { key: NutrientKey.THREONINE, min: 0.65, max: 0.90 },
        { key: NutrientKey.CALCIUM, min: 0.75, max: 1.10 },
        { key: NutrientKey.AVAILABLE_PHOSPHORUS, min: 0.35, max: 0.55 }
      ]
    }
  ]
};

// Convert basic data to enriched presets
export const STRAIN_PRESETS: Record<StrainType, StrainPreset[]> = Object.entries(STRAIN_PRESETS_DATA).reduce((acc, [strain, presets]) => {
  acc[strain as StrainType] = presets.map(preset => ({
    ...preset,
    constraints: enrichConstraints(preset.constraints)
  }));
  return acc;
}, {} as Record<StrainType, StrainPreset[]>);

export function getStrainPreset(strain: StrainType, phase: string = 'Starter'): StrainPreset {
  const presets = STRAIN_PRESETS[strain];
  return presets.find((p: StrainPreset) => p.phase === phase) || presets[0];
}
