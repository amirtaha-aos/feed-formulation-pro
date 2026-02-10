import Foundation
import SwiftUI
import AppKit
import UniformTypeIdentifiers

struct SolutionBanner: View {
    let solution: RationSolution

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: solution.status == .feasible ? "checkmark.seal.fill" : "exclamationmark.triangle.fill")
                .foregroundStyle(solution.status == .feasible ? Palette.pine : Palette.amber)
            Text(solution.message)
                .font(.custom("AvenirNext-Medium", size: 13))
                .foregroundStyle(Palette.textPrimary)
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(solution.status == .feasible ? Palette.pine.opacity(0.18) : Palette.amber.opacity(0.20))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(
                    solution.status == .feasible ? Palette.pine.opacity(0.65) : Palette.amber.opacity(0.65),
                    lineWidth: 1
                )
        )
    }
}
