import Foundation
import SwiftUI
import AppKit
import UniformTypeIdentifiers

struct QualityAlertRow: View {
    let alert: QualityAlert

    private var color: Color {
        switch alert.severity {
        case .info: return Palette.pine
        case .warning: return Palette.amber
        case .critical: return Palette.coral
        }
    }

    private var icon: String {
        switch alert.severity {
        case .info: return "checkmark.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .critical: return "xmark.octagon.fill"
        }
    }

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundStyle(color)

            Text(alert.severity.rawValue)
                .font(.custom("AvenirNext-DemiBold", size: 11))
                .foregroundStyle(color)
                .frame(width: 58, alignment: .leading)

            Text(alert.message)
                .font(.custom("AvenirNext-Medium", size: 12))
                .foregroundStyle(Palette.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Palette.card)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(Palette.border, lineWidth: 1)
        )
    }
}
