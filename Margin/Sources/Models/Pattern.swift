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

    // R7: Location pattern
    var isLocationBased: Bool = false
    var locationType: String?

    init(
        id: UUID = UUID(),
        trigger: String,
        thoughtCategory: String,
        patternDescription: String,
        momentCount: Int,
        confidence: Double,
        createdAt: Date = Date(),
        insights: [String] = [],
        suggestedActions: [String] = [],
        isLocationBased: Bool = false,
        locationType: String? = nil
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
        self.isLocationBased = isLocationBased
        self.locationType = locationType
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

// R7: Location Pattern — privacy-first location insights
struct LocationPattern: Identifiable, Codable, Equatable {
    let id: UUID
    var locationType: String
    var topThoughts: [String]
    var dominantMood: MoodTag?
    var momentCount: Int
    var averageTimeOfDay: String
    var privacyNote: String  // "Derived from time patterns, not GPS"

    init(
        id: UUID = UUID(),
        locationType: String,
        topThoughts: [String],
        dominantMood: MoodTag?,
        momentCount: Int,
        averageTimeOfDay: String,
        privacyNote: String = "Derived from time patterns, not GPS"
    ) {
        self.id = id
        self.locationType = locationType
        self.topThoughts = topThoughts
        self.dominantMood = dominantMood
        self.momentCount = momentCount
        self.averageTimeOfDay = averageTimeOfDay
        self.privacyNote = privacyNote
    }

    var locationEmoji: String {
        switch locationType.lowercased() {
        case "work": return "💼"
        case "home": return "🏠"
        case "transit": return "🚗"
        case "waiting": return "⏳"
        case "outdoor": return "🌳"
        case "indoor": return "🏢"
        default: return "📍"
        }
    }
}
