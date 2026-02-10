import Foundation
import SwiftUI
import AppKit
import UniformTypeIdentifiers

struct InventoryHeaderRow: View {
    var body: some View {
        HStack(spacing: 8) {
            Text("Ingredient").frame(width: 210, alignment: .leading)
            Text("Group").frame(width: 120)
            Text("On Hand (kg)").frame(width: 96)
            Text("Safety (kg)").frame(width: 96)
            Text("Daily Use").frame(width: 88)
            Text("Days Cover").frame(width: 88)
            Text("Reorder kg").frame(width: 96)
        }
        .font(.custom("AvenirNext-DemiBold", size: 12))
        .foregroundStyle(Palette.textMuted)
    }
}
