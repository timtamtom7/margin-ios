import Foundation
import SQLite

final class DatabaseService {
    private var db: Connection?

    // Tables
    private let moments = Table("moments")
    private let dailyDigests = Table("daily_digests")
    private let patterns = Table("patterns")
    private let weeklySummaries = Table("weekly_summaries")
    private let threads = Table("threads")

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

    // R2 Moment columns
    private let isDeepThought = Expression<Bool>("is_deep_thought")
    private let moodTag = Expression<String?>("mood_tag")
    private let threadId = Expression<String?>("thread_id")
    private let previousMomentId = Expression<String?>("previous_moment_id")
    private let isAbandonedThread = Expression<Bool>("is_abandoned_thread")

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

    // R2 Pattern columns
    private let insights = Expression<String>("insights")
    private let suggestedActions = Expression<String>("suggested_actions")

    // WeeklySummary columns
    private let weekStartDate = Expression<Date>("week_start_date")
    private let weekEndDate = Expression<Date>("week_end_date")
    private let topThoughtCategoriesJSON = Expression<String>("top_thought_categories")
    private let topContextsJSON = Expression<String>("top_contexts")
    private let topMoodsJSON = Expression<String>("top_moods")
    private let deepThoughtCount = Expression<Int>("deep_thought_count")
    private let recurringThoughtsJSON = Expression<String>("recurring_thoughts")
    private let weeklyInsight = Expression<String>("weekly_insight")

    // Thread columns
    private let momentIdsJSON = Expression<String>("moment_ids")
    private let threadTitle = Expression<String?>("title")
    private let lastUpdatedAt = Expression<Date>("last_updated_at")
    private let isActive = Expression<Bool>("is_active")

    init() {
        setupDatabase()
    }

    private func setupDatabase() {
        do {
            let documentsPath: String
            if let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first {
                documentsPath = path
            } else if let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                documentsPath = url.path
            } else {
                documentsPath = NSTemporaryDirectory()
            }
            db = try Connection("\(documentsPath)/margin.sqlite3")
            try createTables()
        } catch {
            print("Database setup error: \(error)")
        }
    }

    private func createTables() throws {
        // Moments table with R2 columns
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
            t.column(isDeepThought, defaultValue: false)
            t.column(moodTag)
            t.column(threadId)
            t.column(previousMomentId)
            t.column(isAbandonedThread, defaultValue: false)
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
            t.column(insights, defaultValue: "[]")
            t.column(suggestedActions, defaultValue: "[]")
        })

        try db?.run(weeklySummaries.create(ifNotExists: true) { t in
            t.column(id, primaryKey: true)
            t.column(weekStartDate)
            t.column(weekEndDate)
            t.column(totalMoments)
            t.column(estimatedDeadTimeMinutes)
            t.column(topThoughtCategoriesJSON, defaultValue: "[]")
            t.column(topContextsJSON, defaultValue: "[]")
            t.column(topMoodsJSON, defaultValue: "[]")
            t.column(deepThoughtCount, defaultValue: 0)
            t.column(recurringThoughtsJSON, defaultValue: "[]")
            t.column(weeklyInsight)
            t.column(createdAt)
        })

        try db?.run(threads.create(ifNotExists: true) { t in
            t.column(id, primaryKey: true)
            t.column(momentIdsJSON, defaultValue: "[]")
            t.column(threadTitle)
            t.column(createdAt)
            t.column(lastUpdatedAt)
            t.column(isActive, defaultValue: true)
        })
    }

    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    // MARK: - Moments

    func saveMoment(_ moment: Moment) throws {
        guard let db = db else {
            let nsError = NSError(domain: "DatabaseService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Database connection not available"])
            throw nsError
        }
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
            createdAt <- moment.createdAt,
            isDeepThought <- moment.isDeepThought,
            moodTag <- moment.moodTag?.rawValue,
            threadId <- moment.threadId?.uuidString,
            previousMomentId <- moment.previousMomentId?.uuidString,
            isAbandonedThread <- moment.isAbandonedThread
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
                createdAt: row[createdAt],
                isDeepThought: row[isDeepThought],
                moodTag: row[moodTag].flatMap { MoodTag(rawValue: $0) },
                threadId: row[threadId].flatMap { UUID(uuidString: $0) },
                previousMomentId: row[previousMomentId].flatMap { UUID(uuidString: $0) },
                isAbandonedThread: row[isAbandonedThread]
            )
            result.append(moment)
        }
        return result
    }

    func fetchMoments(for dateValue: Date) throws -> [Moment] {
        guard let db = db else { return [] }
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: dateValue)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? startOfDay
        let query = moments.filter(timestamp >= startOfDay && timestamp < endOfDay).order(timestamp.desc)
        var result: [Moment] = []
        for row in try db.prepare(query) {
            let moment = momentFromRow(row)
            result.append(moment)
        }
        return result
    }

    func fetchMoments(inThread threadIdentifier: UUID) throws -> [Moment] {
        guard let db = db else { return [] }
        let query = moments.filter(threadId == threadIdentifier.uuidString).order(timestamp.asc)
        var result: [Moment] = []
        for row in try db.prepare(query) {
            result.append(momentFromRow(row))
        }
        return result
    }

    func fetchRecentMoments(limit: Int = 5) throws -> [Moment] {
        guard let db = db else { return [] }
        var result: [Moment] = []
        for row in try db.prepare(moments.order(timestamp.desc).limit(limit)) {
            result.append(momentFromRow(row))
        }
        return result
    }

    private func momentFromRow(_ row: Row) -> Moment {
        Moment(
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
            createdAt: row[createdAt],
            isDeepThought: row[isDeepThought],
            moodTag: row[moodTag].flatMap { MoodTag(rawValue: $0) },
            threadId: row[threadId].flatMap { UUID(uuidString: $0) },
            previousMomentId: row[previousMomentId].flatMap { UUID(uuidString: $0) },
            isAbandonedThread: row[isAbandonedThread]
        )
    }

    func updateMomentReflection(momentId: UUID, prompt: String?, answer: String?) throws {
        guard let db = db else { return }
        let moment = moments.filter(id == momentId.uuidString)
        try db.run(moment.update(
            reflectionPrompt <- prompt,
            reflectionAnswer <- answer
        ))
    }

    func updateMomentThread(momentId: UUID, newThreadId: UUID?, prevId: UUID?) throws {
        guard let db = db else { return }
        let moment = moments.filter(id == momentId.uuidString)
        try db.run(moment.update(
            threadId <- newThreadId?.uuidString,
            previousMomentId <- prevId?.uuidString
        ))
    }

    func updateMomentMood(momentId: UUID, mood: MoodTag?) throws {
        guard let db = db else { return }
        let moment = moments.filter(id == momentId.uuidString)
        try db.run(moment.update(moodTag <- mood?.rawValue))
    }

    func updateMomentDeepThought(momentId: UUID, isDeep: Bool) throws {
        guard let db = db else { return }
        let moment = moments.filter(id == momentId.uuidString)
        try db.run(moment.update(isDeepThought <- isDeep))
    }

    func markAbandonedThreads(daysThreshold: Int = 3) throws {
        guard let db = db else { return }
        let thresholdDate = Calendar.current.date(byAdding: .day, value: -daysThreshold, to: Date()) ?? Date()
        // Find threads not updated in threshold days
        let oldThreads = try db.prepare(threads.filter(lastUpdatedAt < thresholdDate && isActive == true))
        for threadRow in oldThreads {
            if let threadIdStr = try? threadRow.get(id),
               UUID(uuidString: threadIdStr) != nil {
                // Mark all moments in this thread as abandoned
                let threadMoments = moments.filter(self.threadId == threadIdStr)
                try db.run(threadMoments.update(isAbandonedThread <- true))
                // Deactivate thread
                let thread = threads.filter(id == threadIdStr)
                try db.run(thread.update(isActive <- false))
            }
        }
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
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? startOfDay
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
        let insightsJSON = (try? encoder.encode(pattern.insights)).flatMap { String(data: $0, encoding: .utf8) } ?? "[]"
        let actionsJSON = (try? encoder.encode(pattern.suggestedActions)).flatMap { String(data: $0, encoding: .utf8) } ?? "[]"
        let insert = patterns.insert(
            id <- pattern.id.uuidString,
            trigger <- pattern.trigger,
            thoughtCategory <- pattern.thoughtCategory,
            patternDescription <- pattern.patternDescription,
            momentCount <- pattern.momentCount,
            confidence <- pattern.confidence,
            createdAt <- pattern.createdAt,
            insights <- insightsJSON,
            suggestedActions <- actionsJSON
        )
        try db.run(insert)
    }

    func fetchAllPatterns() throws -> [Pattern] {
        guard let db = db else { return [] }
        var result: [Pattern] = []
        for row in try db.prepare(patterns.order(momentCount.desc)) {
            let insightsStr = row[insights]
            let actionsStr = row[suggestedActions]
            let decodedInsights = (try? decoder.decode([String].self, from: Data(insightsStr.utf8))) ?? []
            let decodedActions = (try? decoder.decode([String].self, from: Data(actionsStr.utf8))) ?? []

            let pattern = Pattern(
                id: UUID(uuidString: row[id]) ?? UUID(),
                trigger: row[trigger],
                thoughtCategory: row[thoughtCategory],
                patternDescription: row[patternDescription],
                momentCount: row[momentCount],
                confidence: row[confidence],
                createdAt: row[createdAt],
                insights: decodedInsights,
                suggestedActions: decodedActions
            )
            result.append(pattern)
        }
        return result
    }

    func deleteAllPatterns() throws {
        guard let db = db else { return }
        try db.run(patterns.delete())
    }

    // MARK: - Weekly Summaries

    func saveWeeklySummary(_ summary: WeeklySummary) throws {
        guard let db = db else { return }
        let categoriesJSON = (try? encoder.encode(summary.topThoughtCategories)).flatMap { String(data: $0, encoding: .utf8) } ?? "[]"
        let contextsJSON = (try? encoder.encode(summary.topContexts)).flatMap { String(data: $0, encoding: .utf8) } ?? "[]"
        let moodsJSON = (try? encoder.encode(summary.topMoods)).flatMap { String(data: $0, encoding: .utf8) } ?? "[]"
        let recurringJSON = (try? encoder.encode(summary.recurringThoughts)).flatMap { String(data: $0, encoding: .utf8) } ?? "[]"

        let insert = weeklySummaries.insert(
            id <- summary.id.uuidString,
            weekStartDate <- summary.weekStartDate,
            weekEndDate <- summary.weekEndDate,
            totalMoments <- summary.totalMoments,
            estimatedDeadTimeMinutes <- summary.totalDeadTimeMinutes,
            topThoughtCategoriesJSON <- categoriesJSON,
            topContextsJSON <- contextsJSON,
            topMoodsJSON <- moodsJSON,
            deepThoughtCount <- summary.deepThoughtCount,
            recurringThoughtsJSON <- recurringJSON,
            weeklyInsight <- summary.weeklyInsight,
            createdAt <- summary.createdAt
        )
        try db.run(insert)
    }

    func fetchLatestWeeklySummary() throws -> WeeklySummary? {
        guard let db = db else { return nil }
        let query = weeklySummaries.order(weekStartDate.desc).limit(1)
        for row in try db.prepare(query) {
            return weeklySummaryFromRow(row)
        }
        return nil
    }

    func fetchWeeklySummary(forWeekContaining dateValue: Date) throws -> WeeklySummary? {
        guard let db = db else { return nil }
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: dateValue)
        let daysFromMonday = (weekday + 5) % 7
        let weekStart = calendar.date(byAdding: .day, value: -daysFromMonday, to: calendar.startOfDay(for: dateValue)) ?? Date()

        let query = weeklySummaries.filter(weekStartDate == weekStart)
        for row in try db.prepare(query) {
            return weeklySummaryFromRow(row)
        }
        return nil
    }

    private func weeklySummaryFromRow(_ row: Row) -> WeeklySummary {
        let categoriesStr = row[topThoughtCategoriesJSON]
        let contextsStr = row[topContextsJSON]
        let moodsStr = row[topMoodsJSON]
        let recurringStr = row[recurringThoughtsJSON]

        let categories = (try? decoder.decode([String].self, from: Data(categoriesStr.utf8))) ?? []
        let contexts = (try? decoder.decode([String].self, from: Data(contextsStr.utf8))) ?? []
        let moods = (try? decoder.decode([MoodTag].self, from: Data(moodsStr.utf8))) ?? []
        let recurring = (try? decoder.decode([RecurringThought].self, from: Data(recurringStr.utf8))) ?? []

        return WeeklySummary(
            id: UUID(uuidString: row[id]) ?? UUID(),
            weekStartDate: row[weekStartDate],
            weekEndDate: row[weekEndDate],
            totalMoments: row[totalMoments],
            totalDeadTimeMinutes: row[estimatedDeadTimeMinutes],
            topThoughtCategories: categories,
            topContexts: contexts,
            topMoods: moods,
            deepThoughtCount: row[deepThoughtCount],
            recurringThoughts: recurring,
            weeklyInsight: row[weeklyInsight],
            createdAt: row[createdAt]
        )
    }

    // MARK: - Threads

    func saveThread(_ thread: MomentThread) throws {
        guard let db = db else { return }
        let idsJSON = (try? encoder.encode(thread.momentIds)).flatMap { String(data: $0, encoding: .utf8) } ?? "[]"
        let existing = try db.pluck(threads.filter(id == thread.id.uuidString))
        if existing != nil {
            let t = threads.filter(id == thread.id.uuidString)
            try db.run(t.update(
                momentIdsJSON <- idsJSON,
                threadTitle <- thread.title,
                lastUpdatedAt <- thread.lastUpdatedAt,
                isActive <- thread.isActive
            ))
        } else {
            let insert = threads.insert(
                id <- thread.id.uuidString,
                momentIdsJSON <- idsJSON,
                threadTitle <- thread.title,
                createdAt <- thread.createdAt,
                lastUpdatedAt <- thread.lastUpdatedAt,
                isActive <- thread.isActive
            )
            try db.run(insert)
        }
    }

    func fetchAllThreads() throws -> [MomentThread] {
        guard let db = db else { return [] }
        var result: [MomentThread] = []
        for row in try db.prepare(threads.order(lastUpdatedAt.desc)) {
            let idsStr = row[momentIdsJSON]
            let decodedIds = (try? decoder.decode([UUID].self, from: Data(idsStr.utf8))) ?? []
            let thread = MomentThread(
                id: UUID(uuidString: row[id]) ?? UUID(),
                momentIds: decodedIds,
                title: row[threadTitle],
                createdAt: row[createdAt],
                lastUpdatedAt: row[lastUpdatedAt],
                isActive: row[isActive]
            )
            result.append(thread)
        }
        return result
    }

    func fetchActiveThreads() throws -> [MomentThread] {
        guard let db = db else { return [] }
        var result: [MomentThread] = []
        let query = threads.filter(isActive == true).order(lastUpdatedAt.desc)
        for row in try db.prepare(query) {
            let idsStr = row[momentIdsJSON]
            let decodedIds = (try? decoder.decode([UUID].self, from: Data(idsStr.utf8))) ?? []
            let thread = MomentThread(
                id: UUID(uuidString: row[id]) ?? UUID(),
                momentIds: decodedIds,
                title: row[threadTitle],
                createdAt: row[createdAt],
                lastUpdatedAt: row[lastUpdatedAt],
                isActive: row[isActive]
            )
            result.append(thread)
        }
        return result
    }

    func deleteThread(id threadId: UUID) throws {
        guard let db = db else { return }
        let thread = threads.filter(id == threadId.uuidString)
        try db.run(thread.delete())
    }
}
