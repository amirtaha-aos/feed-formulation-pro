import Foundation
import SwiftUI
import AppKit
import UniformTypeIdentifiers

struct ConstraintHeaderRow: View {
    var body: some View {
        HStack(spacing: 8) {
            Text("Nutrient").frame(width: 220, alignment: .leading)
            Text("Unit").frame(width: 80)
            Text("Min").frame(width: 44)
            Text("Min Value").frame(width: 100)
            Text("Max").frame(width: 44)
            Text("Max Value").frame(width: 100)
        }
        .font(.custom("AvenirNext-DemiBold", size: 12))
        .foregroundStyle(Palette.textMuted)
    }
}
