import Foundation
import SwiftUI
import AppKit
import UniformTypeIdentifiers

struct MRPHeaderRow: View {
    var body: some View {
        HStack(spacing: 8) {
            Text("Ingredient").frame(width: 190, alignment: .leading)
            Text("Group").frame(width: 110)
            Text("Daily").frame(width: 76)
            Text("Lead").frame(width: 76)
            Text("Safety").frame(width: 76)
            Text("On Hand").frame(width: 86)
            Text("Reorder").frame(width: 88)
            Text("Cover").frame(width: 72)
        }
        .font(.custom("AvenirNext-DemiBold", size: 12))
        .foregroundStyle(Palette.textMuted)
    }
}
