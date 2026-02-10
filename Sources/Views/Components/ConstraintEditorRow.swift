import Foundation
import SwiftUI
import AppKit
import UniformTypeIdentifiers

struct ConstraintEditorRow: View {
    @Binding var constraint: NutrientConstraint

    private var groupColor: Color {
        switch constraint.key.group {
        case .macro: return Palette.ocean
        case .amino: return Palette.pine
        case .vitamin: return Palette.amber
        case .mineral: return Palette.coral
        }
    }

    var body: some View {
        HStack(spacing: 8) {
            HStack(spacing: 7) {
                Circle()
                    .fill(groupColor)
                    .frame(width: 8, height: 8)
                VStack(alignment: .leading, spacing: 0) {
                    Text(constraint.key.title)
                        .font(.custom("AvenirNext-Medium", size: 13))
                    Text(constraint.key.group.rawValue)
                        .font(.custom("AvenirNext-Regular", size: 11))
                        .foregroundStyle(Palette.textMuted)
                }
            }
            .frame(width: 220, alignment: .leading)

            Text(constraint.key.unit)
                .font(.custom("AvenirNext-Medium", size: 12))
                .foregroundStyle(Palette.textMuted)
                .frame(width: 80)

            Toggle("", isOn: $constraint.useMin)
                .labelsHidden()
                .toggleStyle(.checkbox)
                .frame(width: 44)

            TextField(
                "",
                value: $constraint.minValue,
                format: .number.precision(.fractionLength(constraint.key.decimals))
            )
            .textFieldStyle(.plain)
            .inputChrome()
            .frame(width: 100)
            .multilineTextAlignment(.trailing)
            .disabled(!constraint.useMin)
            .opacity(constraint.useMin ? 1 : 0.5)

            Toggle("", isOn: $constraint.useMax)
                .labelsHidden()
                .toggleStyle(.checkbox)
                .frame(width: 44)

            TextField(
                "",
                value: $constraint.maxValue,
                format: .number.precision(.fractionLength(constraint.key.decimals))
            )
            .textFieldStyle(.plain)
            .inputChrome()
            .frame(width: 100)
            .multilineTextAlignment(.trailing)
            .disabled(!constraint.useMax)
            .opacity(constraint.useMax ? 1 : 0.5)
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
