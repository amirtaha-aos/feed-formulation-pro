import Foundation
import SwiftUI
import AppKit
import UniformTypeIdentifiers

struct IngredientEditorRow: View {
    @Binding var ingredient: Ingredient
    let onRemove: () -> Void

    var body: some View {
        HStack(spacing: 8) {
            TextField("Ingredient", text: $ingredient.name)
                .textFieldStyle(.plain)
                .inputChrome()
                .frame(width: 150)

            Picker("", selection: $ingredient.group) {
                ForEach(IngredientGroup.allCases) { group in
                    Text(group.rawValue).tag(group)
                }
            }
            .pickerStyle(.menu)
            .labelsHidden()
            .frame(width: 125)
            .padding(.horizontal, 8)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Palette.input)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(Palette.border, lineWidth: 1)
            )

            field($ingredient.minPercent, width: 56, fraction: 1)
            field($ingredient.maxPercent, width: 56, fraction: 1)
            field($ingredient.pricePerKg, width: 66, fraction: 0)
            field($ingredient.crudeProtein, width: 55, fraction: 2)
            field($ingredient.metabolizableEnergy, width: 80, fraction: 0)
            field($ingredient.lysine, width: 55, fraction: 2)
            field($ingredient.methionine, width: 55, fraction: 2)
            field($ingredient.threonine, width: 55, fraction: 2)
            field($ingredient.calcium, width: 55, fraction: 2)
            field($ingredient.availablePhosphorus, width: 55, fraction: 2)
            field($ingredient.sodium, width: 55, fraction: 2)
            field($ingredient.vitaminA, width: 82, fraction: 0)
            field($ingredient.vitaminD3, width: 82, fraction: 0)
            field($ingredient.vitaminE, width: 74, fraction: 0)
            field($ingredient.manganese, width: 62, fraction: 0)
            field($ingredient.zinc, width: 62, fraction: 0)
            field($ingredient.copper, width: 62, fraction: 0)
            field($ingredient.iron, width: 62, fraction: 0)
            field($ingredient.selenium, width: 62, fraction: 3)

            Button(role: .destructive, action: onRemove) {
                Image(systemName: "trash.fill")
                    .foregroundStyle(Palette.coral)
            }
            .buttonStyle(.plain)
            .frame(width: 28)
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

    private func field(_ value: Binding<Double>, width: CGFloat, fraction: Int) -> some View {
        TextField(
            "",
            value: value,
            format: .number.precision(.fractionLength(fraction))
        )
        .textFieldStyle(.plain)
        .inputChrome()
        .frame(width: width)
        .multilineTextAlignment(.trailing)
    }
}
