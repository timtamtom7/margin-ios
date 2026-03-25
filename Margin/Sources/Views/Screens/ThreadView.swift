import SwiftUI

struct ThreadView: View {
    @EnvironmentObject var appState: AppState
    let thread: MomentThread

    @State private var moments: [Moment] = []
    @State private var isLoading = true

    var body: some View {
        ZStack {
            MarginColors.background
                .ignoresSafeArea()

            if isLoading {
                ProgressView()
                    .tint(MarginColors.accent)
            } else if moments.isEmpty {
                emptyStateView
            } else {
                threadContent
            }
        }
        .navigationTitle("Thread")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if !thread.isActive {
                    Button {
                        resolveThread()
                    } label: {
                        Text("Mark Resolved")
                            .font(MarginFonts.caption)
                            .foregroundColor(MarginColors.accent)
                    }
                }
            }
        }
        .task {
            await loadThreadMoments()
        }
    }

    private var threadContent: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Thread header
                headerSection

                // Timeline moments
                LazyVStack(spacing: 0) {
                    ForEach(Array(moments.enumerated()), id: \.element.id) { index, moment in
                        momentItem(index: index, moment: moment)
                    }
                }

                // Thread insight
                if !thread.isActive {
                    resolvedBanner
                }
            }
            .padding(.bottom, 100)
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: MarginSpacing.sm) {
            if let title = thread.title {
                Text(title)
                    .font(MarginFonts.subheading)
                    .foregroundColor(MarginColors.primaryText)
            }

            HStack {
                Text("\(moments.count) connected moments")
                    .font(MarginFonts.caption)
                    .foregroundColor(MarginColors.secondaryText)

                if !thread.isActive {
                    Text("· resolved")
                        .font(MarginFonts.caption)
                        .foregroundColor(MarginColors.accentSecondary)
                }

                Spacer()

                if let first = moments.first, let last = moments.last {
                    let interval = last.timestamp.timeIntervalSince(first.timestamp)
                    let hours = Int(interval / 3600)
                    let minutes = Int((interval.truncatingRemainder(dividingBy: 3600)) / 60)
                    Text("\(hours)h \(minutes)m span")
                        .font(MarginFonts.caption)
                        .foregroundColor(MarginColors.secondaryText)
                }
            }
        }
        .padding(MarginSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(MarginColors.surface.opacity(0.5))
    }

    @ViewBuilder
    private func momentItem(index: Int, moment: Moment) -> some View {
        VStack(spacing: 0) {
            // Connection line
            if index > 0 {
                connectionLine
            }

            // Moment card
            MomentCard(moment: moment, showThreadIndicator: true)
                .padding(.horizontal, MarginSpacing.lg)
                .padding(.vertical, MarginSpacing.sm)

            // Time gap indicator
            if index < moments.count - 1 {
                let next = moments[index + 1]
                let gap = moment.timestamp.timeIntervalSince(next.timestamp)
                if gap > 30 * 60 {
                    timeGapBadge(minutes: Int(gap / 60))
                }
            }
        }
    }

    private var connectionLine: some View {
        HStack {
            Spacer()
            VStack(spacing: 2) {
                Image(systemName: "link")
                    .font(.system(size: 10))
                    .foregroundColor(MarginColors.accent.opacity(0.5))
                Rectangle()
                    .fill(MarginColors.accent.opacity(0.3))
                    .frame(width: 2, height: 20)
            }
            .padding(.trailing, MarginSpacing.lg)
            Spacer()
        }
        .padding(.vertical, MarginSpacing.xs)
    }

    private func timeGapBadge(minutes: Int) -> some View {
        HStack {
            Spacer()
            Text("+\(minutes)m later")
                .font(MarginFonts.caption)
                .foregroundColor(MarginColors.secondaryText)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(MarginColors.divider.opacity(0.5))
                .cornerRadius(4)
            Spacer()
        }
        .padding(.vertical, MarginSpacing.xs)
    }

    private var resolvedBanner: some View {
        VStack(spacing: MarginSpacing.sm) {
            Image(systemName: "checkmark.circle")
                .font(.system(size: 24))
                .foregroundColor(MarginColors.accentSecondary)

            Text("Thread resolved")
                .font(MarginFonts.subheading)
                .foregroundColor(MarginColors.primaryText)

            Text("This thought ran its course.")
                .font(MarginFonts.body)
                .foregroundColor(MarginColors.secondaryText)
        }
        .padding(MarginSpacing.xl)
        .frame(maxWidth: .infinity)
        .background(MarginColors.surface)
        .cornerRadius(16)
        .padding(MarginSpacing.lg)
    }

    private var emptyStateView: some View {
        VStack(spacing: MarginSpacing.lg) {
            Image(systemName: "link.badge.plus")
                .font(.system(size: 48))
                .foregroundColor(MarginColors.divider)

            Text("Thread not found")
                .font(MarginFonts.subheading)
                .foregroundColor(MarginColors.primaryText)
        }
    }

    private func loadThreadMoments() async {
        isLoading = true
        do {
            moments = try await appState.databaseService.fetchMoments(inThread: thread.id)
        } catch {
            print("Load thread moments error: \(error)")
        }
        isLoading = false
    }

    private func resolveThread() {
        Task {
            var updatedThread = thread
            updatedThread.isActive = false
            updatedThread.lastUpdatedAt = Date()
            try? await appState.databaseService.saveThread(updatedThread)
        }
    }
}

// MARK: - Abandoned Thread Reminder View

struct AbandonedThreadReminderView: View {
    @EnvironmentObject var appState: AppState
    let thread: MomentThread
    let moments: [Moment]

    var body: some View {
        if let first = moments.first {
            HStack(spacing: MarginSpacing.sm) {
                Image(systemName: "exclamationmark.circle")
                    .font(.system(size: 14))
                    .foregroundColor(MarginColors.destructive)

                VStack(alignment: .leading, spacing: 2) {
                    Text("You started this thread \(daysAgo) days ago")
                        .font(MarginFonts.caption)
                        .foregroundColor(MarginColors.primaryText)

                    Text(first.text)
                        .font(MarginFonts.caption)
                        .foregroundColor(MarginColors.secondaryText)
                        .lineLimit(1)
                }

                Spacer()

                NavigationLink {
                    ThreadView(thread: thread)
                } label: {
                    Text("Return")
                        .font(MarginFonts.caption)
                        .foregroundColor(MarginColors.accent)
                }
            }
            .padding(MarginSpacing.md)
            .background(MarginColors.destructive.opacity(0.08))
            .cornerRadius(12)
        }
    }

    private var daysAgo: Int {
        let interval = Date().timeIntervalSince(thread.lastUpdatedAt)
        return Int(interval / 86400)
    }
}

#Preview {
    NavigationStack {
        ThreadView(thread: MomentThread(
            momentIds: [UUID(), UUID(), UUID()],
            title: "The presentation tomorrow...",
            isActive: true
        ))
    }
    .environmentObject(AppState())
}
