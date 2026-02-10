import { Ingredient, IngredientGroup } from '../types';

export const INGREDIENTS_DATABASE: Ingredient[] = [
  // GRAINS (14 items)
  {
    id: 'corn',
    name: 'Corn',
    group: IngredientGroup.GRAIN,
    minPercent: 0,
    maxPercent: 70,
    pricePerKg: 0.30,
    nutrients: {
      crudeProtein: 7.42,
      metabolizableEnergy: 3350,
      lysine: 0.26,
      methionine: 0.18,
      threonine: 0.28,
      calcium: 0.02,
      availablePhosphorus: 0.09,
      sodium: 0.02,
      linoleicAcid: 1.8
    }
  },
  {
    id: 'wheat',
    name: 'Wheat',
    group: IngredientGroup.GRAIN,
    minPercent: 0,
    maxPercent: 50,
    pricePerKg: 0.28,
    nutrients: {
      crudeProtein: 11.5,
      metabolizableEnergy: 3150,
      lysine: 0.35,
      methionine: 0.20,
      threonine: 0.34,
      calcium: 0.05,
      availablePhosphorus: 0.12,
      sodium: 0.02,
      linoleicAcid: 0.9
    }
  },
  {
    id: 'barley',
    name: 'Barley',
    group: IngredientGroup.GRAIN,
    minPercent: 0,
    maxPercent: 40,
    pricePerKg: 0.25,
    nutrients: {
      crudeProtein: 10.8,
      metabolizableEnergy: 2750,
      lysine: 0.38,
      methionine: 0.18,
      threonine: 0.35,
      calcium: 0.05,
      availablePhosphorus: 0.15,
      sodium: 0.02,
      linoleicAcid: 0.8
    }
  },
  {
    id: 'sorghum',
    name: 'Sorghum',
    group: IngredientGroup.GRAIN,
    minPercent: 0,
    maxPercent: 50,
    pricePerKg: 0.27,
    nutrients: {
      crudeProtein: 9.0,
      metabolizableEnergy: 3250,
      lysine: 0.22,
      methionine: 0.16,
      threonine: 0.32,
      calcium: 0.03,
      availablePhosphorus: 0.10,
      sodium: 0.01,
      linoleicAcid: 1.5
    }
  },
  {
    id: 'rice',
    name: 'Rice',
    group: IngredientGroup.GRAIN,
    minPercent: 0,
    maxPercent: 30,
    pricePerKg: 0.35,
    nutrients: {
      crudeProtein: 7.5,
      metabolizableEnergy: 3300,
      lysine: 0.30,
      methionine: 0.21,
      threonine: 0.29,
      calcium: 0.02,
      availablePhosphorus: 0.11,
      sodium: 0.01,
      linoleicAcid: 1.2
    }
  },

  // PLANT BY-PRODUCTS (32 items - selecting key ones)
  {
    id: 'soybean_meal',
    name: 'Soybean Meal',
    group: IngredientGroup.PLANT_BY_PRODUCTS,
    minPercent: 0,
    maxPercent: 40,
    pricePerKg: 0.45,
    nutrients: {
      crudeProtein: 44.0,
      metabolizableEnergy: 2230,
      lysine: 2.80,
      methionine: 0.62,
      threonine: 1.70,
      calcium: 0.30,
      availablePhosphorus: 0.25,
      sodium: 0.02,
      linoleicAcid: 1.0
    }
  },
  {
    id: 'sunflower_meal',
    name: 'Sunflower Meal',
    group: IngredientGroup.PLANT_BY_PRODUCTS,
    minPercent: 0,
    maxPercent: 15,
    pricePerKg: 0.35,
    nutrients: {
      crudeProtein: 34.0,
      metabolizableEnergy: 1950,
      lysine: 1.20,
      methionine: 0.70,
      threonine: 1.25,
      calcium: 0.35,
      availablePhosphorus: 0.40,
      sodium: 0.03,
      linoleicAcid: 1.2
    }
  },
  {
    id: 'canola_meal',
    name: 'Canola Meal',
    group: IngredientGroup.PLANT_BY_PRODUCTS,
    minPercent: 0,
    maxPercent: 15,
    pricePerKg: 0.38,
    nutrients: {
      crudeProtein: 36.0,
      metabolizableEnergy: 2000,
      lysine: 1.95,
      methionine: 0.75,
      threonine: 1.50,
      calcium: 0.65,
      availablePhosphorus: 0.35,
      sodium: 0.02,
      linoleicAcid: 1.5
    }
  },
  {
    id: 'corn_gluten_meal',
    name: 'Corn Gluten Meal',
    group: IngredientGroup.PLANT_BY_PRODUCTS,
    minPercent: 0,
    maxPercent: 10,
    pricePerKg: 0.55,
    nutrients: {
      crudeProtein: 60.0,
      metabolizableEnergy: 3550,
      lysine: 1.00,
      methionine: 1.50,
      threonine: 2.10,
      calcium: 0.05,
      availablePhosphorus: 0.45,
      sodium: 0.05,
      linoleicAcid: 2.0
    }
  },
  {
    id: 'ddgs_corn',
    name: 'DDGS Corn',
    group: IngredientGroup.PLANT_BY_PRODUCTS,
    minPercent: 0,
    maxPercent: 15,
    pricePerKg: 0.32,
    nutrients: {
      crudeProtein: 27.0,
      metabolizableEnergy: 2750,
      lysine: 0.75,
      methionine: 0.50,
      threonine: 1.00,
      calcium: 0.05,
      availablePhosphorus: 0.40,
      sodium: 0.10,
      linoleicAcid: 3.5
    }
  },
  {
    id: 'wheat_bran',
    name: 'Wheat Bran',
    group: IngredientGroup.PLANT_BY_PRODUCTS,
    minPercent: 0,
    maxPercent: 10,
    pricePerKg: 0.20,
    nutrients: {
      crudeProtein: 15.0,
      metabolizableEnergy: 1250,
      lysine: 0.60,
      methionine: 0.20,
      threonine: 0.52,
      calcium: 0.12,
      availablePhosphorus: 0.28,
      sodium: 0.02,
      linoleicAcid: 1.0
    }
  },
  {
    id: 'rice_bran',
    name: 'Rice Bran',
    group: IngredientGroup.PLANT_BY_PRODUCTS,
    minPercent: 0,
    maxPercent: 15,
    pricePerKg: 0.22,
    nutrients: {
      crudeProtein: 13.0,
      metabolizableEnergy: 2400,
      lysine: 0.55,
      methionine: 0.25,
      threonine: 0.48,
      calcium: 0.07,
      availablePhosphorus: 0.40,
      sodium: 0.01,
      linoleicAcid: 5.0
    }
  },

  // ANIMAL SOURCES (3 items)
  {
    id: 'fish_meal',
    name: 'Fish Meal 65%',
    group: IngredientGroup.ANIMAL_SOURCE,
    minPercent: 0,
    maxPercent: 5,
    pricePerKg: 1.20,
    nutrients: {
      crudeProtein: 65.0,
      metabolizableEnergy: 2950,
      lysine: 5.00,
      methionine: 1.95,
      threonine: 2.85,
      calcium: 4.50,
      availablePhosphorus: 2.90,
      sodium: 0.80,
      linoleicAcid: 1.2
    }
  },
  {
    id: 'meat_bone_meal',
    name: 'Meat and Bone Meal',
    group: IngredientGroup.ANIMAL_SOURCE,
    minPercent: 0,
    maxPercent: 5,
    pricePerKg: 0.65,
    nutrients: {
      crudeProtein: 50.0,
      metabolizableEnergy: 2300,
      lysine: 2.50,
      methionine: 0.70,
      threonine: 1.80,
      calcium: 10.0,
      availablePhosphorus: 5.00,
      sodium: 0.60,
      linoleicAcid: 2.0
    }
  },
  {
    id: 'poultry_meal',
    name: 'Poultry By-Product Meal',
    group: IngredientGroup.ANIMAL_SOURCE,
    minPercent: 0,
    maxPercent: 8,
    pricePerKg: 0.85,
    nutrients: {
      crudeProtein: 60.0,
      metabolizableEnergy: 3100,
      lysine: 2.78,
      methionine: 0.98,
      threonine: 1.85,
      calcium: 4.00,
      availablePhosphorus: 1.20,
      sodium: 0.40,
      linoleicAcid: 2.0
    }
  },

  // FATS & OILS (3 items)
  {
    id: 'oil',
    name: 'Oil',
    group: IngredientGroup.FAT,
    minPercent: 0,
    maxPercent: 6,
    pricePerKg: 1.10,
    nutrients: {
      crudeProtein: 0,
      metabolizableEnergy: 8500,
      lysine: 0,
      methionine: 0,
      threonine: 0,
      calcium: 0,
      availablePhosphorus: 0,
      sodium: 0,
      linoleicAcid: 50.0
    }
  },
  {
    id: 'fat_crystalline',
    name: 'Fat, Crystalline',
    group: IngredientGroup.FAT,
    minPercent: 0,
    maxPercent: 5,
    pricePerKg: 1.15,
    nutrients: {
      crudeProtein: 0,
      metabolizableEnergy: 8500,
      lysine: 0,
      methionine: 0,
      threonine: 0,
      calcium: 0,
      availablePhosphorus: 0,
      sodium: 0,
      linoleicAcid: 12.0
    }
  },
  {
    id: 'fat_calcium_salt',
    name: 'Fat, Calcium Salt',
    group: IngredientGroup.FAT,
    minPercent: 0,
    maxPercent: 5,
    pricePerKg: 1.20,
    nutrients: {
      crudeProtein: 0,
      metabolizableEnergy: 7400,
      lysine: 0,
      methionine: 0,
      threonine: 0,
      calcium: 9.00,
      availablePhosphorus: 0,
      sodium: 0,
      linoleicAcid: 10.0
    }
  },

  // SUPPLEMENTS & ADDITIVES (25 items - key ones)
  {
    id: 'dl_methionine',
    name: 'DL-Methionine',
    group: IngredientGroup.SUPPLEMENTS_ADDITIVES,
    minPercent: 0,
    maxPercent: 0.5,
    pricePerKg: 4.50,
    nutrients: {
      crudeProtein: 58.0,
      metabolizableEnergy: 5500,
      lysine: 0,
      methionine: 99.0,
      threonine: 0,
      calcium: 0,
      availablePhosphorus: 0,
      sodium: 0,
      linoleicAcid: 0
    }
  },
  {
    id: 'l_lysine_hcl',
    name: 'L-Lysine HCl',
    group: IngredientGroup.SUPPLEMENTS_ADDITIVES,
    minPercent: 0,
    maxPercent: 0.6,
    pricePerKg: 2.80,
    nutrients: {
      crudeProtein: 98.0,
      metabolizableEnergy: 5300,
      lysine: 78.0,
      methionine: 0,
      threonine: 0,
      calcium: 0,
      availablePhosphorus: 0,
      sodium: 0,
      linoleicAcid: 0
    }
  },
  {
    id: 'l_threonine',
    name: 'L-Threonine',
    group: IngredientGroup.SUPPLEMENTS_ADDITIVES,
    minPercent: 0,
    maxPercent: 0.3,
    pricePerKg: 3.20,
    nutrients: {
      crudeProtein: 99.0,
      metabolizableEnergy: 3900,
      lysine: 0,
      methionine: 0,
      threonine: 98.5,
      calcium: 0,
      availablePhosphorus: 0,
      sodium: 0,
      linoleicAcid: 0
    }
  },
  {
    id: 'dicalcium_phosphate',
    name: 'Di Calcium Phosphate',
    group: IngredientGroup.SUPPLEMENTS_ADDITIVES,
    minPercent: 0,
    maxPercent: 3,
    pricePerKg: 0.80,
    nutrients: {
      crudeProtein: 0,
      metabolizableEnergy: 0,
      lysine: 0,
      methionine: 0,
      threonine: 0,
      calcium: 23.0,
      availablePhosphorus: 18.5,
      sodium: 0,
      linoleicAcid: 0
    }
  },
  {
    id: 'limestone',
    name: 'Limestone',
    group: IngredientGroup.SUPPLEMENTS_ADDITIVES,
    minPercent: 0,
    maxPercent: 2,
    pricePerKg: 0.10,
    nutrients: {
      crudeProtein: 0,
      metabolizableEnergy: 0,
      lysine: 0,
      methionine: 0,
      threonine: 0,
      calcium: 38.0,
      availablePhosphorus: 0,
      sodium: 0,
      linoleicAcid: 0
    }
  },
  {
    id: 'salt',
    name: 'Salt (NaCl)',
    group: IngredientGroup.SUPPLEMENTS_ADDITIVES,
    minPercent: 0,
    maxPercent: 0.4,
    pricePerKg: 0.15,
    nutrients: {
      crudeProtein: 0,
      metabolizableEnergy: 0,
      lysine: 0,
      methionine: 0,
      threonine: 0,
      calcium: 0,
      availablePhosphorus: 0,
      sodium: 39.0,
      linoleicAcid: 0
    }
  },
  {
    id: 'premix',
    name: 'Vit-Min Premix',
    group: IngredientGroup.SUPPLEMENTS_ADDITIVES,
    minPercent: 0.25,
    maxPercent: 0.5,
    pricePerKg: 8.00,
    nutrients: {
      crudeProtein: 0,
      metabolizableEnergy: 0,
      lysine: 0,
      methionine: 0,
      threonine: 0,
      calcium: 10.0,
      availablePhosphorus: 0,
      sodium: 0,
      linoleicAcid: 0
    }
  }
];

export function getIngredientById(id: string): Ingredient | undefined {
  return INGREDIENTS_DATABASE.find(ing => ing.id === id);
}

export function getIngredientsByGroup(group: IngredientGroup): Ingredient[] {
  return INGREDIENTS_DATABASE.filter(ing => ing.group === group);
}
