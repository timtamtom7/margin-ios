import SwiftUI

struct MacInsightsView: View {
    let moments: [Moment]

    private let aiService = AIService()
    private let reflectionService = AIReflectionService.shared

    // Convert moments to reflections for the AI reflection service
    private var reflections: [Reflection] {
        moments.map { moment in
            Reflection(
                id: UUID(),
                momentId: moment.id,
                text: moment.text,
                timestamp: moment.timestamp,
                moodTag: moment.moodTag,
                contextType: moment.contextType,
                timeOfDay: moment.timeOfDay,
                insightKeywords: extractKeywords(from: moment.text),
                emotionalTone: mapMoodToTone(moment.moodTag)
            )
        }
    }

    private var patterns: [Pattern] {
        aiService.analyzePatterns(moments: moments)
    }

    private var reflectionPatterns: ReflectionPatterns {
        reflectionService.analyzePatterns(reflections: reflections)
    }

    private var weatherForecast: WeatherForecast {
        reflectionService.predictEmotionalWeather(reflections: reflections)
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
                    // Your week in reflection — emotional weather
                    weatherCard

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

                    // Theme map
                    if !reflectionPatterns.recurringThemes.isEmpty {
                        themeSection
                    }
                }

                Spacer()
            }
            .padding(.bottom, 24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(MarginColors.background)
    }

    // MARK: - Weather Card

    private var weatherCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Text(weatherForecast.currentConditions.emoji)
                    .font(.system(size: 28))

                VStack(alignment: .leading, spacing: 2) {
                    Text("Your week in reflection")
                        .font(MarginFonts.caption)
                        .foregroundColor(MarginColors.secondaryText)

                    Text(weatherLabel)
                        .font(MarginFonts.subheading)
                        .foregroundColor(MarginColors.primaryText)
                }

                Spacer()

                trendIndicator
            }

            Text(weatherForecast.outlook)
                .font(MarginFonts.body)
                .foregroundColor(MarginColors.secondaryText)
                .lineSpacing(3)

            if weatherForecast.confidence > 0 {
                HStack {
                    Text("Forecast confidence")
                        .font(MarginFonts.caption)
                        .foregroundColor(MarginColors.divider)

                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(MarginColors.divider)
                                .frame(height: 4)

                            RoundedRectangle(cornerRadius: 2)
                                .fill(MarginColors.accent)
                                .frame(width: geometry.size.width * weatherForecast.confidence, height: 4)
                        }
                    }
                    .frame(height: 4)
                }
            }
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

    private var weatherLabel: String {
        switch weatherForecast.currentConditions {
        case .clear: return "Clear skies"
        case .partlyCloudy: return "Partly cloudy"
        case .overcast: return "Overcast"
        case .rain: return "Rain"
        case .storm: return "Storm"
        case .foggy: return "Foggy"
        }
    }

    @ViewBuilder
    private var trendIndicator: some View {
        switch weatherForecast.trend {
        case .improving:
            Image(systemName: "arrow.up.right")
                .foregroundColor(MarginColors.accent)
                .font(.system(size: 14, weight: .semibold))
        case .stable:
            Image(systemName: "arrow.right")
                .foregroundColor(MarginColors.secondaryText)
                .font(.system(size: 14))
        case .declining:
            Image(systemName: "arrow.down.right")
                .foregroundColor(MarginColors.destructive)
                .font(.system(size: 14, weight: .semibold))
        }
    }

    // MARK: - Narrative Card

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

    // MARK: - Stats Row

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

    // MARK: - Mood Section

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

    // MARK: - Patterns Section

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

    // MARK: - Theme Section

    private var themeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("What You Return To")
                .font(MarginFonts.subheading)
                .foregroundColor(MarginColors.primaryText)

            VStack(spacing: 8) {
                ForEach(reflectionPatterns.recurringThemes) { theme in
                    HStack {
                        Text(theme.emoji)
                            .font(.system(size: 16))

                        Text(theme.theme)
                            .font(MarginFonts.body)
                            .foregroundColor(MarginColors.primaryText)

                        Spacer()

                        Text("\(theme.frequency)×")
                            .font(MarginFonts.caption)
                            .foregroundColor(MarginColors.secondaryText)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(MarginColors.surface)
                    .cornerRadius(8)
                }
            }
        }
        .padding(.horizontal, 24)
    }

    // MARK: - Empty State

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

    // MARK: - Helpers

    private func extractKeywords(from text: String) -> [String] {
        let words = text.lowercased()
            .split(separator: " ")
            .map(String.init)
            .filter { $0.count > 4 }

        let stopWords = Set(["about", "would", "could", "should", "think", "thing", "really", "maybe", "actually", "something", "everything", "nothing"])
        return Array(Set(words).subtracting(stopWords).prefix(5))
    }

    private func mapMoodToTone(_ mood: MoodTag?) -> Reflection.EmotionalTone {
        guard let mood = mood else { return .neutral }
        switch mood {
        case .excited: return .excited
        case .hopeful: return .hopeful
        case .calm: return .calm
        case .anxious, .worried: return .anxious
        case .melancholy, .nostalgic: return .melancholy
        case .curious, .focused, .creative: return .curious
        }
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
