import SwiftUI
import Combine

@MainActor
final class AppState: ObservableObject {
    @Published var selectedTab: Tab = .home
    @Published var isShowingCapture: Bool = false
    @Published var isLoading: Bool = false

    let databaseService: DatabaseService
    let aiService: AIService
    let voiceService: VoiceService
    let contextService: ContextService

    enum Tab: Int, CaseIterable {
        case home = 0
        case stream = 1
        case patterns = 2
        case threads = 3  // R2: Threads tab
        case community = 4 // R2: Community tab
    }

    init() {
        self.databaseService = DatabaseService()
        self.aiService = AIService()
        self.voiceService = VoiceService()
        self.contextService = ContextService()
    }
}
