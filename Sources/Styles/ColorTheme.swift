import SwiftUI

/// Adaptive color theme for Light and Dark modes
struct ColorTheme {

    // MARK: - Background Colors
    let backgroundPrimary: Color
    let backgroundSecondary: Color
    let backgroundGradientStart: Color
    let backgroundGradientEnd: Color

    // MARK: - Panel Colors
    let panelBackground: Color
    let panelBorder: Color
    let panelStrongBorder: Color

    // MARK: - Card Colors
    let cardBackground: Color
    let cardSoft: Color
    let cardBorder: Color

    // MARK: - Input Colors
    let inputBackground: Color
    let inputBorder: Color
    let inputBorderFocused: Color

    // MARK: - Text Colors
    let textPrimary: Color
    let textSecondary: Color
    let textMuted: Color
    let textDisabled: Color

    // MARK: - Accent Colors
    let accentPrimary: Color
    let accentSecondary: Color
    let accentSuccess: Color
    let accentWarning: Color
    let accentDanger: Color
    let accentInfo: Color

    // MARK: - Button Colors
    let buttonPrimaryBackground: Color
    let buttonPrimaryForeground: Color
    let buttonSecondaryBackground: Color
    let buttonSecondaryForeground: Color

    // MARK: - Status Colors
    let statusSuccess: Color
    let statusWarning: Color
    let statusError: Color
    let statusInfo: Color

    // MARK: - Predefined Themes

    static let light = ColorTheme(
        // Backgrounds
        backgroundPrimary: Color(red: 0.98, green: 0.98, blue: 0.99),
        backgroundSecondary: Color(red: 0.95, green: 0.96, blue: 0.97),
        backgroundGradientStart: Color(red: 0.94, green: 0.95, blue: 0.97),
        backgroundGradientEnd: Color(red: 0.96, green: 0.97, blue: 0.98),

        // Panels
        panelBackground: Color(red: 1.0, green: 1.0, blue: 1.0),
        panelBorder: Color(red: 0.85, green: 0.86, blue: 0.87),
        panelStrongBorder: Color(red: 0.75, green: 0.77, blue: 0.80),

        // Cards
        cardBackground: Color(red: 0.99, green: 0.99, blue: 0.995),
        cardSoft: Color(red: 0.97, green: 0.97, blue: 0.98),
        cardBorder: Color(red: 0.88, green: 0.89, blue: 0.90),

        // Inputs
        inputBackground: Color(red: 0.98, green: 0.98, blue: 0.99),
        inputBorder: Color(red: 0.82, green: 0.84, blue: 0.86),
        inputBorderFocused: Color(red: 0.30, green: 0.55, blue: 0.80),

        // Text
        textPrimary: Color(red: 0.12, green: 0.13, blue: 0.15),
        textSecondary: Color(red: 0.28, green: 0.30, blue: 0.33),
        textMuted: Color(red: 0.48, green: 0.51, blue: 0.55),
        textDisabled: Color(red: 0.68, green: 0.70, blue: 0.72),

        // Accents
        accentPrimary: Color(red: 0.10, green: 0.48, blue: 0.82),
        accentSecondary: Color(red: 0.42, green: 0.26, blue: 0.72),
        accentSuccess: Color(red: 0.13, green: 0.62, blue: 0.44),
        accentWarning: Color(red: 0.95, green: 0.65, blue: 0.18),
        accentDanger: Color(red: 0.82, green: 0.25, blue: 0.28),
        accentInfo: Color(red: 0.25, green: 0.60, blue: 0.85),

        // Buttons
        buttonPrimaryBackground: Color(red: 0.10, green: 0.48, blue: 0.82),
        buttonPrimaryForeground: Color.white,
        buttonSecondaryBackground: Color(red: 0.93, green: 0.94, blue: 0.95),
        buttonSecondaryForeground: Color(red: 0.22, green: 0.24, blue: 0.27),

        // Status
        statusSuccess: Color(red: 0.13, green: 0.62, blue: 0.44),
        statusWarning: Color(red: 0.95, green: 0.65, blue: 0.18),
        statusError: Color(red: 0.82, green: 0.25, blue: 0.28),
        statusInfo: Color(red: 0.25, green: 0.60, blue: 0.85)
    )

    static let dark = ColorTheme(
        // Backgrounds
        backgroundPrimary: Color(red: 0.11, green: 0.12, blue: 0.14),
        backgroundSecondary: Color(red: 0.14, green: 0.15, blue: 0.17),
        backgroundGradientStart: Color(red: 0.12, green: 0.22, blue: 0.42),
        backgroundGradientEnd: Color(red: 0.11, green: 0.46, blue: 0.58),

        // Panels
        panelBackground: Color(red: 0.15, green: 0.17, blue: 0.20),
        panelBorder: Color(red: 0.25, green: 0.27, blue: 0.30),
        panelStrongBorder: Color(red: 0.32, green: 0.35, blue: 0.38),

        // Cards
        cardBackground: Color(red: 0.18, green: 0.20, blue: 0.23),
        cardSoft: Color(red: 0.20, green: 0.22, blue: 0.25),
        cardBorder: Color(red: 0.28, green: 0.30, blue: 0.33),

        // Inputs
        inputBackground: Color(red: 0.16, green: 0.18, blue: 0.21),
        inputBorder: Color(red: 0.30, green: 0.33, blue: 0.36),
        inputBorderFocused: Color(red: 0.40, green: 0.62, blue: 0.85),

        // Text
        textPrimary: Color(red: 0.95, green: 0.96, blue: 0.97),
        textSecondary: Color(red: 0.80, green: 0.82, blue: 0.84),
        textMuted: Color(red: 0.58, green: 0.60, blue: 0.63),
        textDisabled: Color(red: 0.38, green: 0.40, blue: 0.43),

        // Accents
        accentPrimary: Color(red: 0.35, green: 0.65, blue: 0.92),
        accentSecondary: Color(red: 0.62, green: 0.46, blue: 0.88),
        accentSuccess: Color(red: 0.30, green: 0.75, blue: 0.58),
        accentWarning: Color(red: 0.98, green: 0.75, blue: 0.32),
        accentDanger: Color(red: 0.92, green: 0.42, blue: 0.45),
        accentInfo: Color(red: 0.42, green: 0.72, blue: 0.92),

        // Buttons
        buttonPrimaryBackground: Color(red: 0.35, green: 0.65, blue: 0.92),
        buttonPrimaryForeground: Color.white,
        buttonSecondaryBackground: Color(red: 0.25, green: 0.28, blue: 0.32),
        buttonSecondaryForeground: Color(red: 0.92, green: 0.93, blue: 0.95),

        // Status
        statusSuccess: Color(red: 0.30, green: 0.75, blue: 0.58),
        statusWarning: Color(red: 0.98, green: 0.75, blue: 0.32),
        statusError: Color(red: 0.92, green: 0.42, blue: 0.45),
        statusInfo: Color(red: 0.42, green: 0.72, blue: 0.92)
    )
}

/// Environment key for color theme
struct ColorThemeKey: EnvironmentKey {
    static let defaultValue = ColorTheme.dark
}

extension EnvironmentValues {
    var colorTheme: ColorTheme {
        get { self[ColorThemeKey.self] }
        set { self[ColorThemeKey.self] = newValue }
    }
}
