import Foundation
import SwiftUI
import AppKit
import UniformTypeIdentifiers

struct SectionCard<Content: View>: View {
    let title: String
    let subtitle: String
    let accent: Color
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.custom("AvenirNext-DemiBold", size: 18))
                    .foregroundStyle(Palette.textPrimary)
                Text(subtitle)
                    .font(.custom("AvenirNext-Regular", size: 13))
                    .foregroundStyle(Palette.textMuted)
            }
            content
                .foregroundStyle(Palette.textPrimary)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Palette.cardSoft)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Palette.border, lineWidth: 1)
        )
        .overlay(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 2, style: .continuous)
                .fill(accent)
                .frame(width: 84, height: 4)
                .padding(.leading, 14)
                .padding(.top, 10)
        }
    }
}
