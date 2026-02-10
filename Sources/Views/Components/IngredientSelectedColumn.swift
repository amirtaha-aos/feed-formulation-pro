import Foundation
import SwiftUI
import AppKit
import UniformTypeIdentifiers

struct IngredientSelectedColumn: View {
    let selectedIngredients: [Ingredient]
    let selectedCount: Int
    let onClearAll: () -> Void
    let onUseCoreSet: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Selected Ingredients")
                    .font(.custom("AvenirNext-DemiBold", size: 15))
                Spacer()
                Text("\(selectedCount)")
                    .font(.custom("AvenirNext-Medium", size: 11))
                    .foregroundStyle(Palette.textMuted)
            }

            ScrollView {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(selectedIngredients) { ingredient in
                        HStack {
                            Text(ingredient.name)
                                .font(.custom("AvenirNext-Regular", size: 12))
                                .lineLimit(1)
                            Spacer()
                            Text(ingredient.group.rawValue)
                                .font(.custom("AvenirNext-Medium", size: 10))
                                .foregroundStyle(Palette.textMuted)
                        }
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

            HStack(spacing: 8) {
                Button("Clear All", action: onClearAll)
                    .buttonStyle(SecondaryActionStyle())
                Button("Use Core Set", action: onUseCoreSet)
                    .buttonStyle(SecondaryActionStyle())
            }
        }
        .frame(maxWidth: .infinity)
    }
}
