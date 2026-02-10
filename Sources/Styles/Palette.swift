import Foundation
import SwiftUI
import AppKit
import UniformTypeIdentifiers

/// Theme-aware color palette supporting Light and Dark modes
@MainActor
final class ThemeManager: ObservableObject {
    static let shared = ThemeManager()

    @Published var isDarkMode: Bool = true {
        didSet {
            UserDefaults.standard.set(isDarkMode, forKey: "isDarkMode")
        }
    }

    init() {
        self.isDarkMode = UserDefaults.standard.object(forKey: "isDarkMode") as? Bool ?? true
    }

    var current: PaletteColors {
        isDarkMode ? .dark : .light
    }
}

/// Color palette structure
struct PaletteColors {
    // Background gradients
    let gradientStart: Color
    let gradientMid: Color
    let gradientEnd: Color

    // Accent colors
    let ocean: Color
    let pine: Color
    let amber: Color
    let coral: Color

    // Panel colors
    let panelTop: Color
    let panelBottom: Color

    // Card colors
    let card: Color
    let cardSoft: Color

    // Input colors
    let input: Color

    // Border colors
    let border: Color
    let strongBorder: Color

    // Text colors
    let textPrimary: Color
    let textSecondary: Color
    let textMuted: Color

    // MARK: - Dark Theme
    static let dark = PaletteColors(
        gradientStart: Color(red: 0.04, green: 0.06, blue: 0.11),
        gradientMid: Color(red: 0.06, green: 0.12, blue: 0.24),
        gradientEnd: Color(red: 0.09, green: 0.40, blue: 0.64),
        ocean: Color(red: 0.09, green: 0.40, blue: 0.64),
        pine: Color(red: 0.08, green: 0.70, blue: 0.47),
        amber: Color(red: 0.95, green: 0.67, blue: 0.16),
        coral: Color(red: 0.93, green: 0.33, blue: 0.35),
        panelTop: Color(red: 0.10, green: 0.13, blue: 0.23).opacity(0.96),
        panelBottom: Color(red: 0.07, green: 0.09, blue: 0.17).opacity(0.98),
        card: Color(red: 0.12, green: 0.17, blue: 0.30).opacity(0.94),
        cardSoft: Color(red: 0.15, green: 0.21, blue: 0.35).opacity(0.94),
        input: Color(red: 0.16, green: 0.22, blue: 0.36).opacity(0.96),
        border: Color.white.opacity(0.20),
        strongBorder: Color.white.opacity(0.34),
        textPrimary: Color.white,
        textSecondary: Color(red: 0.85, green: 0.88, blue: 0.92),
        textMuted: Color(red: 0.65, green: 0.72, blue: 0.82)
    )

    // MARK: - Light Theme
    static let light = PaletteColors(
        gradientStart: Color(red: 0.94, green: 0.95, blue: 0.97),
        gradientMid: Color(red: 0.90, green: 0.93, blue: 0.96),
        gradientEnd: Color(red: 0.86, green: 0.90, blue: 0.95),
        ocean: Color(red: 0.15, green: 0.45, blue: 0.72),
        pine: Color(red: 0.12, green: 0.58, blue: 0.42),
        amber: Color(red: 0.88, green: 0.58, blue: 0.12),
        coral: Color(red: 0.85, green: 0.28, blue: 0.32),
        panelTop: Color(red: 1.0, green: 1.0, blue: 1.0).opacity(0.98),
        panelBottom: Color(red: 0.97, green: 0.97, blue: 0.98).opacity(0.98),
        card: Color(red: 0.98, green: 0.98, blue: 0.99).opacity(0.96),
        cardSoft: Color(red: 0.95, green: 0.96, blue: 0.97).opacity(0.96),
        input: Color(red: 0.96, green: 0.97, blue: 0.98).opacity(0.98),
        border: Color.black.opacity(0.12),
        strongBorder: Color.black.opacity(0.22),
        textPrimary: Color(red: 0.12, green: 0.14, blue: 0.18),
        textSecondary: Color(red: 0.28, green: 0.32, blue: 0.38),
        textMuted: Color(red: 0.45, green: 0.50, blue: 0.58)
    )
}

/// Legacy Palette enum for backward compatibility - now uses ThemeManager
@MainActor
enum Palette {
    static var midnight: Color { ThemeManager.shared.current.gradientStart }
    static var indigo: Color { ThemeManager.shared.current.gradientMid }
    static var ocean: Color { ThemeManager.shared.current.ocean }
    static var pine: Color { ThemeManager.shared.current.pine }
    static var amber: Color { ThemeManager.shared.current.amber }
    static var coral: Color { ThemeManager.shared.current.coral }
    static var panelTop: Color { ThemeManager.shared.current.panelTop }
    static var panelBottom: Color { ThemeManager.shared.current.panelBottom }
    static var card: Color { ThemeManager.shared.current.card }
    static var cardSoft: Color { ThemeManager.shared.current.cardSoft }
    static var input: Color { ThemeManager.shared.current.input }
    static var border: Color { ThemeManager.shared.current.border }
    static var strongBorder: Color { ThemeManager.shared.current.strongBorder }
    static var textPrimary: Color { ThemeManager.shared.current.textPrimary }
    static var textMuted: Color { ThemeManager.shared.current.textMuted }
}
