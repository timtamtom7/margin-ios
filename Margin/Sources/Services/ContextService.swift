import Foundation
import CoreLocation

enum LocationContextType: String, CaseIterable {
    case work = "work"
    case home = "home"
    case transit = "transit"
    case waiting = "waiting"
    case outdoor = "outdoor"
    case indoor = "indoor"

    var emoji: String {
        switch self {
        case .work: return "💼"
        case .home: return "🏠"
        case .transit: return "🚗"
        case .waiting: return "⏳"
        case .outdoor: return "🌳"
        case .indoor: return "🏢"
        }
    }
}

@MainActor
final class ContextService: ObservableObject {
    @Published var currentContext: String?
    @Published var currentLocationType: String?
    @Published var locationPermissionGranted: Bool = false
    @Published var estimatedActivityType: String?

    // R2: Significant locations (stored locally, never synced)
    private var significantLocations: [SignificantLocation] = []

    struct SignificantLocation: Codable {
        let name: String
        let latitude: Double
        let longitude: Double
        let radiusMeters: Double
    }

    nonisolated init() {
        Task { @MainActor in
            self.loadSignificantLocations()
        }
    }

    func inferContext(from date: Date = Date()) -> (timeOfDay: String, dayOfWeek: String, context: String?) {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let weekday = calendar.component(.weekday, from: date)

        let timeOfDay = classifyTimeOfDay(hour: hour)
        let dayOfWeek = calendar.weekdaySymbols[weekday - 1]

        let context = inferContextFromTime(hour: hour)
        estimatedActivityType = inferActivityType(hour: hour, weekday: weekday)

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

    private func inferActivityType(hour: Int, weekday: Int) -> String {
        let isWeekend = weekday == 1 || weekday == 7

        switch hour {
        case 6..<8: return isWeekend ? "leisure morning" : "morning routine"
        case 8..<12: return isWeekend ? "weekend plans" : "work/school"
        case 12..<14: return "lunch break"
        case 14..<17: return isWeekend ? "weekend activities" : "afternoon work"
        case 17..<19: return "commute home"
        case 19..<22: return "evening relaxation"
        default: return "rest time"
        }
    }

    // MARK: - R2: Location Permission & Detection

    func requestLocationPermission() {
        // In R2, we use CLLocationManager just for permission status
        // Actual location detection is time-based (privacy-first)
        #if os(iOS)
        let manager = CLLocationManager()
        let status = manager.authorizationStatus
        locationPermissionGranted = (status == .authorizedWhenInUse || status == .authorizedAlways)
        #else
        locationPermissionGranted = false
        #endif
    }

    func checkLocationPermission() {
        #if os(iOS)
        let manager = CLLocationManager()
        let status = manager.authorizationStatus
        locationPermissionGranted = (status == .authorizedWhenInUse || status == .authorizedAlways)
        #else
        locationPermissionGranted = false
        #endif
    }

    func detectLocationType() {
        // R2: Privacy-first location detection
        // We use time-of-day patterns instead of GPS coordinates
        // This way, no location data ever leaves the device
        let hour = Calendar.current.component(.hour, from: Date())
        currentLocationType = inferLocationTypeFromTime(hour: hour)
    }

    private func inferLocationTypeFromTime(hour: Int) -> String {
        // Privacy-first approach: infer likely location from time patterns
        // Never store or transmit GPS coordinates
        switch hour {
        case 6..<8: return "home"
        case 8..<9: return "transit"
        case 9..<17: return "work"
        case 17..<18: return "transit"
        case 18..<22: return "home"
        default: return "home"
        }
    }

    // MARK: - R2: Significant Location Learning

    func learnSignificantLocation(name: String, at coordinate: CLLocationCoordinate2D) {
        if let existingIndex = significantLocations.firstIndex(where: { $0.name == name }) {
            let existing = significantLocations[existingIndex]
            let newLat = (existing.latitude + coordinate.latitude) / 2
            let newLon = (existing.longitude + coordinate.longitude) / 2
            significantLocations[existingIndex] = SignificantLocation(
                name: name,
                latitude: newLat,
                longitude: newLon,
                radiusMeters: max(existing.radiusMeters, 100)
            )
        } else {
            significantLocations.append(SignificantLocation(
                name: name,
                latitude: coordinate.latitude,
                longitude: coordinate.longitude,
                radiusMeters: 100
            ))
        }
        saveSignificantLocations()
    }

    func classifyCurrentLocation(coordinate: CLLocationCoordinate2D) -> String? {
        for location in significantLocations {
            let loc = CLLocation(latitude: location.latitude, longitude: location.longitude)
            let current = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            if current.distance(from: loc) < location.radiusMeters {
                return location.name
            }
        }
        return nil
    }

    private func loadSignificantLocations() {
        guard let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("significant_locations.json"),
              let data = try? Data(contentsOf: url) else { return }
        significantLocations = (try? JSONDecoder().decode([SignificantLocation].self, from: data)) ?? []
    }

    private func saveSignificantLocations() {
        guard let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("significant_locations.json"),
              let data = try? JSONEncoder().encode(significantLocations) else { return }
        try? data.write(to: url)
    }
}
