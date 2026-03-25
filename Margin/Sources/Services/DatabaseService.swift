import Foundation
import SQLite

final class DatabaseService {
    private var db: Connection?

    // Tables
    private let moments = Table("moments")
    private let dailyDigests = Table("daily_digests")
    private let patterns = Table("patterns")

    // Moment columns
    private let id = Expression<String>("id")
    private let text = Expression<String>("text")
    private let voicePath = Expression<String?>("voice_path")
    private let timestamp = Expression<Date>("timestamp")
    private let timeOfDay = Expression<String>("time_of_day")
    private let dayOfWeek = Expression<String>("day_of_week")
    private let contextType = Expression<String?>("context_type")
    private let locationType = Expression<String?>("location_type")
    private let reflectionPrompt = Expression<String?>("reflection_prompt")
    private let reflectionAnswer = Expression<String?>("reflection_answer")
    private let createdAt = Expression<Date>("created_at")

    // DailyDigest columns
    private let date = Expression<Date>("date")
    private let totalMoments = Expression<Int>("total_moments")
    private let estimatedDeadTimeMinutes = Expression<Int>("estimated_dead_time_minutes")
    private let topThoughtCategory = Expression<String?>("top_thought_category")
    private let topContext = Expression<String?>("top_context")
    private let summary = Expression<String>("summary")

    // Pattern columns
    private let trigger = Expression<String>("trigger")
    private let thoughtCategory = Expression<String>("thought_category")
    private let patternDescription = Expression<String>("pattern_description")
    private let momentCount = Expression<Int>("moment_count")
    private let confidence = Expression<Double>("confidence")

    init() {
        setupDatabase()
    }

    private func setupDatabase() {
        do {
            let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
            db = try Connection("\(path)/margin.sqlite3")
            try createTables()
        } catch {
            print("Database setup error: \(error)")
        }
    }

    private func createTables() throws {
        try db?.run(moments.create(ifNotExists: true) { t in
            t.column(id, primaryKey: true)
            t.column(text)
            t.column(voicePath)
            t.column(timestamp)
            t.column(timeOfDay)
            t.column(dayOfWeek)
            t.column(contextType)
            t.column(locationType)
            t.column(reflectionPrompt)
            t.column(reflectionAnswer)
            t.column(createdAt)
        })

        try db?.run(dailyDigests.create(ifNotExists: true) { t in
            t.column(id, primaryKey: true)
            t.column(date)
            t.column(totalMoments)
            t.column(estimatedDeadTimeMinutes)
            t.column(topThoughtCategory)
            t.column(topContext)
            t.column(summary)
            t.column(createdAt)
        })

        try db?.run(patterns.create(ifNotExists: true) { t in
            t.column(id, primaryKey: true)
            t.column(trigger)
            t.column(thoughtCategory)
            t.column(patternDescription)
            t.column(momentCount)
            t.column(confidence)
            t.column(createdAt)
        })
    }

    // MARK: - Moments

    func saveMoment(_ moment: Moment) throws {
        guard let db = db else { return }
        let insert = moments.insert(
            id <- moment.id.uuidString,
            text <- moment.text,
            voicePath <- moment.voicePath,
            timestamp <- moment.timestamp,
            timeOfDay <- moment.timeOfDay,
            dayOfWeek <- moment.dayOfWeek,
            contextType <- moment.contextType,
            locationType <- moment.locationType,
            reflectionPrompt <- moment.reflectionPrompt,
            reflectionAnswer <- moment.reflectionAnswer,
            createdAt <- moment.createdAt
        )
        try db.run(insert)
    }

    func fetchAllMoments() throws -> [Moment] {
        guard let db = db else { return [] }
        var result: [Moment] = []
        for row in try db.prepare(moments.order(timestamp.desc)) {
            let moment = Moment(
                id: UUID(uuidString: row[id]) ?? UUID(),
                text: row[text],
                voicePath: row[voicePath],
                timestamp: row[timestamp],
                timeOfDay: row[timeOfDay],
                dayOfWeek: row[dayOfWeek],
                contextType: row[contextType],
                locationType: row[locationType],
                reflectionPrompt: row[reflectionPrompt],
                reflectionAnswer: row[reflectionAnswer],
                createdAt: row[createdAt]
            )
            result.append(moment)
        }
        return result
    }

    func fetchMoments(for dateValue: Date) throws -> [Moment] {
        guard let db = db else { return [] }
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: dateValue)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        let query = moments.filter(timestamp >= startOfDay && timestamp < endOfDay).order(timestamp.desc)
        var result: [Moment] = []
        for row in try db.prepare(query) {
            let moment = Moment(
                id: UUID(uuidString: row[id]) ?? UUID(),
                text: row[text],
                voicePath: row[voicePath],
                timestamp: row[timestamp],
                timeOfDay: row[timeOfDay],
                dayOfWeek: row[dayOfWeek],
                contextType: row[contextType],
                locationType: row[locationType],
                reflectionPrompt: row[reflectionPrompt],
                reflectionAnswer: row[reflectionAnswer],
                createdAt: row[createdAt]
            )
            result.append(moment)
        }
        return result
    }

    func updateMomentReflection(momentId: UUID, prompt: String?, answer: String?) throws {
        guard let db = db else { return }
        let moment = moments.filter(id == momentId.uuidString)
        try db.run(moment.update(
            reflectionPrompt <- prompt,
            reflectionAnswer <- answer
        ))
    }

    func deleteMoment(id momentId: UUID) throws {
        guard let db = db else { return }
        let moment = moments.filter(id == momentId.uuidString)
        try db.run(moment.delete())
    }

    // MARK: - Daily Digests

    func saveDailyDigest(_ digest: DailyDigest) throws {
        guard let db = db else { return }
        let insert = dailyDigests.insert(
            id <- digest.id.uuidString,
            date <- digest.date,
            totalMoments <- digest.totalMoments,
            estimatedDeadTimeMinutes <- digest.estimatedDeadTimeMinutes,
            topThoughtCategory <- digest.topThoughtCategory,
            topContext <- digest.topContext,
            summary <- digest.summary,
            createdAt <- digest.createdAt
        )
        try db.run(insert)
    }

    func fetchLatestDigest() throws -> DailyDigest? {
        guard let db = db else { return nil }
        let query = dailyDigests.order(date.desc).limit(1)
        for row in try db.prepare(query) {
            return DailyDigest(
                id: UUID(uuidString: row[id]) ?? UUID(),
                date: row[date],
                totalMoments: row[totalMoments],
                estimatedDeadTimeMinutes: row[estimatedDeadTimeMinutes],
                topThoughtCategory: row[topThoughtCategory],
                topContext: row[topContext],
                summary: row[summary],
                createdAt: row[createdAt]
            )
        }
        return nil
    }

    func fetchDigest(for dateValue: Date) throws -> DailyDigest? {
        guard let db = db else { return nil }
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: dateValue)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        let query = dailyDigests.filter(date >= startOfDay && date < endOfDay)
        for row in try db.prepare(query) {
            return DailyDigest(
                id: UUID(uuidString: row[id]) ?? UUID(),
                date: row[date],
                totalMoments: row[totalMoments],
                estimatedDeadTimeMinutes: row[estimatedDeadTimeMinutes],
                topThoughtCategory: row[topThoughtCategory],
                topContext: row[topContext],
                summary: row[summary],
                createdAt: row[createdAt]
            )
        }
        return nil
    }

    // MARK: - Patterns

    func savePattern(_ pattern: Pattern) throws {
        guard let db = db else { return }
        let insert = patterns.insert(
            id <- pattern.id.uuidString,
            trigger <- pattern.trigger,
            thoughtCategory <- pattern.thoughtCategory,
            patternDescription <- pattern.patternDescription,
            momentCount <- pattern.momentCount,
            confidence <- pattern.confidence,
            createdAt <- pattern.createdAt
        )
        try db.run(insert)
    }

    func fetchAllPatterns() throws -> [Pattern] {
        guard let db = db else { return [] }
        var result: [Pattern] = []
        for row in try db.prepare(patterns.order(momentCount.desc)) {
            let pattern = Pattern(
                id: UUID(uuidString: row[id]) ?? UUID(),
                trigger: row[trigger],
                thoughtCategory: row[thoughtCategory],
                patternDescription: row[patternDescription],
                momentCount: row[momentCount],
                confidence: row[confidence],
                createdAt: row[createdAt]
            )
            result.append(pattern)
        }
        return result
    }

    func deleteAllPatterns() throws {
        guard let db = db else { return }
        try db.run(patterns.delete())
    }
}
