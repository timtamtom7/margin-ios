import Foundation
import NaturalLanguage

// MARK: - Reflection Types

/// A micro-reflection entry — derived from a Moment with optional AI-generated insight
struct Reflection: Identifiable, Codable, Sendable {
    let id: UUID
    let momentId: UUID
    let text: String
    let timestamp: Date
    let moodTag: MoodTag?
    let contextType: String?
    let timeOfDay: String
    let insightKeywords: [String]
    let emotionalTone: EmotionalTone

    enum EmotionalTone: String, Codable, Sendable {
        case hopeful, anxious, curious, calm, melancholy, excited, neutral
    }
}

/// Aggregated patterns discovered from a collection of reflections
struct ReflectionPatterns: Identifiable, Codable, Sendable {
    let id: UUID
    let analyzedAt: Date
    let totalReflections: Int
    let dominantMood: MoodTag?
    let emotionalTone: Reflection.EmotionalTone
    let recurringThemes: [ThemeEntry]
    let timeHotspots: [TimeHotspot]
    let crossContextInsights: [String]

    struct ThemeEntry: Identifiable, Codable, Sendable {
        let id: UUID
        let theme: String
        let frequency: Int
        let emoji: String
    }

    struct TimeHotspot: Codable, Sendable {
        let timeOfDay: String
        let reflectionCount: Int
        let dominantTheme: String
    }
}

/// A forecast of emotional weather based on reflection history
struct WeatherForecast: Codable, Sendable {
    let generatedAt: Date
    let currentConditions: WeatherCondition
    let trend: WeatherTrend
    let outlook: String
    let confidence: Double

    enum WeatherCondition: String, Codable, Sendable {
        case clear, partlyCloudy, overcast, rain, storm, foggy

        var emoji: String {
            switch self {
            case .clear: return "☀️"
            case .partlyCloudy: return "⛅"
            case .overcast: return "☁️"
            case .rain: return "🌧️"
            case .storm: return "⛈️"
            case .foggy: return "🌫️"
            }
        }
    }

    enum WeatherTrend: String, Codable, Sendable {
        case improving, stable, declining
    }
}

// MARK: - AI Reflection Service

final class AIReflectionService: @unchecked Sendable {
    static let shared = AIReflectionService()

    private init() {}

    // MARK: - Sentiment Analysis

    private func analyzeSentiment(_ text: String) -> Double {
        // Keyword-based sentiment scoring
        let lower = text.lowercased()

        let positiveWords = [
            "happy", "excited", "great", "amazing", "love", "wonderful", "fantastic",
            "grateful", "blessed", "joy", "peaceful", "calm", "hopeful", "beautiful",
            "awesome", "incredible", "good", "best", "thrilled", "bright"
        ]
        let negativeWords = [
            "sad", "anxious", "worried", "stressed", "terrible", "awful", "hate",
            "fear", "dread", "overwhelmed", "tired", "exhausted", "lost", "regret",
            "angry", "frustrated", "confused", "stuck", "broken", "heavy", "scared"
        ]
        let questionWords = ["why", "how", "what if", "should i", "could i", "wonder"]

        var score: Double = 0
        for word in positiveWords where lower.contains(word) { score += 0.15 }
        for word in negativeWords where lower.contains(word) { score -= 0.15 }
        for word in questionWords where lower.contains(word) { score -= 0.05 }

        return max(-1.0, min(1.0, score))
    }

    // MARK: - Public API

    /// Analyze patterns across a collection of reflections
    func analyzePatterns(reflections: [Reflection]) -> ReflectionPatterns {
        guard !reflections.isEmpty else {
            return emptyPatterns()
        }

        let dominantMood = findDominantMood(reflections)
        let emotionalTone = inferEmotionalTone(reflections)
        let themes = extractRecurringThemes(reflections)
        let hotspots = findTimeHotspots(reflections)
        let crossContext = generateCrossContextInsights(reflections)

        return ReflectionPatterns(
            id: UUID(),
            analyzedAt: Date(),
            totalReflections: reflections.count,
            dominantMood: dominantMood,
            emotionalTone: emotionalTone,
            recurringThemes: themes,
            timeHotspots: hotspots,
            crossContextInsights: crossContext
        )
    }

    /// Predict emotional weather based on reflection history
    func predictEmotionalWeather(reflections: [Reflection]) -> WeatherForecast {
        guard !reflections.isEmpty else {
            return WeatherForecast(
                generatedAt: Date(),
                currentConditions: .clear,
                trend: .stable,
                outlook: "No reflections yet — start capturing moments to see your emotional forecast.",
                confidence: 0
            )
        }

        let recentReflections = getRecentReflections(reflections, days: 7)
        let olderReflections = getOlderReflections(reflections, range: 14..<30)

        let conditions = determineConditions(reflections: recentReflections)
        let trend = determineTrend(recent: recentReflections, older: olderReflections)
        let outlook = generateOutlook(reflections: recentReflections, conditions: conditions, trend: trend)
        let confidence = min(1.0, Double(reflections.count) / 20.0)

        return WeatherForecast(
            generatedAt: Date(),
            currentConditions: conditions,
            trend: trend,
            outlook: outlook,
            confidence: confidence
        )
    }

    // MARK: - Private Helpers

    private func emptyPatterns() -> ReflectionPatterns {
        ReflectionPatterns(
            id: UUID(),
            analyzedAt: Date(),
            totalReflections: 0,
            dominantMood: nil,
            emotionalTone: .neutral,
            recurringThemes: [],
            timeHotspots: [],
            crossContextInsights: []
        )
    }

    private func findDominantMood(_ reflections: [Reflection]) -> MoodTag? {
        let moodCounts = Dictionary(grouping: reflections.compactMap { $0.moodTag }) { $0 }
            .mapValues { $0.count }
        return moodCounts.max(by: { $0.value < $1.value })?.key
    }

    private func inferEmotionalTone(_ reflections: [Reflection]) -> Reflection.EmotionalTone {
        let scores = reflections.map { analyzeSentiment($0.text) }
        let avg = scores.reduce(0, +) / Double(max(1, scores.count))

        if avg > 0.3 { return .excited }
        if avg > 0.1 { return .hopeful }
        if avg > -0.1 { return .calm }
        if avg > -0.3 { return .curious }
        if avg > -0.6 { return .anxious }
        return .melancholy
    }

    private func extractRecurringThemes(_ reflections: [Reflection]) -> [ReflectionPatterns.ThemeEntry] {
        var themeCounts: [String: Int] = [:]

        let themeKeywords: [String: [String]] = [
            "work": ["project", "deadline", "meeting", "boss", "colleague", "task", "office"],
            "relationships": ["friend", "partner", "family", "love", "date", "marriage", "baby", "parents", "person"],
            "future": ["plan", "dream", "goal", "someday", "when i", "if only", "hope", "fear", "future"],
            "past": ["remember", "when i used to", "miss", "regret", "wish i", "nostalgia", "old days"],
            "self": ["i'm", "i feel", "my life", "who i", "what i", "myself", "health", "tired", "anxious"],
            "creative": ["idea", "write", "create", "make", "build", "design", "art", "music", "story"],
            "health": ["sleep", "tired", "energy", "exercise", "body", "sick", "headache", "rest"]
        ]

        for reflection in reflections {
            let text = reflection.text.lowercased()
            for (theme, keywords) in themeKeywords {
                let matchCount = keywords.filter { text.contains($0) }.count
                if matchCount > 0 {
                    themeCounts[theme, default: 0] += matchCount
                }
            }
        }

        let themeEmojis: [String: String] = [
            "work": "💼", "relationships": "💜", "future": "🌱", "past": "📼",
            "self": "🪞", "creative": "💡", "health": "🌿"
        ]

        return themeCounts
            .sorted { $0.value > $1.value }
            .prefix(5)
            .map { theme, count in
                ReflectionPatterns.ThemeEntry(
                    id: UUID(),
                    theme: theme.capitalized,
                    frequency: count,
                    emoji: themeEmojis[theme] ?? "•"
                )
            }
    }

    private func findTimeHotspots(_ reflections: [Reflection]) -> [ReflectionPatterns.TimeHotspot] {
        let byTime = Dictionary(grouping: reflections) { $0.timeOfDay }
        return byTime.compactMap { time, refs in
            guard !refs.isEmpty else { return nil }
            let topTheme = refs.compactMap { $0.insightKeywords.first }.first ?? "thoughts"
            return ReflectionPatterns.TimeHotspot(
                timeOfDay: time,
                reflectionCount: refs.count,
                dominantTheme: topTheme
            )
        }.sorted { $0.reflectionCount > $1.reflectionCount }
    }

    private func generateCrossContextInsights(_ reflections: [Reflection]) -> [String] {
        var insights: [String] = []

        // Cross-context theme detection
        let byContext = Dictionary(grouping: reflections.filter { $0.contextType != nil }) { $0.contextType! }
        let contexts = Array(byContext.keys)

        if contexts.count >= 2 {
            insights.append("Your thoughts shift across \(contexts.count) different contexts.")
        }

        // Emotional consistency check
        let tones = reflections.map { $0.emotionalTone }
        let toneCounts = Dictionary(grouping: tones) { $0 }.mapValues { $0.count }
        if let dominant = toneCounts.max(by: { $0.value < $1.value }), dominant.value > reflections.count / 2 {
            insights.append("Your emotional tone has been predominantly \(dominant.key.rawValue) lately.")
        }

        // Deep reflection indicator
        let hopefulCount = reflections.filter { $0.emotionalTone == .hopeful }.count
        if hopefulCount > reflections.count / 3 {
            insights.append("You've been leaning hopeful — that's a generative space to be in.")
        }

        let anxiousCount = reflections.filter { $0.emotionalTone == .anxious }.count
        if anxiousCount > reflections.count / 3 {
            insights.append("Some anxiety has been present — that's often the mind working through something.")
        }

        return insights
    }

    private func getRecentReflections(_ reflections: [Reflection], days: Int) -> [Reflection] {
        let cutoff = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        return reflections.filter { $0.timestamp > cutoff }
    }

    private func getOlderReflections(_ reflections: [Reflection], range: Range<Int>) -> [Reflection] {
        let now = Date()
        guard let start = Calendar.current.date(byAdding: .day, value: -range.upperBound, to: now),
              let end = Calendar.current.date(byAdding: .day, value: -range.lowerBound, to: now) else {
            return []
        }
        return reflections.filter { $0.timestamp >= start && $0.timestamp < end }
    }

    private func determineConditions(reflections: [Reflection]) -> WeatherForecast.WeatherCondition {
        guard !reflections.isEmpty else { return .clear }

        let toneCounts = Dictionary(grouping: reflections.map { $0.emotionalTone }) { $0 }
            .mapValues { $0.count }
        guard let dominant = toneCounts.max(by: { $0.value < $1.value })?.key else { return .clear }

        let sentimentScores = reflections.map { analyzeSentiment($0.text) }
        let avgSentiment = sentimentScores.isEmpty ? 0 : sentimentScores.reduce(0, +) / Double(sentimentScores.count)

        switch dominant {
        case .excited, .hopeful:
            return avgSentiment > 0.2 ? .clear : .partlyCloudy
        case .calm, .curious:
            return .partlyCloudy
        case .neutral:
            return avgSentiment > 0 ? .partlyCloudy : .overcast
        case .anxious:
            return avgSentiment > -0.4 ? .overcast : .rain
        case .melancholy:
            return avgSentiment > -0.3 ? .overcast : .rain
        }
    }

    private func determineTrend(recent: [Reflection], older: [Reflection]) -> WeatherForecast.WeatherTrend {
        guard !recent.isEmpty, !older.isEmpty else { return .stable }

        let recentAvg = recent.map { analyzeSentiment($0.text) }.reduce(0, +) / Double(max(1, recent.count))
        let olderAvg = older.map { analyzeSentiment($0.text) }.reduce(0, +) / Double(max(1, older.count))

        let delta = recentAvg - olderAvg
        if delta > 0.15 { return .improving }
        if delta < -0.15 { return .declining }
        return .stable
    }

    private func generateOutlook(reflections: [Reflection], conditions: WeatherForecast.WeatherCondition, trend: WeatherForecast.WeatherTrend) -> String {
        var parts: [String] = []

        switch trend {
        case .improving:
            parts.append("Your emotional weather is trending brighter.")
        case .stable:
            parts.append("Your emotional weather has been steady.")
        case .declining:
            parts.append("The skies are darker than usual — be gentle with yourself.")
        }

        switch conditions {
        case .clear:
            parts.append("You've been in a clear space — good for seeing what's actually there.")
        case .partlyCloudy:
            parts.append("A mix of sun and clouds. Not bad, not bright — just real.")
        case .overcast:
            parts.append("Some heaviness in the air. This often passes.")
        case .rain:
            parts.append("Rain clears the air. Let it fall.")
        case .storm:
            parts.append("A storm is passing through. Stay inside if you can.")
        case .foggy:
            parts.append("Some fog — things will become clearer in time.")
        }

        if reflections.count >= 10 {
            parts.append("You've captured \(reflections.count) reflections this week — that's real attention to your inner life.")
        }

        return parts.joined(separator: " ")
    }
}
