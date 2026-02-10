// Color theme matching the Swift/macOS version exactly
// Converted from Swift ColorTheme.swift RGB values (0-1) to hex

export const lightColors = {
  // Backgrounds
  backgroundPrimary: '#FAFAFC',      // rgb(0.98, 0.98, 0.99)
  backgroundSecondary: '#F2F4F7',    // rgb(0.95, 0.96, 0.97)
  backgroundGradientStart: '#F0F2F7', // rgb(0.94, 0.95, 0.97)
  backgroundGradientEnd: '#F5F7F9',  // rgb(0.96, 0.97, 0.98)

  // Panels
  panelBackground: '#FFFFFF',        // rgb(1.0, 1.0, 1.0)
  panelBorder: '#D9DBDE',            // rgb(0.85, 0.86, 0.87)
  panelStrongBorder: '#BFC4CC',      // rgb(0.75, 0.77, 0.80)

  // Cards
  cardBackground: '#FCFCFE',         // rgb(0.99, 0.99, 0.995)
  cardSoft: '#F7F7F9',               // rgb(0.97, 0.97, 0.98)
  cardBorder: '#E0E3E6',             // rgb(0.88, 0.89, 0.90)

  // Inputs
  inputBackground: '#FAFAFC',        // rgb(0.98, 0.98, 0.99)
  inputBorder: '#D1D6DB',            // rgb(0.82, 0.84, 0.86)
  inputBorderFocused: '#4D8CCC',     // rgb(0.30, 0.55, 0.80)

  // Text
  textPrimary: '#1F2126',            // rgb(0.12, 0.13, 0.15)
  textSecondary: '#474D54',          // rgb(0.28, 0.30, 0.33)
  textMuted: '#7A828C',              // rgb(0.48, 0.51, 0.55)
  textDisabled: '#ADB2B8',           // rgb(0.68, 0.70, 0.72)

  // Accents
  accentPrimary: '#1A7AD1',          // rgb(0.10, 0.48, 0.82)
  accentSecondary: '#6B42B8',        // rgb(0.42, 0.26, 0.72)
  accentSuccess: '#219E70',          // rgb(0.13, 0.62, 0.44)
  accentWarning: '#F2A62E',          // rgb(0.95, 0.65, 0.18)
  accentDanger: '#D14047',           // rgb(0.82, 0.25, 0.28)
  accentInfo: '#4099D9',             // rgb(0.25, 0.60, 0.85)

  // Buttons
  buttonPrimaryBg: '#1A7AD1',        // rgb(0.10, 0.48, 0.82)
  buttonPrimaryText: '#FFFFFF',      // white
  buttonSecondaryBg: '#EDEEF0',      // rgb(0.93, 0.94, 0.95)
  buttonSecondaryText: '#383D45',    // rgb(0.22, 0.24, 0.27)

  // Status
  statusSuccess: '#219E70',          // rgb(0.13, 0.62, 0.44)
  statusWarning: '#F2A62E',          // rgb(0.95, 0.65, 0.18)
  statusError: '#D14047',            // rgb(0.82, 0.25, 0.28)
  statusInfo: '#4099D9',             // rgb(0.25, 0.60, 0.85)
};

export const darkColors = {
  // Backgrounds
  backgroundPrimary: '#1C1F24',      // rgb(0.11, 0.12, 0.14)
  backgroundSecondary: '#23262B',    // rgb(0.14, 0.15, 0.17)
  backgroundGradientStart: '#1F386B', // rgb(0.12, 0.22, 0.42)
  backgroundGradientEnd: '#1C7594',  // rgb(0.11, 0.46, 0.58)

  // Panels
  panelBackground: '#262B33',        // rgb(0.15, 0.17, 0.20)
  panelBorder: '#40454D',            // rgb(0.25, 0.27, 0.30)
  panelStrongBorder: '#525961',      // rgb(0.32, 0.35, 0.38)

  // Cards
  cardBackground: '#2E333B',         // rgb(0.18, 0.20, 0.23)
  cardSoft: '#333840',               // rgb(0.20, 0.22, 0.25)
  cardBorder: '#474D54',             // rgb(0.28, 0.30, 0.33)

  // Inputs
  inputBackground: '#292E36',        // rgb(0.16, 0.18, 0.21)
  inputBorder: '#4D545C',            // rgb(0.30, 0.33, 0.36)
  inputBorderFocused: '#669ED9',     // rgb(0.40, 0.62, 0.85)

  // Text
  textPrimary: '#F2F5F7',            // rgb(0.95, 0.96, 0.97)
  textSecondary: '#CCD1D6',          // rgb(0.80, 0.82, 0.84)
  textMuted: '#949CA1',              // rgb(0.58, 0.60, 0.63)
  textDisabled: '#61666D',           // rgb(0.38, 0.40, 0.43)

  // Accents
  accentPrimary: '#59A6EB',          // rgb(0.35, 0.65, 0.92)
  accentSecondary: '#9E75E0',        // rgb(0.62, 0.46, 0.88)
  accentSuccess: '#4DBF94',          // rgb(0.30, 0.75, 0.58)
  accentWarning: '#FABF52',          // rgb(0.98, 0.75, 0.32)
  accentDanger: '#EB6B73',            // rgb(0.92, 0.42, 0.45)
  accentInfo: '#6BB8EB',             // rgb(0.42, 0.72, 0.92)

  // Buttons
  buttonPrimaryBg: '#59A6EB',        // rgb(0.35, 0.65, 0.92)
  buttonPrimaryText: '#FFFFFF',      // white
  buttonSecondaryBg: '#404752',      // rgb(0.25, 0.28, 0.32)
  buttonSecondaryText: '#EBEDF2',    // rgb(0.92, 0.93, 0.95)

  // Status
  statusSuccess: '#4DBF94',          // rgb(0.30, 0.75, 0.58)
  statusWarning: '#FABF52',          // rgb(0.98, 0.75, 0.32)
  statusError: '#EB6B73',            // rgb(0.92, 0.42, 0.45)
  statusInfo: '#6BB8EB',             // rgb(0.42, 0.72, 0.92)
};

export type ColorTheme = typeof lightColors;
