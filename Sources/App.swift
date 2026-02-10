import Foundation
import SwiftUI
import AppKit
import UniformTypeIdentifiers

@main
struct PhdKhaleghiFormolaApp: App {
    @StateObject private var themeManager = ThemeManager.shared

    var body: some Scene {
        WindowGroup("Feed Formulation Pro - PHD Khaleghi") {
            ContentView()
                .environmentObject(themeManager)
                .frame(minWidth: 1450, minHeight: 880)
        }
        .commands {
            CommandGroup(after: .appSettings) {
                Button(themeManager.isDarkMode ? "Switch to Light Mode" : "Switch to Dark Mode") {
                    themeManager.isDarkMode.toggle()
                }
                .keyboardShortcut("t", modifiers: [.command, .shift])
            }
        }
    }
}
