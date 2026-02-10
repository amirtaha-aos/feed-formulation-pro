import Foundation
import SwiftUI
import AppKit
import UniformTypeIdentifiers

struct MetricCard: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.custom("AvenirNext-Medium", size: 11))
                .foregroundStyle(Palette.textMuted)
            Text(value)
                .font(.custom("AvenirNext-DemiBold", size: 17))
                .foregroundStyle(Palette.textPrimary)
                .monospacedDigit()
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Palette.cardSoft)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(Palette.border, lineWidth: 1)
        )
    }
}
