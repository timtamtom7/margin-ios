import SwiftUI

// R10: Paywall View — shown when free tier limit is reached
struct PaywallView: View {
    @EnvironmentObject var appState: AppState
    @ObservedObject var subscriptionManager: SubscriptionManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                MarginColors.background
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: MarginSpacing.xl) {
                        // Header
                        headerSection

                        // Value props
                        valuePropsSection

                        // Pricing
                        pricingSection

                        // FAQ
                        faqSection
                    }
                    .padding(MarginSpacing.xl)
                    .padding(.bottom, 100)
                }
            }
            .navigationTitle("Go Unlimited")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(MarginColors.secondaryText)
                    }
                }
            }
        }
    }

    private var headerSection: some View {
        VStack(spacing: MarginSpacing.md) {
            Image(systemName: "sparkles")
                .font(.system(size: 48))
                .foregroundColor(MarginColors.accent)

            Text("You've reached your limit")
                .font(MarginFonts.heading)
                .foregroundColor(MarginColors.primaryText)

            Text("You've captured \(20) moments this month on the free tier. Upgrade to Pro for unlimited captures and more.")
                .font(MarginFonts.body)
                .foregroundColor(MarginColors.secondaryText)
                .multilineTextAlignment(.center)
        }
    }

    private var valuePropsSection: some View {
        VStack(spacing: MarginSpacing.md) {
            valueProp(icon: "infinity", title: "Unlimited moments", body: "Capture without limits, whenever inspiration strikes")
            valueProp(icon: "sparkles", title: "Advanced AI insights", body: "Deeper pattern analysis and richer weekly narratives")
            valueProp(icon: "icloud", title: "Cloud sync", body: "Sync across all your devices seamlessly")
            valueProp(icon: "person.3", title: "Private group threads", body: "Create and join small private groups with trusted people")
            valueProp(icon: "bell", title: "Daily digest notifications", body: "Get a thoughtful summary delivered each evening")
        }
    }

    private func valueProp(icon: String, title: String, body: String) -> some View {
        HStack(alignment: .top, spacing: MarginSpacing.md) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(MarginColors.accent)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(MarginFonts.subheading)
                    .foregroundColor(MarginColors.primaryText)
                Text(body)
                    .font(MarginFonts.caption)
                    .foregroundColor(MarginColors.secondaryText)
            }

            Spacer()
        }
        .padding(MarginSpacing.md)
        .background(MarginColors.surface)
        .cornerRadius(12)
    }

    private var pricingSection: some View {
        VStack(spacing: MarginSpacing.md) {
            // Pro plan
            VStack(spacing: MarginSpacing.md) {
                HStack {
                    Text("Pro")
                        .font(MarginFonts.subheading)
                        .foregroundColor(.white)

                    Spacer()

                    Text("$2.99/mo")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                }

                Text("Billed monthly. Cancel anytime.")
                    .font(MarginFonts.caption)
                    .foregroundColor(.white.opacity(0.7))

                Button {
                    Task {
                        await subscriptionManager.subscribeToPro()
                        if subscriptionManager.isSubscribed {
                            dismiss()
                        }
                    }
                } label: {
                    if subscriptionManager.isLoading {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text("Start Pro")
                            .font(MarginFonts.body)
                            .fontWeight(.medium)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(MarginSpacing.md)
                .background(Color.white)
                .foregroundColor(MarginColors.accent)
                .cornerRadius(12)
                .disabled(subscriptionManager.isLoading)
            }
            .padding(MarginSpacing.lg)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [MarginColors.accent, MarginColors.accentSecondary]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(16)

            Button {
                Task {
                    await subscriptionManager.restorePurchases()
                    if subscriptionManager.isSubscribed {
                        dismiss()
                    }
                }
            } label: {
                Text("Restore purchases")
                    .font(MarginFonts.caption)
                    .foregroundColor(MarginColors.secondaryText)
            }

            Text("Terms of Use · Privacy Policy")
                .font(MarginFonts.caption)
                .foregroundColor(MarginColors.secondaryText)
        }
    }

    private var faqSection: some View {
        VStack(alignment: .leading, spacing: MarginSpacing.md) {
            Text("Questions?")
                .font(MarginFonts.subheading)
                .foregroundColor(MarginColors.primaryText)

            faqItem(question: "Can I cancel anytime?", answer: "Yes. Cancel anytime from Settings and you'll keep Pro access until the end of your billing period.")
            faqItem(question: "What counts as a moment?", answer: "Any captured thought — voice or text — counts as one moment. Editing or deleting moments doesn't affect your count.")
            faqItem(question: "What about my existing moments?", answer: "They're safe. Your 20 free moments are preserved. Upgrading unlocks unlimited new captures.")
        }
    }

    private func faqItem(question: String, answer: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(question)
                .font(MarginFonts.body)
                .foregroundColor(MarginColors.primaryText)
            Text(answer)
                .font(MarginFonts.caption)
                .foregroundColor(MarginColors.secondaryText)
        }
        .padding(MarginSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(MarginColors.surface)
        .cornerRadius(12)
    }
}

// R10: Upgrade prompt banner (shown when near limit)
struct UpgradePromptBanner: View {
    @ObservedObject var subscriptionManager: SubscriptionManager
    let onUpgrade: () -> Void

    var body: some View {
        if subscriptionManager.isNearLimit && !subscriptionManager.isSubscribed {
            HStack(spacing: MarginSpacing.md) {
                Image(systemName: "exclamationmark.circle")
                    .foregroundColor(MarginColors.accent)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Only \(subscriptionManager.momentsRemaining) free moments left")
                        .font(MarginFonts.caption)
                        .foregroundColor(MarginColors.primaryText)

                    Text("Upgrade for unlimited captures")
                        .font(MarginFonts.caption)
                        .foregroundColor(MarginColors.secondaryText)
                }

                Spacer()

                Button("Upgrade") {
                    onUpgrade()
                }
                .font(MarginFonts.caption)
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(MarginColors.accent)
                .cornerRadius(12)
            }
            .padding(MarginSpacing.md)
            .background(MarginColors.accent.opacity(0.1))
            .cornerRadius(12)
        }
    }
}

#Preview {
    PaywallView(subscriptionManager: SubscriptionManager())
        .environmentObject(AppState())
}
