import Foundation
import SwiftUI
import AppKit
import UniformTypeIdentifiers

struct MRPRow: View {
    let line: MRPOrderLine

    var body: some View {
        HStack(spacing: 8) {
            Text(line.ingredientName)
                .lineLimit(1)
                .frame(width: 190, alignment: .leading)
            Text(line.group.rawValue)
                .font(.custom("AvenirNext-Medium", size: 11))
                .foregroundStyle(Palette.textMuted)
                .frame(width: 110)
            Text("\(line.dailyUsageKg, specifier: "%.2f")")
                .frame(width: 76, alignment: .trailing)
                .monospacedDigit()
            Text("\(line.leadDemandKg, specifier: "%.1f")")
                .frame(width: 76, alignment: .trailing)
                .monospacedDigit()
            Text("\(line.safetyKg, specifier: "%.1f")")
                .frame(width: 76, alignment: .trailing)
                .monospacedDigit()
            Text("\(line.onHandKg, specifier: "%.1f")")
                .frame(width: 86, alignment: .trailing)
                .monospacedDigit()
            Text("\(line.reorderKg, specifier: "%.1f")")
                .frame(width: 88, alignment: .trailing)
                .foregroundStyle(line.reorderKg > 0 ? Palette.amber : Palette.pine)
                .monospacedDigit()
            Text(line.daysCover > 0 ? "\(line.daysCover, specifier: "%.1f")d" : "-")
                .frame(width: 72, alignment: .trailing)
                .foregroundStyle(line.daysCover < 3 ? Palette.coral : Palette.textMuted)
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
}
