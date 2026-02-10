import Foundation
import SwiftUI
import AppKit
import UniformTypeIdentifiers

struct IngredientHeaderRow: View {
    var body: some View {
        HStack(spacing: 8) {
            Text("Ingredient").frame(width: 150, alignment: .leading)
            Text("Group").frame(width: 125)
            Text("Min%").frame(width: 56)
            Text("Max%").frame(width: 56)
            Text("Cost Tmn").frame(width: 66)
            Text("CP").frame(width: 55)
            Text("ME").frame(width: 80)
            Text("Lys").frame(width: 55)
            Text("Met").frame(width: 55)
            Text("Thr").frame(width: 55)
            Text("Ca").frame(width: 55)
            Text("AvP").frame(width: 55)
            Text("Na").frame(width: 55)
            Text("VitA").frame(width: 82)
            Text("VitD3").frame(width: 82)
            Text("VitE").frame(width: 74)
            Text("Mn").frame(width: 62)
            Text("Zn").frame(width: 62)
            Text("Cu").frame(width: 62)
            Text("Fe").frame(width: 62)
            Text("Se").frame(width: 62)
            Text("").frame(width: 28)
        }
        .font(.custom("AvenirNext-DemiBold", size: 12))
        .foregroundStyle(Palette.textMuted)
    }
}
