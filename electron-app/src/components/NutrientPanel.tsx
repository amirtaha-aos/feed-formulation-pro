import { NutrientConstraint } from '../types';

interface NutrientPanelProps {
  constraints: NutrientConstraint[];
  phaseName: string;
  ageRange: string;
}

export function NutrientPanel({ constraints, phaseName, ageRange }: NutrientPanelProps) {
  return (
    <div className="panel nutrient-panel">
      <h2>Nutrient Requirements</h2>

      <div className="phase-info">
        <div className="phase-name">{phaseName}</div>
        <div className="phase-age">{ageRange}</div>
      </div>

      <div className="nutrient-table">
        <div className="table-header">
          <span className="col-nutrient">Nutrient</span>
          <span className="col-min">Min</span>
          <span className="col-max">Max</span>
          <span className="col-unit">Unit</span>
        </div>

        {constraints.map((constraint, index) => (
          <div key={index} className="table-row">
            <span className="col-nutrient">{constraint.name}</span>
            <span className="col-min">
              {constraint.min !== null ? constraint.min.toFixed(2) : '-'}
            </span>
            <span className="col-max">
              {constraint.max !== null ? constraint.max.toFixed(2) : '-'}
            </span>
            <span className="col-unit">{constraint.unit}</span>
          </div>
        ))}
      </div>
    </div>
  );
}
