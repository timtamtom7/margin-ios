import Foundation
import SwiftUI

/// R13: Retention tracking for Margin
/// Day 1: first moment
/// Day 3: first pattern
/// Day 7: first AI briefing
@MainActor
final class RetentionService: ObservableObject {
    static let shared = RetentionService()

    private let installDateKey = "margin_install_date"
    private let day1MomentKey = "day1_moment_completed"
    private let day3PatternKey = "day3_pattern_completed"
    private let day7BriefingKey = "day7_briefing_completed"
    private let lastActiveKey = "margin_last_active"

    @Published var daysSinceInstall: Int = 0
    @Published var day1Completed: Bool = false
    @Published var day3Completed: Bool = false
    @Published var day7Completed: Bool = false

    var currentMilestone: RetentionMilestone {
        if day7Completed { return .completed }
        else if day3Completed { return .day7 }
        else if day1Completed { return .day3 }
        else { return .day1 }
    }

    enum RetentionMilestone: String {
        case day1 = "Capture your first moment"
        case day3 = "Discover your first pattern"
        case day7 = "Get your first AI briefing"
        case completed = "Reflection active!"
    }

    init() {
        loadRetentionData()
    }

    func loadRetentionData() {
        if let installDate = UserDefaults.standard.object(forKey: installDateKey) as? Date {
            daysSinceInstall = Calendar.current.dateComponents([.day], from: installDate, to: Date()).day ?? 0
        } else {
            UserDefaults.standard.set(Date(), forKey: installDateKey)
            daysSinceInstall = 0
        }

        day1Completed = UserDefaults.standard.bool(forKey: day1MomentKey)
        day3Completed = UserDefaults.standard.bool(forKey: day3PatternKey)
        day7Completed = UserDefaults.standard.bool(forKey: day7BriefingKey)
        UserDefaults.standard.set(Date(), forKey: lastActiveKey)
    }

    func recordMomentCaptured() {
        guard !day1Completed else { return }
        day1Completed = true
        UserDefaults.standard.set(true, forKey: day1MomentKey)
        trackMilestone(.day1)
    }

    func recordPatternDiscovered() {
        guard !day3Completed else { return }
        day3Completed = true
        UserDefaults.standard.set(true, forKey: day3PatternKey)
        trackMilestone(.day3)
    }

    func recordBriefingViewed() {
        guard !day7Completed else { return }
        day7Completed = true
        UserDefaults.standard.set(true, forKey: day7BriefingKey)
        trackMilestone(.day7)
    }

    private func trackMilestone(_ milestone: RetentionMilestone) {
        print("[Retention] Milestone completed: \(milestone.rawValue)")
    }
}
