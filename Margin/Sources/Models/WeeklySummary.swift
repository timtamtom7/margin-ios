import Foundation

struct WeeklySummary: Identifiable, Codable, Equatable {
    let id: UUID
    let weekStartDate: Date
    let weekEndDate: Date
    var totalMoments: Int
    var totalDeadTimeMinutes: Int
    var topThoughtCategories: [String]
    var topContexts: [String]
    var topMoods: [MoodTag]
    var deepThoughtCount: Int
    var recurringThoughts: [RecurringThought]
    var weeklyInsight: String
    let createdAt: Date

    init(
        id: UUID = UUID(),
        weekStartDate: Date,
        weekEndDate: Date,
        totalMoments: Int,
        totalDeadTimeMinutes: Int,
        topThoughtCategories: [String] = [],
        topContexts: [String] = [],
        topMoods: [MoodTag] = [],
        deepThoughtCount: Int = 0,
        recurringThoughts: [RecurringThought] = [],
        weeklyInsight: String,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.weekStartDate = weekStartDate
        self.weekEndDate = weekEndDate
        self.totalMoments = totalMoments
        self.totalDeadTimeMinutes = totalDeadTimeMinutes
        self.topThoughtCategories = topThoughtCategories
        self.topContexts = topContexts
        self.topMoods = topMoods
        self.deepThoughtCount = deepThoughtCount
        self.recurringThoughts = recurringThoughts
        self.weeklyInsight = weeklyInsight
        self.createdAt = createdAt
    }

    var formattedWeekRange: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        let start = formatter.string(from: weekStartDate)
        let end = formatter.string(from: weekEndDate)
        return "\(start) – \(end)"
    }
}

struct RecurringThought: Identifiable, Codable, Equatable {
    let id: UUID
    var thoughtText: String
    var occurrenceCount: Int
    var contexts: [String]

    init(id: UUID = UUID(), thoughtText: String, occurrenceCount: Int, contexts: [String] = []) {
        self.id = id
        self.thoughtText = thoughtText
        self.occurrenceCount = occurrenceCount
        self.contexts = contexts
    }
}
