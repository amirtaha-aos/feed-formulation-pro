import { useState } from 'react';
import { Ingredient, IngredientGroup } from '../types';

interface IngredientPanelProps {
  ingredients: Ingredient[];
  selectedIds: Set<string>;
  onToggle: (id: string) => void;
}

export function IngredientPanel({ ingredients, selectedIds, onToggle }: IngredientPanelProps) {
  const [activeGroup, setActiveGroup] = useState<IngredientGroup>(IngredientGroup.GRAIN);

  const filteredIngredients = ingredients.filter(ing => ing.group === activeGroup);

  return (
    <div className="panel ingredient-panel">
      <h2>Ingredients</h2>

      <div className="group-tabs">
        {Object.values(IngredientGroup).map(group => (
          <button
            key={group}
            className={`tab ${activeGroup === group ? 'active' : ''}`}
            onClick={() => setActiveGroup(group)}
          >
            {group}
          </button>
        ))}
      </div>

      <div className="ingredient-list">
        {filteredIngredients.map(ing => (
          <div
            key={ing.id}
            className={`ingredient-item ${selectedIds.has(ing.id) ? 'selected' : ''}`}
            onClick={() => onToggle(ing.id)}
          >
            <input
              type="checkbox"
              checked={selectedIds.has(ing.id)}
              onChange={() => {}}
            />
            <span className="ingredient-name">{ing.name}</span>
            <span className="ingredient-protein">CP: {ing.nutrients.crudeProtein}%</span>
          </div>
        ))}
      </div>
    </div>
  );
}
