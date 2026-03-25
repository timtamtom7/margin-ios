import Foundation
import AppleIntelligence

final class AIService {
    private let prompts = [
        "What were you just thinking about?",
        "Was that a worry or a hope?",
        "Did that thought surprise you?",
        "What's the feeling underneath that thought?",
        "Where does that thought usually lead you?",
        "Is this something you think about often?",
        "What would it feel like to let that go?",
        "Does that connect to anything else on your mind?"
    ]

    func generateReflectionPrompt() -> String {
        prompts.randomElement() ?? "What were you just thinking about?"
    }

    func generateContextLabel(for timeOfDay: String, context: String?) -> String {
        if let ctx = context {
            return ctx
        }
        return timeOfDay
    }

    func analyzePatterns(moments: [Moment]) async -> [Pattern] {
        guard moments.count >= 3 else { return [] }

        var patterns: [Pattern] = []
        let contextGroups = Dictionary(grouping: moments) { $0.contextType ?? "unknown" }

        for (context, contextMoments) in contextGroups {
            guard contextMoments.count >= 2 else { continue }

            let wordCounts = contextMoments.compactMap { $0.text }
            let allText = wordCounts.joined(separator: " ").lowercased()

            let thoughtCategories = categorizeThoughts(from: allText)
            guard let topCategory = thoughtCategories.max(by: { $0.value < $1.value }),
                  topCategory.value >= 2 else { continue }

            let confidence = min(1.0, Double(topCategory.value) / Double(contextMoments.count) * 1.5)

            let triggerDescription = formatTrigger(context)
            let pattern = Pattern(
                trigger: triggerDescription,
                thoughtCategory: topCategory.key,
                patternDescription: "When you're in \(triggerDescription.lowercased()), you tend to think about \(topCategory.key.lowercased()).",
                momentCount: contextMoments.count,
                confidence: confidence
            )
            patterns.append(pattern)
        }

        return patterns
    }

    private func categorizeThoughts(from text: String) -> [String: Int] {
        let categories: [String: [String]] = [
            "work": ["project", "deadline", "meeting", "boss", "colleague", "email", "task", "office", "presentation", "client"],
            "relationships": ["friend", "partner", "family", "love", "date", "relationship", "marriage", "baby", "kids", "parents"],
            "future": ["plan", "dream", "goal", "someday", "when i", "if only", "should", "want to", "hope", "fear"],
            "past": ["remember", "when i used to", "miss", "regret", "wish i", "nostalgia", "the time"],
            "self": ["i'm", "i feel", "my life", "who i", "what i", "myself", "body", "health", "tired", "anxious"],
            "creative": ["idea", "write", "create", "make", "build", "design", "art", "music", "story", "storytelling"]
        ]

        var counts: [String: Int] = [:]
        for (category, keywords) in categories {
            let count = keywords.filter { text.contains($0) }.count
            if count > 0 {
                counts[category] = count
            }
        }

        if counts.isEmpty {
            counts["general"] = 1
        }

        return counts
    }

    private func formatTrigger(_ context: String) -> String {
        switch context.lowercased() {
        case let c where c.contains("transit") || c.contains("traffic") || c.contains("red light") || c.contains("uber"):
            return "traffic"
        case let c where c.contains("waiting") || c.contains("line") || c.contains("queue"):
            return "waiting rooms"
        case let c where c.contains("coffee") || c.contains("cafe"):
            return "coffee shops"
        case let c where c.contains("elevator"):
            return "elevators"
        case let c where c.contains("morning"):
            return "mornings"
        case let c where c.contains("evening") || c.contains("night"):
            return "evenings"
        case let c where c.contains("lunch") || c.contains("break"):
            return "breaks"
        default:
            return context.isEmpty ? "general moments" : context
        }
    }

    func generateDailyDigest(moments: [Moment]) async -> DailyDigest {
        let totalMoments = moments.count
        let estimatedMinutes = totalMoments * 2

        let allText = moments.compactMap { $0.text }.joined(separator: " ").lowercased()
        let topCategory = categorizeThoughts(from: allText).max(by: { $0.value < $1.value })?.key ?? "various thoughts"

        let contextCounts = Dictionary(grouping: moments.compactMap { $0.contextType }) { $0 }
            .mapValues { $0.count }
        let topContext = contextCounts.max(by: { $0.value < $1.value })?.key

        let summary = "Today you had \(totalMoments) micro-moments, about \(estimatedMinutes) minutes of dead time. You thought most about \(topCategory).\(topContext != nil ? " Most of these happened at \(topContext!)." : "")"

        return DailyDigest(
            date: Date(),
            totalMoments: totalMoments,
            estimatedDeadTimeMinutes: estimatedMinutes,
            topThoughtCategory: topCategory,
            topContext: topContext,
            summary: summary
        )
    }
}
