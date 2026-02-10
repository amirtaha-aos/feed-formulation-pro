import Foundation
import SwiftUI
import AppKit
import UniformTypeIdentifiers

struct QualityAlert: Identifiable {
    let id = UUID()
    let severity: QualitySeverity
    let message: String
}
