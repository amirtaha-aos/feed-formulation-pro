// Light Mode Colors
export const lightColors = {
  background: '#f5f5f7',
  surface: '#ffffff',
  surfaceHover: '#f0f0f0',
  border: '#d1d1d6',
  text: '#1d1d1f',
  textSecondary: '#6e6e73',
  primary: '#007aff',
  primaryHover: '#0051d5',
  success: '#34c759',
  warning: '#ff9500',
  error: '#ff3b30',
  shadow: 'rgba(0, 0, 0, 0.1)',
  headerBg: '#ffffff',
  panelBg: '#ffffff',
  inputBg: '#f5f5f7',
};

// Dark Mode Colors
export const darkColors = {
  background: '#000000',
  surface: '#1c1c1e',
  surfaceHover: '#2c2c2e',
  border: '#38383a',
  text: '#ffffff',
  textSecondary: '#ebebf5',
  primary: '#0a84ff',
  primaryHover: '#409cff',
  success: '#32d74b',
  warning: '#ff9f0a',
  error: '#ff453a',
  shadow: 'rgba(0, 0, 0, 0.3)',
  headerBg: '#1c1c1e',
  panelBg: '#1c1c1e',
  inputBg: '#2c2c2e',
};

export type ColorTheme = typeof lightColors;
