import Foundation

struct Pattern: Identifiable, Codable, Equatable {
    let id: UUID
    var trigger: String
    var thoughtCategory: String
    var patternDescription: String
    var momentCount: Int
    var confidence: Double
    let createdAt: Date

    // R2: Extended pattern info
    var insights: [String] = []
    var suggestedActions: [String] = []

    init(
        id: UUID = UUID(),
        trigger: String,
        thoughtCategory: String,
        patternDescription: String,
        momentCount: Int,
        confidence: Double,
        createdAt: Date = Date(),
        insights: [String] = [],
        suggestedActions: [String] = []
    ) {
        self.id = id
        self.trigger = trigger
        self.thoughtCategory = thoughtCategory
        self.patternDescription = patternDescription
        self.momentCount = momentCount
        self.confidence = confidence
        self.createdAt = createdAt
        self.insights = insights
        self.suggestedActions = suggestedActions
    }

    var confidenceLabel: String {
        switch confidence {
        case 0..<0.4: return "weak signal"
        case 0.4..<0.7: return "emerging pattern"
        case 0.7..<0.9: return "strong pattern"
        default: return "consistent pattern"
        }
    }

    var confidenceEmoji: String {
        switch confidence {
        case 0..<0.4: return "🔘"
        case 0.4..<0.7: return "🔶"
        case 0.7..<0.9: return "🟡"
        default: return "🟢"
        }
    }
}
