import Foundation
import SwiftUI
import AppKit
import UniformTypeIdentifiers

struct AllocationRow: View {
    let allocation: RationAllocation
    let batchSizeKg: Double

    private var batchShareKg: Double {
        (allocation.inclusionPercent / 100.0) * batchSizeKg
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Text(allocation.name)
                    .foregroundStyle(Palette.textPrimary)
                Spacer()
                Text(allocation.group.rawValue)
                    .font(.custom("AvenirNext-Medium", size: 11))
                    .foregroundStyle(Palette.textMuted)
                Text("\(allocation.inclusionPercent, specifier: "%.2f")%")
                    .foregroundStyle(Palette.textMuted)
                    .monospacedDigit()
            }

            ProgressView(value: allocation.inclusionPercent, total: 100)
                .tint(Palette.pine)

            HStack {
                Text("Batch share: \(batchShareKg, specifier: "%.2f") kg")
                    .font(.custom("AvenirNext-Medium", size: 11))
                    .foregroundStyle(Palette.textMuted)
                Spacer()
                Text("Cost share: \(allocation.costContributionPerKg, specifier: "%.0f") Toman / kg")
                    .font(.custom("AvenirNext-Medium", size: 11))
                    .foregroundStyle(Palette.textMuted)
                    .monospacedDigit()
            }
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
