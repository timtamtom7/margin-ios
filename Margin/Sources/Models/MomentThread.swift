import Foundation

struct MomentThread: Identifiable, Codable, Equatable {
    let id: UUID
    var momentIds: [UUID]
    var title: String?
    var createdAt: Date
    var lastUpdatedAt: Date
    var isActive: Bool

    init(
        id: UUID = UUID(),
        momentIds: [UUID] = [],
        title: String? = nil,
        createdAt: Date = Date(),
        lastUpdatedAt: Date = Date(),
        isActive: Bool = true
    ) {
        self.id = id
        self.momentIds = momentIds
        self.title = title
        self.createdAt = createdAt
        self.lastUpdatedAt = lastUpdatedAt
        self.isActive = isActive
    }
}

// R2: Anonymous Social — Shared Moment (public feed item)
struct SharedMoment: Identifiable, Codable, Equatable {
    let id: UUID
    var text: String
    var contextType: String?
    var locationType: String?
    var moodTag: MoodTag?
    var timestamp: Date
    var likeCount: Int
    var replyCount: Int

    init(
        id: UUID = UUID(),
        text: String,
        contextType: String? = nil,
        locationType: String? = nil,
        moodTag: MoodTag? = nil,
        timestamp: Date = Date(),
        likeCount: Int = 0,
        replyCount: Int = 0
    ) {
        self.id = id
        self.text = text
        self.contextType = contextType
        self.locationType = locationType
        self.moodTag = moodTag
        self.timestamp = timestamp
        self.likeCount = likeCount
        self.replyCount = replyCount
    }

    var timeAgo: String {
        let interval = Date().timeIntervalSince(timestamp)
        if interval < 60 {
            return "just now"
        } else if interval < 3600 {
            let mins = Int(interval / 60)
            return "\(mins)m ago"
        } else if interval < 86400 {
            let hours = Int(interval / 3600)
            return "\(hours)h ago"
        } else {
            let days = Int(interval / 86400)
            return "\(days)d ago"
        }
    }
}
