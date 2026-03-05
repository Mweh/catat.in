import Foundation

struct CustomCategory: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var name: String
    var icon: String       // SF Symbol name
    var colorName: String  // Named color key (see CategoryColor enum)

    static let builtIn: [CustomCategory] = [
        CustomCategory(name: "Makanan",      icon: "fork.knife",   colorName: "orange"),
        CustomCategory(name: "Transportasi", icon: "car.fill",     colorName: "blue"),
        CustomCategory(name: "Belanja",      icon: "bag.fill",     colorName: "purple"),
    ]
}

enum CategoryColor: String, CaseIterable {
    case orange, blue, purple, green, red, pink, teal, indigo

    var displayName: String { rawValue.capitalized }

    var swiftUIColor: SwiftUIColorBox {
        switch self {
        case .orange: return SwiftUIColorBox(.orange)
        case .blue:   return SwiftUIColorBox(.blue)
        case .purple: return SwiftUIColorBox(.purple)
        case .green:  return SwiftUIColorBox(.green)
        case .red:    return SwiftUIColorBox(.red)
        case .pink:   return SwiftUIColorBox(.pink)
        case .teal:   return SwiftUIColorBox(.teal)
        case .indigo: return SwiftUIColorBox(.indigo)
        }
    }
}

// Lightweight wrapper so we can pass SwiftUI Color from the enum
import SwiftUI
struct SwiftUIColorBox {
    let color: Color
    init(_ color: Color) { self.color = color }
}

extension String {
    /// Convert stored colorName string → SwiftUI Color
    var categoryColor: Color {
        CategoryColor(rawValue: self)?.swiftUIColor.color ?? .gray
    }
}
