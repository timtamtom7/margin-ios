import Foundation

struct DailyDigest: Identifiable, Codable, Equatable {
    let id: UUID
    let date: Date
    var totalMoments: Int
    var estimatedDeadTimeMinutes: Int
    var topThoughtCategory: String?
    var topContext: String?
    var summary: String
    let createdAt: Date

    init(
        id: UUID = UUID(),
        date: Date = Date(),
        totalMoments: Int,
        estimatedDeadTimeMinutes: Int,
        topThoughtCategory: String? = nil,
        topContext: String? = nil,
        summary: String,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.date = date
        self.totalMoments = totalMoments
        self.estimatedDeadTimeMinutes = estimatedDeadTimeMinutes
        self.topThoughtCategory = topThoughtCategory
        self.topContext = topContext
        self.summary = summary
        self.createdAt = createdAt
    }

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter.string(from: date)
    }
}
