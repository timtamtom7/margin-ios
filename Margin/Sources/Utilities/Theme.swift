import SwiftUI

// MARK: - Theme — iOS 26 Liquid Glass Design System
// Centralizes all design tokens: corner radius, typography, colors, haptics, spacing

enum Theme {

    // MARK: - Corner Radius Tokens

    enum CornerRadius {
        /// Extra small: 4pt — badges, tags
        static let xs: CGFloat = 4
        /// Small: 8pt — pills, compact elements
        static let sm: CGFloat = 8
        /// Medium: 12pt — cards, inputs
        static let md: CGFloat = 12
        /// Large: 16pt — modals, large cards
        static let lg: CGFloat = 16
        /// Extra large: 20pt — feature cards
        static let xl: CGFloat = 20
    }

    // MARK: - Typography Tokens

    enum Typography {
        /// Minimum accessible font size (11pt)
        static let minSize: CGFloat = 11

        /// Heading: 28pt Georgia
        static let heading = SwiftUI.Font.custom("Georgia", size: 28, relativeTo: .title)
        /// Subheading: 20pt Georgia
        static let subheading = SwiftUI.Font.custom("Georgia", size: 20, relativeTo: .title2)
        /// Body: 16pt SF Pro
        static let body = SwiftUI.Font.system(size: 16, design: .default)
        /// Caption: 13pt SF Pro Light
        static let caption = SwiftUI.Font.system(size: 13, weight: .light)
        /// Handwritten: 15pt italic
        static let handwritten = SwiftUI.Font.system(size: 15, design: .default).italic()
    }

    // MARK: - Color Tokens

    enum Colors {
        static let background = Color(hex: "F5F2EB")
        static let surface = Color(hex: "FDFCF8")
        static let primaryText = Color(hex: "2C2A26")
        static let secondaryText = Color(hex: "7A776F")
        static let accent = Color(hex: "C4A882")
        static let accentSecondary = Color(hex: "9AAEAB")
        static let destructive = Color(hex: "C0736A")
        static let divider = Color(hex: "E0DDD4")
    }

    // MARK: - Spacing Tokens

    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
    }

    // MARK: - Shadow Tokens

    enum Shadow {
        static let card = (color: Color.black.opacity(0.04), radius: CGFloat(4), x: CGFloat(0), y: CGFloat(2))
        static let elevated = (color: Color.black.opacity(0.06), radius: CGFloat(8), x: CGFloat(0), y: CGFloat(4))
        static let button = (color: Color.black.opacity(0.1), radius: CGFloat(2), x: CGFloat(0), y: CGFloat(1))
    }

    // MARK: - Haptic Feedback

    enum Haptic {
        /// Light impact — subtle UI feedback
        @MainActor
        static func light() {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        }

        /// Medium impact — button presses, toggles
        @MainActor
        static func medium() {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
        }

        /// Heavy impact — significant actions
        @MainActor
        static func heavy() {
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.impactOccurred()
        }

        /// Selection feedback — picker/tab changes
        @MainActor
        static func selection() {
            let generator = UISelectionFeedbackGenerator()
            generator.selectionChanged()
        }

        /// Success notification
        @MainActor
        static func success() {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        }

        /// Warning notification
        @MainActor
        static func warning() {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.warning)
        }

        /// Error notification
        @MainActor
        static func error() {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
        }
    }

    // MARK: - Animation Tokens

    enum Animation {
        static let quick = SwiftUI.Animation.easeInOut(duration: 0.15)
        static let standard = SwiftUI.Animation.easeInOut(duration: 0.25)
        static let slow = SwiftUI.Animation.easeInOut(duration: 0.4)
        static let spring = SwiftUI.Animation.spring(response: 0.3, dampingFraction: 0.7)
    }
}
