import SwiftUI

struct HomeView: View {
    @EnvironmentObject var appState: AppState
    @State private var todayDigest: DailyDigest?
    @State private var todayMoments: [Moment] = []
    @State private var isLoading = true
    @State private var showingSettings = false

    var body: some View {
        NavigationStack {
            ZStack {
                MarginColors.background
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: MarginSpacing.lg) {
                        if let digest = todayDigest {
                            DailyDigestCard(digest: digest)
                                .padding(.horizontal, MarginSpacing.lg)
                        }

                        if todayMoments.isEmpty && !isLoading {
                            emptyStateView
                        } else {
                            VStack(spacing: MarginSpacing.md) {
                                ForEach(todayMoments) { moment in
                                    MomentCard(moment: moment)
                                        .padding(.horizontal, MarginSpacing.lg)
                                        .contextMenu {
                                            Button(role: .destructive) {
                                                deleteMoment(moment)
                                            } label: {
                                                Label("Delete", systemImage: "trash")
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
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                            .foregroundColor(MarginColors.secondaryText)
                    }
                }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
        }
        .task {
            await loadData()
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: MarginSpacing.lg) {
            Image(systemName: "square.stack.3d.up")
                .font(.system(size: 48))
                .foregroundColor(MarginColors.divider)

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
                let digest = await appState.aiService.generateDailyDigest(moments: todayMoments)
                try? await appState.databaseService.saveDailyDigest(digest)
                todayDigest = digest
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
