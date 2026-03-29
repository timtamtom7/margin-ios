import SwiftUI
import AppKit

@main
struct MarginMacApp: App {
    @StateObject private var appState = MacAppState()
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            MacContentView()
                .environmentObject(appState)
                .preferredColorScheme(.light)
                .onReceive(NotificationCenter.default.publisher(for: .momentCaptured)) { notification in
                    if let text = notification.object as? String {
                        appState.addMoment(text: text)
                    }
                }
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .commands {
            CommandGroup(replacing: .newItem) { }
        }
    }
}

// MARK: - Mac App State

@MainActor
class MacAppState: ObservableObject {
    @Published var moments: [Moment] = []

    private let aiService = AIService()

    func addMoment(text: String) {
        let hour = Calendar.current.component(.hour, from: Date())
        let timeOfDay: String
        switch hour {
        case 5..<12: timeOfDay = "morning"
        case 12..<17: timeOfDay = "afternoon"
        case 17..<21: timeOfDay = "evening"
        default: timeOfDay = "night"
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        let dayOfWeek = formatter.string(from: Date())

        let mood = aiService.detectMood(from: text)
        let isDeep = aiService.isDeepThought(text: text)
        let prompt = aiService.generateReflectionPrompt()

        let moment = Moment(
            text: text,
            timestamp: Date(),
            timeOfDay: timeOfDay,
            dayOfWeek: dayOfWeek,
            reflectionPrompt: prompt,
            isDeepThought: isDeep,
            moodTag: mood
        )

        moments.insert(moment, at: 0)
    }
}
