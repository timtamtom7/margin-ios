import SwiftUI

extension View {
    func marginCard() -> some View {
        self
            .background(MarginColors.surface)
            .cornerRadius(Theme.CornerRadius.md)
            .shadow(color: Theme.Shadow.card.color, radius: Theme.Shadow.card.radius, x: Theme.Shadow.card.x, y: Theme.Shadow.card.y)
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
