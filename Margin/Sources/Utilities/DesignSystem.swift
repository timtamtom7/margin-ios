import SwiftUI

enum MarginColors {
    static let background = Color(hex: "F5F2EB")
    static let surface = Color(hex: "FDFCF8")
    static let primaryText = Color(hex: "2C2A26")
    static let secondaryText = Color(hex: "7A776F")
    static let accent = Color(hex: "C4A882")
    static let accentSecondary = Color(hex: "9AAEAB")
    static let destructive = Color(hex: "C0736A")
    static let divider = Color(hex: "E0DDD4")
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

enum MarginFonts {
    static let heading = Font.custom("Georgia", size: 28, relativeTo: .title)
    static let subheading = Font.custom("Georgia", size: 20, relativeTo: .title2)
    static let body = Font.system(size: 16, design: .default)
    static let caption = Font.system(size: 13, weight: .light)
    static let handwritten = Font.system(size: 15, design: .default).italic()
}

enum MarginSpacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
}
