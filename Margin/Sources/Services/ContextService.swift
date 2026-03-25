import Foundation
import CoreLocation

final class ContextService: ObservableObject {
    @Published var currentContext: String?
    @Published var currentLocationType: String?

    private let locationManager = CLLocationManager()

    func inferContext(from date: Date = Date()) -> (timeOfDay: String, dayOfWeek: String, context: String?) {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let weekday = calendar.component(.weekday, from: date)

        let timeOfDay = classifyTimeOfDay(hour: hour)
        let dayOfWeek = calendar.weekdaySymbols[weekday - 1]

        let context = inferContextFromTime(hour: hour)

        return (timeOfDay, dayOfWeek, context)
    }

    private func classifyTimeOfDay(hour: Int) -> String {
        switch hour {
        case 5..<12: return "morning"
        case 12..<17: return "afternoon"
        case 17..<21: return "evening"
        default: return "night"
        }
    }

    private func inferContextFromTime(hour: Int) -> String? {
        switch hour {
        case 7..<9: return "🚗 commute"
        case 9..<11: return "☕ morning at desk"
        case 11..<13: return "☕ coffee break"
        case 13..<14: return "🍽️ lunch break"
        case 14..<17: return "💻 afternoon"
        case 17..<19: return "🚗 evening commute"
        case 19..<21: return "🏠 evening"
        default: return nil
        }
    }

    func estimateActivityContext() -> String? {
        // In Round 1, we rely on time-based inference
        // Round 2 will add significant-location detection
        return nil
    }
}
