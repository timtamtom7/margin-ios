import SwiftUI

struct DailyDigestCard: View {
    let digest: DailyDigest

    var body: some View {
        VStack(alignment: .leading, spacing: MarginSpacing.md) {
            HStack {
                Text("Today's Margin")
                    .font(MarginFonts.subheading)
                    .foregroundColor(MarginColors.primaryText)

                Spacer()

                Text(digest.formattedDate)
                    .font(MarginFonts.caption)
                    .foregroundColor(MarginColors.secondaryText)
            }

            HStack(spacing: MarginSpacing.lg) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(digest.totalMoments)")
                        .font(.system(size: 32, weight: .light, design: .serif))
                        .foregroundColor(MarginColors.accent)
                    Text("moments")
                        .font(MarginFonts.caption)
                        .foregroundColor(MarginColors.secondaryText)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("\(digest.estimatedDeadTimeMinutes)")
                        .font(.system(size: 32, weight: .light, design: .serif))
                        .foregroundColor(MarginColors.accent)
                    Text("minutes")
                        .font(MarginFonts.caption)
                        .foregroundColor(MarginColors.secondaryText)
                }

                if let category = digest.topThoughtCategory {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(category.prefix(10))
                            .font(.system(size: 20, weight: .light, design: .serif))
                            .foregroundColor(MarginColors.accentSecondary)
                        Text("top thought")
                            .font(MarginFonts.caption)
                            .foregroundColor(MarginColors.secondaryText)
                    }
                }
            }

            Divider()
                .background(MarginColors.divider)

            Text(digest.summary)
                .font(MarginFonts.handwritten)
                .foregroundColor(MarginColors.secondaryText)
                .italic()
        }
        .padding(MarginSpacing.lg)
        .background(MarginColors.surface)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 3)
    }
}

#Preview {
    DailyDigestCard(digest: DailyDigest(
        date: Date(),
        totalMoments: 12,
        estimatedDeadTimeMinutes: 24,
        topThoughtCategory: "work",
        topContext: "afternoon",
        summary: "Today you had 12 micro-moments, about 24 minutes of dead time. You thought most about work. Most of these happened in the afternoon."
    ))
    .padding()
    .background(MarginColors.background)
}
