import Foundation

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
        createdAt: Date = Date()
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
}
