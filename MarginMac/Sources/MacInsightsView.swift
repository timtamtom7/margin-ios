import SwiftUI

struct MacInsightsView: View {
    let moments: [Moment]

    private let aiService = AIService()

    private var patterns: [Pattern] {
        aiService.analyzePatterns(moments: moments)
    }

    private var dailyDigest: DailyDigest {
        aiService.generateDailyDigest(moments: moments)
    }

    private var weeklyNarrative: String {
        aiService.generateWeeklyNarrative(moments: moments)
    }

    private var moodTrend: [(MoodTag, Int)] {
        let moodCounts = Dictionary(grouping: moments.compactMap { $0.moodTag }) { $0 }
            .mapValues { $0.count }
        return moodCounts.sorted { $0.value > $1.value }.prefix(5).map { ($0.key, $0.value) }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                Text("Insights")
                    .font(MarginFonts.heading)
                    .foregroundColor(MarginColors.primaryText)
                    .padding(.horizontal, 24)
                    .padding(.top, 20)

                if moments.isEmpty {
                    emptyState
                } else {
                    // Weekly narrative
                    narrativeCard

                    // Stats row
                    statsRow

                    // Mood trend
                    if !moodTrend.isEmpty {
                        moodSection
                    }

                    // Patterns
                    if !patterns.isEmpty {
                        patternsSection
                    }
                }

                Spacer()
            }
            .padding(.bottom, 24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(MarginColors.background)
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "lightbulb")
                .font(.system(size: 40))
                .foregroundColor(MarginColors.divider)

            VStack(spacing: 8) {
                Text("Patterns emerge over time")
                    .font(MarginFonts.subheading)
                    .foregroundColor(MarginColors.primaryText)

                Text("Keep capturing moments and AI will discover what your mind returns to.")
                    .font(MarginFonts.body)
                    .foregroundColor(MarginColors.secondaryText)
                    .multilineTextAlignment(.center)
            }
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 40)
    }

    private var narrativeCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 6) {
                Image(systemName: "text.book.closed")
                    .font(.system(size: 12))
                Text("This Week")
                    .font(MarginFonts.caption)
            }
            .foregroundColor(MarginColors.accentSecondary)

            Text(weeklyNarrative)
                .font(MarginFonts.handwritten)
                .foregroundColor(MarginColors.primaryText)
                .lineSpacing(4)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(MarginColors.surface)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(MarginColors.divider, lineWidth: 1)
        )
        .padding(.horizontal, 24)
    }

    private var statsRow: some View {
        HStack(spacing: 12) {
            InsightStatCard(
                title: "Moments",
                value: "\(moments.count)",
                subtitle: "captured"
            )

            InsightStatCard(
                title: "Dead Time",
                value: "\(moments.count * 2)",
                subtitle: "minutes"
            )

            InsightStatCard(
                title: "Deep Thoughts",
                value: "\(moments.filter { $0.isDeepThought }.count)",
                subtitle: "worth exploring"
            )
        }
        .padding(.horizontal, 24)
    }

    private var moodSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Mood Trends")
                .font(MarginFonts.subheading)
                .foregroundColor(MarginColors.primaryText)

            HStack(spacing: 12) {
                ForEach(moodTrend.prefix(5), id: \.0) { mood, count in
                    VStack(spacing: 6) {
                        Text(mood.emoji)
                            .font(.system(size: 24))

                        Text("\(count)")
                            .font(MarginFonts.caption)
                            .foregroundColor(MarginColors.secondaryText)

                        Text(mood.displayName)
                            .font(MarginFonts.caption)
                            .foregroundColor(MarginColors.primaryText)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(MarginColors.surface)
                    .cornerRadius(8)
                }
            }
        }
        .padding(.horizontal, 24)
    }

    private var patternsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Patterns")
                .font(MarginFonts.subheading)
                .foregroundColor(MarginColors.primaryText)

            ForEach(patterns.prefix(5)) { pattern in
                PatternInsightRow(pattern: pattern)
            }
        }
        .padding(.horizontal, 24)
    }
}

// MARK: - Insight Stat Card

struct InsightStatCard: View {
    let title: String
    let value: String
    let subtitle: String

    var body: some View {
        VStack(spacing: 6) {
            Text(title)
                .font(MarginFonts.caption)
                .foregroundColor(MarginColors.secondaryText)

            Text(value)
                .font(.custom("Georgia", size: 32, relativeTo: .title2))
                .foregroundColor(MarginColors.accent)

            Text(subtitle)
                .font(MarginFonts.caption)
                .foregroundColor(MarginColors.secondaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(MarginColors.surface)
        .cornerRadius(8)
    }
}

// MARK: - Pattern Insight Row

struct PatternInsightRow: View {
    let pattern: Pattern

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(pattern.confidenceEmoji)
                    .font(.system(size: 14))

                Text(pattern.trigger.capitalized)
                    .font(MarginFonts.body)
                    .foregroundColor(MarginColors.primaryText)

                Spacer()

                Text(pattern.confidenceLabel)
                    .font(MarginFonts.caption)
                    .foregroundColor(MarginColors.secondaryText)
            }

            Text(pattern.patternDescription)
                .font(MarginFonts.body)
                .foregroundColor(MarginColors.secondaryText)
                .lineLimit(2)

            if !pattern.insights.isEmpty {
                HStack(spacing: 6) {
                    ForEach(pattern.insights.prefix(2), id: \.self) { insight in
                        Text(insight)
                            .font(MarginFonts.caption)
                            .foregroundColor(MarginColors.accentSecondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(MarginColors.accentSecondary.opacity(0.1))
                            .cornerRadius(4)
                    }
                }
            }
        }
        .padding(16)
        .background(MarginColors.surface)
        .cornerRadius(8)
    }
}

#Preview {
    MacInsightsView(moments: [])
}
