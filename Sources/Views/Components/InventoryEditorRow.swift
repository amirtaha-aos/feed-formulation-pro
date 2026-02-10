import Foundation
import SwiftUI
import AppKit
import UniformTypeIdentifiers

struct InventoryEditorRow: View {
    let ingredientName: String
    let group: String
    let dailyUsageKg: Double
    let daysCover: Double
    let reorderKg: Double
    @Binding var onHand: Double
    @Binding var safety: Double

    var body: some View {
        HStack(spacing: 8) {
            Text(ingredientName)
                .lineLimit(1)
                .frame(width: 210, alignment: .leading)
            Text(group)
                .font(.custom("AvenirNext-Medium", size: 11))
                .foregroundStyle(Palette.textMuted)
                .frame(width: 120)

            numericField($onHand, width: 96, fraction: 1)
            numericField($safety, width: 96, fraction: 1)
            Text("\(dailyUsageKg, specifier: "%.2f")")
                .frame(width: 88, alignment: .trailing)
                .monospacedDigit()
            Text(daysCover > 0 ? "\(daysCover, specifier: "%.1f")" : "-")
                .frame(width: 88, alignment: .trailing)
                .foregroundStyle(daysCover > 0 ? Palette.textMuted : Palette.coral)
                .monospacedDigit()
            Text("\(reorderKg, specifier: "%.1f")")
                .frame(width: 96, alignment: .trailing)
                .foregroundStyle(reorderKg > 0 ? Palette.amber : Palette.pine)
                .monospacedDigit()
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

    private func numericField(_ value: Binding<Double>, width: CGFloat, fraction: Int) -> some View {
        TextField("", value: value, format: .number.precision(.fractionLength(fraction)))
            .textFieldStyle(.plain)
            .inputChrome()
            .frame(width: width)
            .multilineTextAlignment(.trailing)
    }
}
