import SwiftUI

// MARK: - DesignSystem.swift
// ⚠️ DEPRECATED — All tokens have moved to Theme.swift
// This file is kept for backward compatibility during migration.
// Please use Theme.Colors, Theme.Typography, Theme.Spacing, Theme.Haptic directly.

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

// Backward-compatible aliases — delegate to Theme
enum MarginColors {
    static let background = Theme.Colors.background
    static let surface = Theme.Colors.surface
    static let primaryText = Theme.Colors.primaryText
    static let secondaryText = Theme.Colors.secondaryText
    static let accent = Theme.Colors.accent
    static let accentSecondary = Theme.Colors.accentSecondary
    static let destructive = Theme.Colors.destructive
    static let divider = Theme.Colors.divider
}

enum MarginFonts {
    static let heading = Theme.Typography.heading
    static let subheading = Theme.Typography.subheading
    static let body = Theme.Typography.body
    static let caption = Theme.Typography.caption
    static let handwritten = Theme.Typography.handwritten
}

enum MarginSpacing {
    static let xs: CGFloat = Theme.Spacing.xs
    static let sm: CGFloat = Theme.Spacing.sm
    static let md: CGFloat = Theme.Spacing.md
    static let lg: CGFloat = Theme.Spacing.lg
    static let xl: CGFloat = Theme.Spacing.xl
    static let xxl: CGFloat = Theme.Spacing.xxl
}
