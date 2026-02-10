import Foundation
import SwiftUI
import AppKit
import UniformTypeIdentifiers

struct InventorySetting: Codable, Hashable {
    var onHandKg: Double
    var safetyStockKg: Double
}
