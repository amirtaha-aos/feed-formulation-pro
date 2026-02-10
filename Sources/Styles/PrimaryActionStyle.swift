import Foundation
import SwiftUI
import AppKit
import UniformTypeIdentifiers

struct PrimaryActionStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.custom("AvenirNext-DemiBold", size: 14))
            .foregroundStyle(Palette.textPrimary)
            .padding(.horizontal, 16)
            .padding(.vertical, 9)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Palette.pine, Palette.ocean],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(Palette.strongBorder, lineWidth: 1)
            )
            .shadow(color: Palette.pine.opacity(0.35), radius: 8, y: 4)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeOut(duration: 0.14), value: configuration.isPressed)
    }
}
