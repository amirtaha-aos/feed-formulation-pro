import { useState } from 'react';
import { INGREDIENTS_DATABASE } from '../data/ingredients';
import { getStrainPreset } from '../data/strainPresets';
import { StrainType } from '../types/enums';
import { optimizeFormulation } from '../utils/optimizer';
import { Header } from './Header';
import { IngredientPanel } from './IngredientPanel';
import { NutrientPanel } from './NutrientPanel';
import { ResultsPanel } from './ResultsPanel';
import '../styles/index.css';

export function App() {
  const [isDarkMode, setIsDarkMode] = useState(true);
  const [selectedStrain, setSelectedStrain] = useState<StrainType>(StrainType.ROSS);
  const [selectedIngredientIds, setSelectedIngredientIds] = useState<Set<string>>(new Set());
  const [result, setResult] = useState<any>(null);

  const preset = getStrainPreset(selectedStrain);
  const selectedIngredients = INGREDIENTS_DATABASE.filter(ing => 
    selectedIngredientIds.has(ing.id)
  );

  const handleCalculate = () => {
    if (selectedIngredients.length === 0) {
      alert('Please select at least one ingredient');
      return;
    }

    const optimizedResult = optimizeFormulation(selectedIngredients, preset.constraints);
    setResult(optimizedResult);
  };

  const handleReset = () => {
    setSelectedIngredientIds(new Set());
    setResult(null);
  };

  return (
    <div className={isDarkMode ? 'app dark' : 'app light'}>
      <Header 
        selectedStrain={selectedStrain}
        onStrainChange={setSelectedStrain}
        isDarkMode={isDarkMode}
        onThemeToggle={() => setIsDarkMode(!isDarkMode)}
        onReset={handleReset}
        onCalculate={handleCalculate}
      />
      
      <div className="main-content">
        <IngredientPanel 
          ingredients={INGREDIENTS_DATABASE}
          selectedIds={selectedIngredientIds}
          onToggle={(id) => {
            const newSet = new Set(selectedIngredientIds);
            if (newSet.has(id)) {
              newSet.delete(id);
            } else {
              newSet.add(id);
            }
            setSelectedIngredientIds(newSet);
          }}
        />
        
        <NutrientPanel
          constraints={preset.constraints}
          phaseName={preset.phase}
          ageRange={preset.ageRange}
        />

        <ResultsPanel
          result={result}
        />
      </div>
    </div>
  );
}
