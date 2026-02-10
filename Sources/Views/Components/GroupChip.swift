import Foundation
import SwiftUI
import AppKit
import UniformTypeIdentifiers

struct GroupChip: View {
    let title: String
    let isOn: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 5) {
                Image(systemName: isOn ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 12))
                Text(title)
                    .font(.custom("AvenirNext-DemiBold", size: 12))
            }
            .foregroundStyle(isOn ? Palette.textPrimary : Palette.textMuted)
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(
                Capsule(style: .continuous)
                    .fill(isOn ? Palette.ocean.opacity(0.85) : Palette.card)
            )
            .overlay(
                Capsule(style: .continuous)
                    .stroke(isOn ? Palette.strongBorder : Palette.border, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}
