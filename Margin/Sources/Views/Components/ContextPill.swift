import SwiftUI

struct ContextPill: View {
    let label: String

    var body: some View {
        HStack(spacing: 4) {
            Text(label)
                .font(MarginFonts.caption)
                .foregroundColor(MarginColors.accentSecondary)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(MarginColors.accentSecondary.opacity(0.15))
        .cornerRadius(12)
    }
}

#Preview {
    ContextPill(label: "☕ Coffee shop")
        .padding()
}
