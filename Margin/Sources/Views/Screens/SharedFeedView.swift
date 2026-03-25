import SwiftUI

struct SharedFeedView: View {
    @EnvironmentObject var appState: AppState
    @State private var sharedMoments: [SharedMoment] = []
    @State private var isLoading = true
    @State private var selectedContext: String = "all"
    @State private var showingShareSheet = false
    @State private var momentToShare: Moment?

    private let contexts = ["all", "traffic", "waiting", "coffee", "elevator", "commute", "work"]

    var body: some View {
        NavigationStack {
            ZStack {
                MarginColors.background
                    .ignoresSafeArea()

                if isLoading {
                    ProgressView()
                        .tint(MarginColors.accent)
                } else if sharedMoments.isEmpty {
                    emptyStateView
                } else {
                    feedContent
                }
            }
            .navigationTitle("Community")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button("Share a moment...") {
                            // Opens capture first, then share
                        }
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundColor(MarginColors.secondaryText)
                    }
                }
            }
            .sheet(isPresented: $showingShareSheet) {
                if let moment = momentToShare {
                    ShareMomentSheet(moment: moment)
                        .environmentObject(appState)
                }
            }
        }
        .task {
            await loadSharedMoments()
        }
    }

    private var feedContent: some View {
        VStack(spacing: 0) {
            // Context filter
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: MarginSpacing.sm) {
                    ForEach(contexts, id: \.self) { ctx in
                        contextFilterPill(ctx)
                    }
                }
                .padding(.horizontal, MarginSpacing.lg)
                .padding(.vertical, MarginSpacing.sm)
            }
            .background(MarginColors.surface.opacity(0.5))

            ScrollView {
                LazyVStack(spacing: MarginSpacing.md) {
                    ForEach(filteredMoments) { shared in
                        SharedMomentCard(shared: shared) {
                            // Like action
                        }
                    }
                }
                .padding(MarginSpacing.lg)
                .padding(.bottom, 100)
            }
            .refreshable {
                await loadSharedMoments()
            }
        }
    }

    private func contextFilterPill(_ context: String) -> some View {
        let isSelected = selectedContext == context
        return Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedContext = context
            }
        } label: {
            Text(context == "all" ? "All" : context.capitalized)
                .font(MarginFonts.caption)
                .foregroundColor(isSelected ? .white : MarginColors.secondaryText)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? MarginColors.accent : MarginColors.divider.opacity(0.5))
                .cornerRadius(16)
        }
    }

    private var filteredMoments: [SharedMoment] {
        if selectedContext == "all" {
            return sharedMoments
        }
        return sharedMoments.filter { $0.contextType?.lowercased().contains(selectedContext) == true }
    }

    private var emptyStateView: some View {
        VStack(spacing: MarginSpacing.lg) {
            Image(systemName: "person.3")
                .font(.system(size: 48))
                .foregroundColor(MarginColors.divider)

            Text("No shared moments yet")
                .font(MarginFonts.subheading)
                .foregroundColor(MarginColors.primaryText)

            Text("Be the first to share a moment anonymously. See what others in similar situations are thinking.")
                .font(MarginFonts.body)
                .foregroundColor(MarginColors.secondaryText)
                .multilineTextAlignment(.center)

            Button {
                // Open share flow
            } label: {
                Text("Share a moment")
                    .font(MarginFonts.body)
                    .foregroundColor(MarginColors.accent)
            }
            .padding(.top, MarginSpacing.md)
        }
        .padding(MarginSpacing.xxl)
    }

    private func loadSharedMoments() async {
        isLoading = true
        // R2: In a real app, this would fetch from a server
        // For now, generate sample data
        sharedMoments = generateSampleSharedMoments()
        isLoading = false
    }

    private func generateSampleSharedMoments() -> [SharedMoment] {
        [
            SharedMoment(
                text: "At red lights, I always wonder if the person next to me is thinking about something important too.",
                contextType: "🚗 traffic",
                moodTag: .curious,
                timestamp: Date().addingTimeInterval(-3600),
                likeCount: 24
            ),
            SharedMoment(
                text: "The elevator always makes me think about how we all have our own full lives happening.",
                contextType: "⏳ elevator",
                moodTag: .nostalgic,
                timestamp: Date().addingTimeInterval(-7200),
                likeCount: 18
            ),
            SharedMoment(
                text: "Coffee shop排队的时候，我在想是不是每个人都和我一样觉得排队是思考人生的好时机。",
                contextType: "☕ waiting",
                moodTag: .calm,
                timestamp: Date().addingTimeInterval(-14400),
                likeCount: 31
            ),
            SharedMoment(
                text: "Why do traffic jams always make me think about the people I'll never meet who have the same mundane problems as me?",
                contextType: "🚗 commute",
                moodTag: .melancholy,
                timestamp: Date().addingTimeInterval(-28800),
                likeCount: 42
            ),
            SharedMoment(
                text: "The buzz of a coffee machine is the best sound for thinking about nothing in particular.",
                contextType: "☕ coffee",
                moodTag: .calm,
                timestamp: Date().addingTimeInterval(-43200),
                likeCount: 15
            )
        ]
    }
}

struct SharedMomentCard: View {
    let shared: SharedMoment
    let onLike: () -> Void

    @State private var isLiked = false

    var body: some View {
        VStack(alignment: .leading, spacing: MarginSpacing.sm) {
            HStack {
                // Anonymous avatar
                Circle()
                    .fill(avatarGradient)
                    .frame(width: 32, height: 32)
                    .overlay(
                        Text(anonymousInitial)
                            .font(MarginFonts.caption)
                            .foregroundColor(.white)
                    )

                VStack(alignment: .leading, spacing: 2) {
                    Text("Anonymous")
                        .font(MarginFonts.caption)
                        .foregroundColor(MarginColors.secondaryText)

                    HStack(spacing: MarginSpacing.xs) {
                        if let ctx = shared.contextType {
                            Text(ctx)
                                .font(MarginFonts.caption)
                                .foregroundColor(MarginColors.accentSecondary)
                        }
                        Text("·")
                            .foregroundColor(MarginColors.divider)
                        Text(shared.timeAgo)
                            .font(MarginFonts.caption)
                            .foregroundColor(MarginColors.secondaryText)
                    }
                }

                Spacer()

                if let mood = shared.moodTag {
                    Text(mood.emoji)
                        .font(.system(size: 16))
                }
            }

            Text(shared.text)
                .font(MarginFonts.body)
                .foregroundColor(MarginColors.primaryText)
                .lineLimit(4)

            Divider()
                .background(MarginColors.divider)

            HStack {
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isLiked.toggle()
                    }
                    onLike()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: isLiked ? "heart.fill" : "heart")
                            .font(.system(size: 14))
                            .foregroundColor(isLiked ? MarginColors.destructive : MarginColors.secondaryText)
                        Text("\(shared.likeCount + (isLiked ? 1 : 0))")
                            .font(MarginFonts.caption)
                            .foregroundColor(MarginColors.secondaryText)
                    }
                }

                Spacer()

                Button {
                    // Reply action
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "bubble.right")
                            .font(.system(size: 14))
                            .foregroundColor(MarginColors.secondaryText)
                        Text("\(shared.replyCount)")
                            .font(MarginFonts.caption)
                            .foregroundColor(MarginColors.secondaryText)
                    }
                }
            }
        }
        .padding(MarginSpacing.md)
        .background(MarginColors.surface)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
    }

    private var avatarGradient: LinearGradient {
        let colors: [[Color]] = [
            [MarginColors.accent, MarginColors.accentSecondary],
            [MarginColors.accentSecondary, MarginColors.accent],
            [Color(hex: "7A776F"), Color(hex: "C4A882")],
            [Color(hex: "9AAEAB"), Color(hex: "C4A882")]
        ]
        let chosen = colors.randomElement() ?? colors[0]
        return LinearGradient(gradient: Gradient(colors: chosen), startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    private var anonymousInitial: String {
        let initials = ["A", "M", "S", "R", "J", "L", "K", "N", "T", "W"]
        return initials.randomElement() ?? "A"
    }
}

// Share moment sheet
struct ShareMomentSheet: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    let moment: Moment

    @State private var isAnonymous = true
    @State private var isSharing = false

    var body: some View {
        NavigationStack {
            ZStack {
                MarginColors.background
                    .ignoresSafeArea()

                VStack(spacing: MarginSpacing.lg) {
                    // Preview of what will be shared
                    VStack(alignment: .leading, spacing: MarginSpacing.sm) {
                        Text("Preview")
                            .font(MarginFonts.caption)
                            .foregroundColor(MarginColors.secondaryText)

                        Text(moment.text)
                            .font(MarginFonts.body)
                            .foregroundColor(MarginColors.primaryText)
                            .padding(MarginSpacing.md)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(MarginColors.surface)
                            .cornerRadius(12)
                    }

                    Toggle("Share anonymously", isOn: $isAnonymous)
                        .tint(MarginColors.accent)
                        .padding(.horizontal, MarginSpacing.md)
                        .padding(MarginSpacing.md)
                        .background(MarginColors.surface)
                        .cornerRadius(12)

                    Text("Your name and identity will never be shared. Only the thought itself.")
                        .font(MarginFonts.caption)
                        .foregroundColor(MarginColors.secondaryText)
                        .multilineTextAlignment(.center)

                    Spacer()

                    Button {
                        shareMoment()
                    } label: {
                        if isSharing {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("Share to Community")
                                .font(MarginFonts.body)
                                .fontWeight(.medium)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(MarginSpacing.md)
                    .background(MarginColors.accent)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .disabled(isSharing)
                }
                .padding(MarginSpacing.lg)
            }
            .navigationTitle("Share Anonymously")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(MarginColors.secondaryText)
                }
            }
        }
    }

    private func shareMoment() {
        isSharing = true
        // R2: In a real app, this would upload to a server
        // For now, simulate network delay
        Task {
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            await MainActor.run {
                isSharing = false
                dismiss()
            }
        }
    }
}

// MARK: - "Most Common Thoughts" aggregate view

struct CommonThoughtsView: View {
    @State private var insights: [AggregatedInsight] = []

    var body: some View {
        NavigationStack {
            ZStack {
                MarginColors.background
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: MarginSpacing.lg) {
                        Text("What others think about in the same situations")
                            .font(MarginFonts.body)
                            .foregroundColor(MarginColors.secondaryText)
                            .multilineTextAlignment(.center)

                        ForEach(insights) { insight in
                            insightCard(insight)
                        }
                    }
                    .padding(MarginSpacing.lg)
                    .padding(.bottom, 100)
                }
            }
            .navigationTitle("Common Thoughts")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            loadInsights()
        }
    }

    private func insightCard(_ insight: AggregatedInsight) -> some View {
        VStack(alignment: .leading, spacing: MarginSpacing.sm) {
            HStack {
                Text(insight.contextEmoji)
                    .font(.system(size: 20))
                Text(insight.context)
                    .font(MarginFonts.subheading)
                    .foregroundColor(MarginColors.primaryText)
                Spacer()
                Text("\(insight.thoughtCount) thoughts")
                    .font(MarginFonts.caption)
                    .foregroundColor(MarginColors.secondaryText)
            }

            Text(insight.topThought)
                .font(MarginFonts.body)
                .foregroundColor(MarginColors.secondaryText)
                .italic()
        }
        .padding(MarginSpacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(MarginColors.surface)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
    }

    private func loadInsights() {
        insights = [
            AggregatedInsight(context: "Traffic lights", contextEmoji: "🚦", thoughtCount: 142, topThought: "Everyone has somewhere to be, but at this exact moment, we're all just... here."),
            AggregatedInsight(context: "Coffee shop lines", contextEmoji: "☕", thoughtCount: 238, topThought: "Is it just me, or does waiting in line make you think about your to-do list more than actually doing it?"),
            AggregatedInsight(context: "Elevators", contextEmoji: "⏳", thoughtCount: 87, topThought: "The 30 seconds of awkward eye contact. The relief when doors open."),
            AggregatedInsight(context: "Morning commute", contextEmoji: "🚗", thoughtCount: 312, topThought: "Why does the song that comes on shuffle always perfectly match what I'm feeling?"),
            AggregatedInsight(context: "Waiting rooms", contextEmoji: "⏰", thoughtCount: 156, topThought: "Every waiting room thought eventually circles back to health, time, or both.")
        ]
    }
}

struct AggregatedInsight: Identifiable {
    let id = UUID()
    let context: String
    let contextEmoji: String
    let thoughtCount: Int
    let topThought: String
}

#Preview {
    SharedFeedView()
        .environmentObject(AppState())
}
