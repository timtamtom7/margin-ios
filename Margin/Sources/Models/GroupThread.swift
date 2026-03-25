import Foundation

// R9: Small Group Threads — private shared threads among a trusted circle
struct GroupThread: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var memberCount: Int
    var memberInitials: [String]
    var momentCount: Int
    var lastActivityAt: Date
    var isJoined: Bool
    let createdAt: Date

    // R9: Shared moments in this group
    var sharedMomentIds: [UUID]

    init(
        id: UUID = UUID(),
        name: String,
        memberCount: Int = 2,
        memberInitials: [String] = [],
        momentCount: Int = 0,
        lastActivityAt: Date = Date(),
        isJoined: Bool = true,
        createdAt: Date = Date(),
        sharedMomentIds: [UUID] = []
    ) {
        self.id = id
        self.name = name
        self.memberCount = memberCount
        self.memberInitials = memberInitials
        self.momentCount = momentCount
        self.lastActivityAt = lastActivityAt
        self.isJoined = isJoined
        self.createdAt = createdAt
        self.sharedMomentIds = sharedMomentIds
    }

    var timeAgo: String {
        let interval = Date().timeIntervalSince(lastActivityAt)
        if interval < 60 {
            return "just now"
        } else if interval < 3600 {
            return "\(Int(interval / 60))m ago"
        } else if interval < 86400 {
            return "\(Int(interval / 3600))h ago"
        } else {
            return "\(Int(interval / 86400))d ago"
        }
    }
}

// R9: Shared moment within a group thread
struct GroupSharedMoment: Identifiable, Codable, Equatable {
    let id: UUID
    var text: String
    var moodTag: MoodTag?
    var contextType: String?
    var fromName: String  // Display name within group
    var fromInitials: String
    var timestamp: Date
    var likeCount: Int
    var hasReplied: Bool

    init(
        id: UUID = UUID(),
        text: String,
        moodTag: MoodTag? = nil,
        contextType: String? = nil,
        fromName: String = "You",
        fromInitials: String = "Y",
        timestamp: Date = Date(),
        likeCount: Int = 0,
        hasReplied: Bool = false
    ) {
        self.id = id
        self.text = text
        self.moodTag = moodTag
        self.contextType = contextType
        self.fromName = fromName
        self.fromInitials = fromInitials
        self.timestamp = timestamp
        self.likeCount = likeCount
        self.hasReplied = hasReplied
    }

    var timeAgo: String {
        let interval = Date().timeIntervalSince(timestamp)
        if interval < 60 {
            return "just now"
        } else if interval < 3600 {
            return "\(Int(interval / 60))m ago"
        } else if interval < 86400 {
            return "\(Int(interval / 3600))h ago"
        } else {
            return "\(Int(interval / 86400))d ago"
        }
    }
}
