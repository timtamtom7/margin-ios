import SwiftUI

struct PatternCard: View {
    let pattern: Pattern
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: MarginSpacing.sm) {
            HStack {
                Text(pattern.trigger)
                    .font(MarginFonts.subheading)
                    .foregroundColor(MarginColors.primaryText)

                Spacer()

                Text(pattern.confidenceLabel)
                    .font(MarginFonts.caption)
                    .foregroundColor(MarginColors.secondaryText)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(MarginColors.divider.opacity(0.5))
                    .cornerRadius(4)
            }

            Text(pattern.patternDescription)
                .font(MarginFonts.body)
                .foregroundColor(MarginColors.secondaryText)

            HStack {
                Image(systemName: "chart.bar.fill")
                    .font(.system(size: 12))
                    .foregroundColor(MarginColors.accent)

                Text("\(pattern.momentCount) moments observed")
                    .font(MarginFonts.caption)
                    .foregroundColor(MarginColors.secondaryText)
            }
        }
        .padding(MarginSpacing.md)
        .background(MarginColors.surface)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    PatternCard(pattern: Pattern(
        trigger: "Traffic lights",
        thoughtCategory: "relationships",
        patternDescription: "When you're at traffic lights, you tend to think about relationships and people in your life.",
        momentCount: 7,
        confidence: 0.75
    ))
    .padding()
    .background(MarginColors.background)
}
