import SwiftUI

extension View {
    func marginCard() -> some View {
        self
            .background(MarginColors.surface)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
    }

    func marginTextStyle() -> some View {
        self
            .font(MarginFonts.body)
            .foregroundColor(MarginColors.primaryText)
    }

    func marginSecondaryTextStyle() -> some View {
        self
            .font(MarginFonts.caption)
            .foregroundColor(MarginColors.secondaryText)
    }
}
