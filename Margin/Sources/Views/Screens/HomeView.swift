import SwiftUI

struct HomeView: View {
    @EnvironmentObject var appState: AppState
    @State private var todayDigest: DailyDigest?
    @State private var todayMoments: [Moment] = []
    @State private var isLoading = true
    @State private var showingSettings = false
    @State private var showingWeeklySummary = false
    @State private var abandonedThreads: [MomentThread] = []
    @State private var abandonedThreadMoments: [UUID: [Moment]] = [:]

    var body: some View {
        NavigationStack {
            ZStack {
                MarginColors.background
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: MarginSpacing.lg) {
                        // R2: Weekly summary banner
                        weeklySummaryBanner

                        // R10: Free tier meter / Upgrade prompt
                        freeTierMeter
                            .padding(.horizontal, MarginSpacing.lg)

                        if let digest = todayDigest {
                            DailyDigestCard(digest: digest)
                                .padding(.horizontal, MarginSpacing.lg)
                        }

                        // R2: Abandoned thread reminders
                        if !abandonedThreads.isEmpty {
                            VStack(spacing: MarginSpacing.sm) {
                                ForEach(abandonedThreads) { thread in
                                    if let moments = abandonedThreadMoments[thread.id] {
                                        AbandonedThreadReminderView(thread: thread, moments: moments)
                                    }
                                }
                            }
                            .padding(.horizontal, MarginSpacing.lg)
                        }

                        if todayMoments.isEmpty && !isLoading {
                            emptyStateView
                        } else {
                            VStack(spacing: MarginSpacing.md) {
                                ForEach(todayMoments) { moment in
                                    MomentCard(moment: moment, showThreadIndicator: moment.threadId != nil)
                                        .padding(.horizontal, MarginSpacing.lg)
                                        .contextMenu {
                                            Button(role: .destructive) {
                                                deleteMoment(moment)
                                            } label: {
                                                Label("Delete", systemImage: "trash")
                                            }

                                            // R2: Link to thread action
                                            if moment.threadId == nil {
                                                Button {
                                                    // Manual thread linking
                                                } label: {
                                                    Label("Link to thread", systemImage: "link")
                                                }
                                            }
                                        }
                                }
                            }
                        }
                    }
                    .padding(.top, MarginSpacing.md)
                    .padding(.bottom, 100)
                }
                .refreshable {
                    await loadData()
                }
            }
            .navigationTitle("Margin")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: MarginSpacing.sm) {
                        Button {
                            showingWeeklySummary = true
                        } label: {
                            Image(systemName: "calendar")
                                .foregroundColor(MarginColors.secondaryText)
                        }

                        Button {
                            showingSettings = true
                        } label: {
                            Image(systemName: "gearshape")
                                .foregroundColor(MarginColors.secondaryText)
                        }
                    }
                }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showingWeeklySummary) {
                WeeklySummaryView()
            }
            .sheet(isPresented: Binding(
                get: { appState.subscriptionManager.showPaywall },
                set: { appState.subscriptionManager.showPaywall = $0 }
            )) {
                PaywallView(subscriptionManager: appState.subscriptionManager)
            }
        }
        .task {
            await loadData()
        }
    }

    private var weeklySummaryBanner: some View {
        Button {
            showingWeeklySummary = true
        } label: {
            HStack(spacing: MarginSpacing.sm) {
                Image(systemName: "calendar.badge.clock")
                    .font(.system(size: 16))
                    .foregroundColor(MarginColors.accent)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Your week in review")
                        .font(MarginFonts.subheading)
                        .foregroundColor(MarginColors.primaryText)
                    Text("Patterns, threads, and insights")
                        .font(MarginFonts.caption)
                        .foregroundColor(MarginColors.secondaryText)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundColor(MarginColors.secondaryText)
            }
            .padding(MarginSpacing.md)
            .background(MarginColors.surface)
            .cornerRadius(12)
            .padding(.horizontal, MarginSpacing.lg)
        }
    }

    // R10: Free tier meter
    @ViewBuilder
    private var freeTierMeter: some View {
        if appState.subscriptionManager.isSubscribed {
            HStack(spacing: MarginSpacing.sm) {
                Image(systemName: "checkmark.seal.fill")
                    .foregroundColor(MarginColors.accentSecondary)
                Text("Pro — unlimited moments")
                    .font(MarginFonts.caption)
                    .foregroundColor(MarginColors.accentSecondary)
                Spacer()
            }
            .padding(MarginSpacing.sm)
        } else {
            VStack(spacing: MarginSpacing.sm) {
                HStack {
                    Text("Free tier")
                        .font(MarginFonts.caption)
                        .foregroundColor(MarginColors.secondaryText)
                    Spacer()
                    Text(appState.subscriptionManager.momentsUsedText)
                        .font(MarginFonts.caption)
                        .foregroundColor(appState.subscriptionManager.isNearLimit ? MarginColors.destructive : MarginColors.secondaryText)
                }

                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(MarginColors.divider)
                            .frame(height: 4)
                            .cornerRadius(2)

                        Rectangle()
                            .fill(appState.subscriptionManager.isNearLimit ? MarginColors.destructive : MarginColors.accent)
                            .frame(width: geometry.size.width * appState.subscriptionManager.freeTierProgress, height: 4)
                            .cornerRadius(2)
                    }
                }
                .frame(height: 4)

                if appState.subscriptionManager.isNearLimit {
                    UpgradePromptBanner(subscriptionManager: appState.subscriptionManager) {
                        appState.subscriptionManager.showPaywall = true
                    }
                }
            }
            .padding(MarginSpacing.md)
            .background(MarginColors.surface)
            .cornerRadius(12)
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: MarginSpacing.lg) {
            MarginEmptyIllustration(size: 180)

            Text("No moments yet")
                .font(MarginFonts.subheading)
                .foregroundColor(MarginColors.primaryText)

            Text("Tap + to capture your first micro-thought.\nThe margins of your day hold more than you think.")
                .font(MarginFonts.body)
                .foregroundColor(MarginColors.secondaryText)
                .multilineTextAlignment(.center)
        }
        .padding(MarginSpacing.xxl)
    }

    private func loadData() async {
        isLoading = true
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        do {
            let allMoments = try await appState.databaseService.fetchAllMoments()
            todayMoments = allMoments.filter { calendar.isDate($0.timestamp, inSameDayAs: today) }

            if let digest = try await appState.databaseService.fetchDigest(for: today) {
                todayDigest = digest
            } else if !todayMoments.isEmpty {
                let digest = appState.aiService.generateDailyDigest(moments: todayMoments)
                try? await appState.databaseService.saveDailyDigest(digest)
                todayDigest = digest
            }

            // R2: Load abandoned threads
            try? await appState.databaseService.markAbandonedThreads()
            abandonedThreads = try await appState.databaseService.fetchActiveThreads().filter { !$0.isActive }
            for thread in abandonedThreads {
                let moments = try await appState.databaseService.fetchMoments(inThread: thread.id)
                abandonedThreadMoments[thread.id] = moments
            }
        } catch {
            print("Load error: \(error)")
        }

        isLoading = false
    }

    private func deleteMoment(_ moment: Moment) {
        Task {
            do {
                try await appState.databaseService.deleteMoment(id: moment.id)
                todayMoments.removeAll { $0.id == moment.id }
            } catch {
                print("Delete error: \(error)")
            }
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(AppState())
}
