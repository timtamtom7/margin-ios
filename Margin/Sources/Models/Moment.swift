import Foundation

enum MoodTag: String, Codable, CaseIterable {
    case anxious = "anxious"
    case curious = "curious"
    case creative = "creative"
    case melancholy = "melancholy"
    case excited = "excited"
    case calm = "calm"
    case worried = "worried"
    case hopeful = "hopeful"
    case nostalgic = "nostalgic"
    case focused = "focused"

    var emoji: String {
        switch self {
        case .anxious: return "😰"
        case .curious: return "🤔"
        case .creative: return "💡"
        case .melancholy: return "😢"
        case .excited: return "✨"
        case .calm: return "😌"
        case .worried: return "😟"
        case .hopeful: return "🌱"
        case .nostalgic: return "📼"
        case .focused: return "🎯"
        }
    }

    var displayName: String {
        rawValue.capitalized
    }
}

struct Moment: Identifiable, Codable, Equatable {
    let id: UUID
    var text: String
    var voicePath: String?
    let timestamp: Date
    var timeOfDay: String
    var dayOfWeek: String
    var contextType: String?
    var locationType: String?
    var reflectionPrompt: String?
    var reflectionAnswer: String?
    let createdAt: Date

    // R2: Deep thought detection
    var isDeepThought: Bool = false

    // R2: Mood tag
    var moodTag: MoodTag?

    // R2: Moment threads
    var threadId: UUID?
    var previousMomentId: UUID?
    var isAbandonedThread: Bool = false

    init(
        id: UUID = UUID(),
        text: String,
        voicePath: String? = nil,
        timestamp: Date = Date(),
        timeOfDay: String,
        dayOfWeek: String,
        contextType: String? = nil,
        locationType: String? = nil,
        reflectionPrompt: String? = nil,
        reflectionAnswer: String? = nil,
        createdAt: Date = Date(),
        isDeepThought: Bool = false,
        moodTag: MoodTag? = nil,
        threadId: UUID? = nil,
        previousMomentId: UUID? = nil,
        isAbandonedThread: Bool = false
    ) {
        self.id = id
        self.text = text
        self.voicePath = voicePath
        self.timestamp = timestamp
        self.timeOfDay = timeOfDay
        self.dayOfWeek = dayOfWeek
        self.contextType = contextType
        self.locationType = locationType
        self.reflectionPrompt = reflectionPrompt
        self.reflectionAnswer = reflectionAnswer
        self.createdAt = createdAt
        self.isDeepThought = isDeepThought
        self.moodTag = moodTag
        self.threadId = threadId
        self.previousMomentId = previousMomentId
        self.isAbandonedThread = isAbandonedThread
    }

    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: timestamp)
    }

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter.string(from: timestamp)
    }

    var contextLabel: String {
        if let ctx = contextType {
            return ctx
        }
        return timeOfDay
    }

    var locationLabel: String? {
        guard let lt = locationType else { return nil }
        switch lt.lowercased() {
        case "work": return "💼 Work"
        case "home": return "🏠 Home"
        case "transit": return "🚗 Transit"
        case "waiting": return "⏳ Waiting"
        case "outdoor": return "🌳 Outdoor"
        case "indoor": return "🏢 Indoor"
        default: return lt
        }
    }
}
