import { FormulationResult } from '../types';

interface ResultsPanelProps {
  result: FormulationResult | null;
}

export function ResultsPanel({ result }: ResultsPanelProps) {
  if (!result) {
    return (
      <div className="panel results-panel">
        <h2>Formulation Results</h2>
        <div className="no-results">
          <p>Select ingredients and click "Calculate Formulation" to see results</p>
        </div>
      </div>
    );
  }

  const { ingredients, nutrients, totalCost, status, message } = result;

  return (
    <div className="panel results-panel">
      <h2>Formulation Results</h2>

      {/* Status Message */}
      <div className={`status-message ${status}`}>
        <strong>{status === 'feasible' ? '✓ Success' : '⚠ Warning'}</strong>
        <p>{message}</p>
      </div>

      {/* Total Cost */}
      <div className="cost-summary">
        <span className="cost-label">Total Cost per Kg:</span>
        <span className="cost-value">${totalCost.toFixed(4)}</span>
      </div>

      {/* Ingredient Composition */}
      <div className="section">
        <h3>Ingredient Composition</h3>
        <div className="ingredient-results">
          {ingredients.map((item, index) => (
            <div key={index} className="result-row">
              <span className="ingredient-name">{item.name}</span>
              <span className="ingredient-percentage">{item.percentage.toFixed(2)}%</span>
            </div>
          ))}
        </div>
      </div>

      {/* Nutrient Profile */}
      <div className="section">
        <h3>Calculated Nutrient Profile</h3>
        <div className="nutrient-results">
          {nutrients.map((nutrient, index) => (
            <div key={index} className="result-row">
              <span className="nutrient-name">{nutrient.name}</span>
              <span className="nutrient-value">
                {nutrient.value.toFixed(2)} {nutrient.unit}
              </span>
              <span className={`nutrient-status ${nutrient.status}`}>
                {nutrient.status === 'ok' ? '✓' : nutrient.status === 'low' ? '↓' : '↑'}
              </span>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
