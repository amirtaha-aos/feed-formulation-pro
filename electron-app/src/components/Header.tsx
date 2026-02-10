import { StrainType } from '../types/enums';

interface HeaderProps {
  selectedStrain: StrainType;
  onStrainChange: (strain: StrainType) => void;
  isDarkMode: boolean;
  onThemeToggle: () => void;
  onReset: () => void;
  onCalculate: () => void;
}

export function Header({
  selectedStrain,
  onStrainChange,
  isDarkMode,
  onThemeToggle,
  onReset,
  onCalculate
}: HeaderProps) {
  return (
    <header className="app-header">
      <div className="header-left">
        <h1>Feed Formulation Pro</h1>
        <p className="subtitle">PHD Khaleghi - Professional Feed Formulation</p>
      </div>

      <div className="header-controls">
        <select
          value={selectedStrain}
          onChange={(e) => onStrainChange(e.target.value as StrainType)}
          className="strain-select"
        >
          {Object.values(StrainType).map(strain => (
            <option key={strain} value={strain}>{strain}</option>
          ))}
        </select>

        <button onClick={onThemeToggle} className="btn-secondary">
          {isDarkMode ? '☀️ Light' : '🌙 Dark'}
        </button>

        <button onClick={onReset} className="btn-secondary">
          Reset
        </button>

        <button onClick={onCalculate} className="btn-primary">
          Calculate
        </button>
      </div>
    </header>
  );
}
