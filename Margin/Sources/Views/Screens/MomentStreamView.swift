import SwiftUI

struct MomentStreamView: View {
    @EnvironmentObject var appState: AppState
    @State private var moments: [Moment] = []
    @State private var isLoading = true
    @State private var groupedMoments: [(String, [Moment])] = []

    var body: some View {
        NavigationStack {
            ZStack {
                MarginColors.background
                    .ignoresSafeArea()

                if isLoading {
                    ProgressView()
                        .tint(MarginColors.accent)
                } else if moments.isEmpty {
                    emptyStateView
                } else {
                    streamContent
                }
            }
            .navigationTitle("Stream")
            .navigationBarTitleDisplayMode(.large)
        }
        .task {
            await loadMoments()
        }
    }

    private var streamContent: some View {
        ScrollView {
            LazyVStack(spacing: MarginSpacing.md, pinnedViews: .sectionHeaders) {
                ForEach(groupedMoments, id: \.0) { day, dayMoments in
                    Section {
                        ForEach(dayMoments) { moment in
                            NavigationLink {
                                MomentDetailView(moment: moment)
                            } label: {
                                MomentCard(moment: moment)
                            }
                            .buttonStyle(.plain)
                            .contextMenu {
                                Button(role: .destructive) {
                                    deleteMoment(moment)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    } header: {
                        dayHeader(day)
                    }
                }
            }
            .padding(.horizontal, MarginSpacing.lg)
            .padding(.bottom, 100)
        }
        .refreshable {
            await loadMoments()
        }
    }

    private func dayHeader(_ day: String) -> some View {
        HStack {
            Text(day)
                .font(MarginFonts.subheading)
                .foregroundColor(MarginColors.primaryText)
            Spacer()
        }
        .padding(.vertical, MarginSpacing.sm)
        .padding(.horizontal, MarginSpacing.lg)
        .background(MarginColors.background.opacity(0.95))
    }

    private var emptyStateView: some View {
        VStack(spacing: MarginSpacing.lg) {
            Image(systemName: "list.bullet.rectangle")
                .font(.system(size: 48))
                .foregroundColor(MarginColors.divider)

            Text("Your moments will appear here")
                .font(MarginFonts.subheading)
                .foregroundColor(MarginColors.primaryText)

            Text("Capture thoughts throughout your day\nand watch your inner world unfold.")
                .font(MarginFonts.body)
                .foregroundColor(MarginColors.secondaryText)
                .multilineTextAlignment(.center)
        }
        .padding(MarginSpacing.xxl)
    }

    private func loadMoments() async {
        isLoading = true
        do {
            let allMoments = try await appState.databaseService.fetchAllMoments()
            moments = allMoments

            let grouped = Dictionary(grouping: moments) { $0.formattedDate }
            groupedMoments = grouped.sorted { $0.key > $1.key }
        } catch {
            print("Load error: \(error)")
        }
        isLoading = false
    }

    private func deleteMoment(_ moment: Moment) {
        Task {
            do {
                try await appState.databaseService.deleteMoment(id: moment.id)
                await loadMoments()
            } catch {
                print("Delete error: \(error)")
            }
        }
    }
}

#Preview {
    MomentStreamView()
        .environmentObject(AppState())
}
