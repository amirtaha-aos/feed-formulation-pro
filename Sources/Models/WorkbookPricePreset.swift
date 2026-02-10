import Foundation
import SwiftUI
import AppKit
import UniformTypeIdentifiers

struct WorkbookPricePreset: Hashable, Identifiable {
    let name: String
    let prices: [String: Double]
    var id: String { name }
}
