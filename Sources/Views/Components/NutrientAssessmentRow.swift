import Foundation
import SwiftUI
import AppKit
import UniformTypeIdentifiers

struct NutrientAssessmentRow: View {
    let assessment: NutrientAssessment

    private var targetText: String {
        switch (assessment.minTarget, assessment.maxTarget) {
        case let (minTarget?, maxTarget?):
            return "\(formatted(minTarget)) to \(formatted(maxTarget)) \(assessment.key.unit)"
        case let (minTarget?, nil):
            return ">= \(formatted(minTarget)) \(assessment.key.unit)"
        case let (nil, maxTarget?):
            return "<= \(formatted(maxTarget)) \(assessment.key.unit)"
        default:
            return "disabled"
        }
    }

    private var statusColor: Color {
        assessment.isGood ? Palette.pine : Palette.amber
    }

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: assessment.isGood ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundStyle(statusColor)

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(assessment.key.title)
                        .foregroundStyle(Palette.textPrimary)
                    Spacer()
                    Text(formatted(assessment.achieved) + " " + assessment.key.unit)
                        .font(.custom("AvenirNext-Medium", size: 11))
                        .foregroundStyle(Palette.textMuted)
                        .monospacedDigit()
                }

                Text("Target: \(targetText)")
                    .font(.custom("AvenirNext-Medium", size: 11))
                    .foregroundStyle(Palette.textMuted)
            }
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

    private func formatted(_ value: Double) -> String {
        String(format: "%.*f", assessment.key.decimals, value)
    }
}
