import Foundation
import SwiftUI
import AppKit
import UniformTypeIdentifiers

struct IngredientAvailableColumn: View {
    let group: IngredientGroup
    let ingredients: [Ingredient]
    let selectedIngredientIDs: Set<UUID>
    let onToggle: (UUID, Bool) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(group.rawValue)
                    .font(.custom("AvenirNext-DemiBold", size: 15))
                Spacer()
                Text("Tick to use")
                    .font(.custom("AvenirNext-Medium", size: 11))
                    .foregroundStyle(Palette.textMuted)
            }

            ScrollView {
                VStack(alignment: .leading, spacing: 5) {
                    ForEach(ingredients) { ingredient in
                        Toggle(
                            isOn: Binding(
                                get: { selectedIngredientIDs.contains(ingredient.id) },
                                set: { isOn in onToggle(ingredient.id, isOn) }
                            )
                        ) {
                            Text(ingredient.name)
                                .font(.custom("AvenirNext-Regular", size: 13))
                                .foregroundStyle(Palette.textPrimary)
                        }
                        .toggleStyle(.checkbox)
                    }
                }
            }
            .frame(height: 230)
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
        .frame(maxWidth: .infinity)
    }
}
