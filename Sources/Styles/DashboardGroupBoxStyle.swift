import Foundation
import SwiftUI
import AppKit
import UniformTypeIdentifiers

struct DashboardGroupBoxStyle: GroupBoxStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            configuration.label
                .font(.custom("AvenirNext-DemiBold", size: 14))
                .foregroundStyle(Palette.textPrimary)
            configuration.content
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Palette.cardSoft)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Palette.border, lineWidth: 1)
        )
    }
}
