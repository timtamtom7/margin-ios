import Foundation

final class AIService {
    private let reflectionPrompts = [
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
        reflectionPrompts.randomElement() ?? "What were you just thinking about?"
    }

    func generateContextLabel(for timeOfDay: String, context: String?) -> String {
        if let ctx = context {
            return ctx
        }
        return timeOfDay
    }

    // MARK: - R2: Mood Detection

    func detectMood(from text: String) -> MoodTag? {
        let lowercased = text.lowercased()

        let moodIndicators: [MoodTag: [String]] = [
            .anxious: ["worried", "nervous", "stressed", "overwhelm", "anxious", "panic", "fear", "scared", "dread", "uncertain"],
            .curious: ["wonder", "curious", "how", "why", "what if", "interesting", "want to know", "fascinated", "puzzle", "figure out"],
            .creative: ["idea", "create", "build", "design", "make", "imagine", "story", "write", "art", "music", "project", "brainstorm"],
            .melancholy: ["miss", "remember", "when", "used to", "nostalgia", "long for", "gone", "lost", "regret", "sad", "sorrow"],
            .excited: ["can't wait", "excited", "amazing", "great", "awesome", "love", "incredible", "fantastic", "pumped", "thrilled"],
            .calm: ["peace", "quiet", "still", "content", "fine", "okay", "steady", "balanced", "serene"],
            .worried: ["hope", "hope not", "maybe", "might", "could go wrong", "concern", "pray", "wish", "if only"],
            .hopeful: ["someday", "one day", "goal", "dream", "plan", "looking forward", "will", "going to", "bright", "future"],
            .nostalgic: ["remember", "the time", "when i was", "miss those", "used to", "childhood", "old days", "flashback"],
            .focused: ["need to", "must", "should", "have to", "finish", "complete", "task", "goal for today", "priority", "deadline"]
        ]

        var scores: [MoodTag: Int] = [:]
        for (mood, keywords) in moodIndicators {
            let score = keywords.filter { lowercased.contains($0) }.count
            if score > 0 {
                scores[mood] = score
            }
        }

        guard let top = scores.max(by: { $0.value < $1.value }), top.value >= 1 else {
            return nil
        }
        return top.key
    }

    // MARK: - R2: Deep Thought Detection

    func isDeepThought(text: String) -> Bool {
        let lowercased = text.lowercased()

        // Indicators of genuinely novel/reflection thoughts vs routine worrying
        let deepIndicators = [
            "why do i", "what does it mean", "i wonder if", "realized", "figured out",
            "understanding", "insight", "suddenly", "occurred to me", "made me think",
            "pattern", "identity", "purpose", "meaning", "belief", "value", "choice",
            "who am i", "what if i", "who should i", "whoever", "whatever", "paradox",
            "contradiction", "reconcile", "actually", "genuinely", "truly", "honestly",
            "i've been thinking", "it hit me", "came to realize", "dawned on me",
            "suprised", "unexpected", "paradox", "perspective", "reframe", "rethink",
            "paradox", "tension between", "weighing", "balancing", "nuance", "subtle"
        ]

        let routineIndicators = [
            "todo", "email", "meeting", "reply", "send", "call", "text", "message",
            "schedule", "appointment", "deadline today", "finish", "complete task",
            "what to eat", "lunch", "dinner", "breakfast", "grocery", "shopping list"
        ]

        let deepScore = deepIndicators.filter { lowercased.contains($0) }.count
        let routineScore = routineIndicators.filter { lowercased.contains($0) }.count

        // A thought is "deep" if it has deep indicators and is not primarily routine
        return deepScore >= 2 || (deepScore >= 1 && routineScore == 0)
    }

    // MARK: - R2: Thread Detection

    func detectThread(moment: Moment, recentMoments: [Moment]) -> (threadId: UUID, previousMomentId: UUID)? {
        // Look at recent moments (within last 2 hours) for similar themes
        let twoHoursAgo = Date().addingTimeInterval(-2 * 60 * 60)
        let recentRelevant = recentMoments.filter { $0.timestamp > twoHoursAgo && $0.id != moment.id }

        for recent in recentRelevant {
            if isThreadContinuation(moment.text, previousText: recent.text) {
                let threadId = recent.threadId ?? recent.id
                return (threadId, recent.id)
            }
        }

        return nil
    }

    private func isThreadContinuation(_ newText: String, previousText: String) -> Bool {
        let newWords = Set(newText.lowercased().split(separator: " ").map(String.init))
        let prevWords = Set(previousText.lowercased().split(separator: " ").map(String.init))

        // Find meaningful overlap (excluding common words)
        let stopWords = Set(["the", "a", "an", "is", "are", "was", "were", "i", "you", "he", "she", "it", "we", "they", "to", "and", "or", "but", "in", "on", "at", "for", "of", "with", "my", "your", "this", "that", "what", "how", "when", "where", "be", "have", "has", "had", "do", "did", "does", "not", "just", "about", "so", "if", "as"])
        let meaningfulNew = newWords.subtracting(stopWords)
        let meaningfulPrev = prevWords.subtracting(stopWords)

        let overlap = meaningfulNew.intersection(meaningfulPrev)

        // Need at least 2 meaningful overlapping words OR one significant phrase
        if overlap.count >= 2 {
            return true
        }

        // Check for question continuation
        if newText.contains("?") || previousText.contains("?") {
            let questionWords = ["why", "how", "what", "when", "where", "should", "could", "would", "whether"]
            let newHasQ = questionWords.contains { newText.lowercased().contains($0) }
            let prevHasQ = questionWords.contains { previousText.lowercased().contains($0) }
            if newHasQ && prevHasQ && !overlap.isEmpty {
                return true
            }
        }

        return false
    }

    func generateThreadTitle(_ moments: [Moment]) -> String? {
        guard moments.count >= 2 else { return nil }
        let combinedText = moments.map { $0.text }.joined(separator: " ")
        let firstFew = String(combinedText.prefix(50))
        if firstFew.count < combinedText.count {
            return firstFew + "..."
        }
        return firstFew
    }

    // MARK: - R2: Location Pattern Insights

    func generateLocationInsight(moments: [Moment]) -> String? {
        let withLocation = moments.filter { $0.locationType != nil }
        guard withLocation.count >= 3 else { return nil }

        let byLocation = Dictionary(grouping: withLocation) { $0.locationType ?? "unknown" }
        guard let topLocation = byLocation.max(by: { $0.value.count < $1.value.count }),
              byLocation[topLocation.key]!.count >= 2 else { return nil }

        let thoughtsByLocation = Dictionary(grouping: byLocation[topLocation.key]!) { categorizeSimpleThought($0.text) }
        guard let topThought = thoughtsByLocation.max(by: { $0.value.count < $1.value.count })?.key else { return nil }

        let locationLabel = topLocation.key.capitalized
        return "You think about \(topThought.lowercased()) most when you're at \(locationLabel.lowercased())."
    }

    private func categorizeSimpleThought(_ text: String) -> String {
        let lower = text.lowercased()
        if lower.contains("work") || lower.contains("project") || lower.contains("deadline") || lower.contains("meeting") {
            return "work"
        } else if lower.contains("person") || lower.contains("friend") || lower.contains("love") || lower.contains("family") {
            return "relationships"
        } else if lower.contains("future") || lower.contains("dream") || lower.contains("goal") || lower.contains("plan") {
            return "the future"
        } else if lower.contains("remember") || lower.contains("past") || lower.contains("when i") {
            return "the past"
        }
        return "general thoughts"
    }

    // MARK: - Pattern Analysis (enhanced for R2)

    func analyzePatterns(moments: [Moment]) -> [Pattern] {
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

            // R2: Generate insights for the pattern
            let insights = generateInsightsForPattern(context: context, moments: contextMoments, category: topCategory.key)
            let actions = generateSuggestedActions(category: topCategory.key)

            let pattern = Pattern(
                trigger: triggerDescription,
                thoughtCategory: topCategory.key,
                patternDescription: "When you're in \(triggerDescription.lowercased()), you tend to think about \(topCategory.key.lowercased()).",
                momentCount: contextMoments.count,
                confidence: confidence,
                insights: insights,
                suggestedActions: actions
            )
            patterns.append(pattern)
        }

        // R2: Mood-based patterns
        let moodGroups = Dictionary(grouping: moments.filter { $0.moodTag != nil }) { $0.moodTag! }
        for (mood, moodMoments) in moodGroups {
            guard moodMoments.count >= 3 else { continue }
            let contexts = Set(moodMoments.compactMap { $0.contextType })
            if contexts.count >= 2 {
                let confidence = min(1.0, Double(moodMoments.count) / 10.0)
                let pattern = Pattern(
                    trigger: "your \(mood.displayName.lowercased()) mood",
                    thoughtCategory: "emotional awareness",
                    patternDescription: "When you're feeling \(mood.displayName.lowercased()), you tend to reflect more deeply.",
                    momentCount: moodMoments.count,
                    confidence: confidence,
                    insights: ["Mood pattern detected across \(contexts.count) different contexts"],
                    suggestedActions: []
                )
                patterns.append(pattern)
            }
        }

        return patterns
    }

    private func generateInsightsForPattern(context: String, moments: [Moment], category: String) -> [String] {
        var insights: [String] = []
        let deepThoughts = moments.filter { $0.isDeepThought }.count
        if deepThoughts > 0 {
            insights.append("\(deepThoughts) of these were deep thoughts")
        }

        let moodCounts = Dictionary(grouping: moments.compactMap { $0.moodTag }) { $0 }.mapValues { $0.count }
        if let topMood = moodCounts.max(by: { $0.value < $1.value }) {
            insights.append("Your dominant mood here: \(topMood.key.displayName)")
        }

        if moments.count >= 5 {
            insights.append("This is one of your most frequent contexts")
        }

        return insights
    }

    private func generateSuggestedActions(category: String) -> [String] {
        switch category {
        case "work": return ["Try setting a 'done thinking about it' boundary"]
        case "relationships": return ["Consider journaling about what this person means to you"]
        case "future": return ["Write down one concrete step toward this goal"]
        case "self": return ["This thought might be worth exploring further"]
        default: return []
        }
    }

    private func categorizeThoughts(from text: String) -> [String: Int] {
        let categories: [String: [String]] = [
            "work": ["project", "deadline", "meeting", "boss", "colleague", "email", "task", "office", "presentation", "client", "presentation"],
            "relationships": ["friend", "partner", "family", "love", "date", "relationship", "marriage", "baby", "kids", "parents", "person"],
            "future": ["plan", "dream", "goal", "someday", "when i", "if only", "should", "want to", "hope", "fear", "future"],
            "past": ["remember", "when i used to", "miss", "regret", "wish i", "nostalgia", "the time", "old days"],
            "self": ["i'm", "i feel", "my life", "who i", "what i", "myself", "body", "health", "tired", "anxious", "myself"],
            "creative": ["idea", "write", "create", "make", "build", "design", "art", "music", "story", "storytelling", "project"]
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
        case let c where c.contains("transit") || c.contains("traffic") || c.contains("red light") || c.contains("uber") || c.contains("bus"):
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

    // MARK: - R2: Weekly Summary

    func generateWeeklySummary(moments: [Moment]) -> WeeklySummary {
        let calendar = Calendar.current
        let today = Date()
        let weekday = calendar.component(.weekday, from: today)
        let daysFromMonday = (weekday + 5) % 7
        let weekStart = calendar.date(byAdding: .day, value: -daysFromMonday, to: calendar.startOfDay(for: today))!
        let weekEnd = calendar.date(byAdding: .day, value: 6, to: weekStart)!

        let weekMoments = moments.filter { $0.timestamp >= weekStart && $0.timestamp <= weekEnd }

        let totalMoments = weekMoments.count
        let estimatedMinutes = totalMoments * 2

        let allText = weekMoments.compactMap { $0.text }.joined(separator: " ").lowercased()
        let topCategories = categorizeThoughts(from: allText)
            .sorted { $0.value > $1.value }
            .prefix(3)
            .map { $0.key }

        let contextCounts = Dictionary(grouping: weekMoments.compactMap { $0.contextType }) { $0 }
            .mapValues { $0.count }
        let topContexts = contextCounts.sorted { $0.value > $1.value }.prefix(3).map { $0.key }

        let moodCounts = Dictionary(grouping: weekMoments.compactMap { $0.moodTag }) { $0 }
            .mapValues { $0.count }
        let topMoods = moodCounts.sorted { $0.value > $1.value }.prefix(3).map { $0.key }

        let deepThoughtCount = weekMoments.filter { $0.isDeepThought }.count

        // Find recurring thoughts
        let recurringThoughts = findRecurringThoughts(moments: weekMoments)

        let weeklyInsight = buildWeeklyInsight(
            moments: weekMoments,
            totalMinutes: estimatedMinutes,
            topCategories: Array(topCategories),
            deepThoughtCount: deepThoughtCount,
            recurringThoughts: recurringThoughts
        )

        return WeeklySummary(
            weekStartDate: weekStart,
            weekEndDate: weekEnd,
            totalMoments: totalMoments,
            totalDeadTimeMinutes: estimatedMinutes,
            topThoughtCategories: Array(topCategories),
            topContexts: topContexts,
            topMoods: topMoods,
            deepThoughtCount: deepThoughtCount,
            recurringThoughts: recurringThoughts,
            weeklyInsight: weeklyInsight
        )
    }

    private func findRecurringThoughts(moments: [Moment]) -> [RecurringThought] {
        // Simple recurrence detection: find thoughts with similar words
        var seen: [String: (count: Int, contexts: Set<String>)] = [:]

        for moment in moments {
            let words = Set(moment.text.lowercased()
                .split(separator: " ")
                .map(String.init)
                .filter { $0.count > 4 })

            for word in words {
                let stopWords = ["about", "would", "could", "should", "think", "thing", "really", "maybe", "actually"]
                if stopWords.contains(word) { continue }

                if seen[word] != nil {
                    seen[word]!.count += 1
                    if let ctx = moment.contextType {
                        seen[word]!.contexts.insert(ctx)
                    }
                } else {
                    var contexts: Set<String> = []
                    if let ctx = moment.contextType {
                        contexts.insert(ctx)
                    }
                    seen[word] = (1, contexts)
                }
            }
        }

        return seen
            .filter { $0.value.count >= 3 }
            .sorted { $0.value.count > $1.value.count }
            .prefix(5)
            .map { RecurringThought(thoughtText: "thoughts about '\($0.key)'", occurrenceCount: $0.value.count, contexts: Array($0.value.contexts)) }
    }

    private func buildWeeklyInsight(moments: [Moment], totalMinutes: Int, topCategories: [String], deepThoughtCount: Int, recurringThoughts: [RecurringThought]) -> String {
        var parts: [String] = []

        if totalMinutes > 0 {
            parts.append("This week you captured \(moments.count) moments, about \(totalMinutes) minutes of dead time.")
        }

        if !topCategories.isEmpty {
            let top = topCategories.first ?? "various things"
            parts.append("Most of your thoughts were about \(top).")
        }

        if deepThoughtCount > 0 {
            parts.append("\(deepThoughtCount) were genuine deep thoughts — moments of real reflection.")
        }

        if let firstRecurring = recurringThoughts.first {
            parts.append("Your most recurring thought theme appeared \(firstRecurring.occurrenceCount) times this week.")
        }

        return parts.joined(separator: " ")
    }

    // MARK: - R2: Daily Digest (enhanced)

    func generateDailyDigest(moments: [Moment]) -> DailyDigest {
        let totalMoments = moments.count
        let estimatedMinutes = totalMoments * 2

        let allText = moments.compactMap { $0.text }.joined(separator: " ").lowercased()
        let topCategory = categorizeThoughts(from: allText).max(by: { $0.value < $1.value })?.key ?? "various thoughts"

        let contextCounts = Dictionary(grouping: moments.compactMap { $0.contextType }) { $0 }
            .mapValues { $0.count }
        let topContext = contextCounts.max(by: { $0.value < $1.value })?.key

        let summary: String
        if totalMoments == 0 {
            summary = "No moments captured yet today."
        } else {
            var parts = ["Today you had \(totalMoments) micro-moments, about \(estimatedMinutes) minutes of dead time.", "You thought most about \(topCategory)."]
            if let ctx = topContext {
                parts.append("Most of these happened at \(ctx).")
            }

            // R2: Add mood summary
            let moods = moments.compactMap { $0.moodTag }
            if !moods.isEmpty {
                let moodCounts = Dictionary(grouping: moods) { $0 }.mapValues { $0.count }
                if let topMood = moodCounts.max(by: { $0.value < $1.value }) {
                    parts.append("You were mostly \(topMood.key.displayName.lowercased()).")
                }
            }

            summary = parts.joined(separator: " ")
        }

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
