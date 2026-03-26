import Foundation
import StoreKit

// R13: Subscription Manager — free tier (20 moments/month), Pro ($7.99), Complete ($14.99)
@MainActor
final class SubscriptionManager: ObservableObject {
    enum SubscriptionTier: String, Codable, CaseIterable {
        case free = "free"
        case pro = "pro"
        case complete = "complete"

        var momentLimit: Int? { nil }  // nil = unlimited
        var displayName: String {
            switch self {
            case .free: return "Free"
            case .pro: return "Pro"
            case .complete: return "Complete"
            }
        }

        // R13: Updated pricing
        var price: String {
            switch self {
            case .free: return "Free"
            case .pro: return "$7.99/mo"
            case .complete: return "$14.99/mo"
            }
        }

        var features: [String] {
            switch self {
            case .free:
                return ["20 moments/month", "Basic patterns", "7-day history"]
            case .pro:
                return ["Unlimited moments", "Advanced patterns", "Voice-to-moment", "AI briefings", "30-day history"]
            case .complete:
                return ["Everything in Pro", "Lifetime history", "Priority AI", "Export data", "Widgets"]
            }
        }

        var canCapture: Bool { true }

        static var defaultTier: SubscriptionTier { .free }
    }

    @Published var currentTier: SubscriptionTier = .free
    @Published var momentsUsedThisMonth: Int = 0
    @Published var momentsRemaining: Int = 20
    @Published var isLoading: Bool = false
    @Published var showPaywall: Bool = false
    @Published var isSubscribed: Bool = false

    private let freeMomentLimit = 20
    private let monthKey = "current_month"
    private let momentsKey = "monthly_moments_used"
    private let tierKey = "subscription_tier"

    static let shared = SubscriptionManager()

    init() {
        loadState()
    }

    // MARK: - Public API

    func checkCaptureAllowed() -> Bool {
        if isSubscribed { return true }
        return momentsRemaining > 0
    }

    func recordMomentCapture() {
        if isSubscribed { return }

        momentsUsedThisMonth += 1
        momentsRemaining = max(0, freeMomentLimit - momentsUsedThisMonth)
        saveState()

        if momentsRemaining == 0 {
            showPaywall = true
        }
    }

    func restorePurchases() async {
        isLoading = true
        // In a real app, this would call StoreKit to restore purchases
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        // Simulate successful restore
        isSubscribed = true
        currentTier = .pro
        isLoading = false
    }

    func subscribeToPro() async {
        isLoading = true
        // In a real app, this would initiate a StoreKit purchase
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        // Simulate successful subscription
        isSubscribed = true
        currentTier = .pro
        saveState()
        isLoading = false
    }

    func cancelSubscription() {
        isSubscribed = false
        currentTier = .free
        saveState()
    }

    // MARK: - Monthly Reset

    func checkMonthlyReset() {
        let calendar = Calendar.current
        let currentMonth = calendar.component(.month, from: Date())
        let storedMonth = UserDefaults.standard.integer(forKey: monthKey)

        if currentMonth != storedMonth || storedMonth == 0 {
            // New month — reset counter
            momentsUsedThisMonth = 0
            momentsRemaining = freeMomentLimit
            UserDefaults.standard.set(currentMonth, forKey: monthKey)
            UserDefaults.standard.set(0, forKey: momentsKey)
        }
    }

    // MARK: - Persistence

    private func loadState() {
        checkMonthlyReset()

        if let savedTier = UserDefaults.standard.string(forKey: tierKey),
           let tier = SubscriptionTier(rawValue: savedTier) {
            currentTier = tier
            isSubscribed = (tier == .pro)
        }

        let used = UserDefaults.standard.integer(forKey: momentsKey)
        momentsUsedThisMonth = used
        momentsRemaining = max(0, freeMomentLimit - used)
    }

    private func saveState() {
        UserDefaults.standard.set(currentTier.rawValue, forKey: tierKey)
        UserDefaults.standard.set(momentsUsedThisMonth, forKey: momentsKey)
    }

    // MARK: - UI Helpers

    var freeTierProgress: Double {
        Double(momentsUsedThisMonth) / Double(freeMomentLimit)
    }

    var momentsUsedText: String {
        if isSubscribed {
            return "Unlimited moments"
        }
        return "\(momentsRemaining) / \(freeMomentLimit) moments remaining"
    }

    var isNearLimit: Bool {
        !isSubscribed && momentsRemaining <= 3
    }
}
