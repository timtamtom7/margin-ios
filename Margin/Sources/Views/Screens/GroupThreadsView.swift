import SwiftUI

// R9: Group Threads — small private groups for sharing moments with trusted people
struct GroupThreadsView: View {
    @EnvironmentObject var appState: AppState
    @State private var groupThreads: [GroupThread] = []
    @State private var isLoading = true
    @State private var showingCreateSheet = false
    @State private var selectedThread: GroupThread?

    var body: some View {
        NavigationStack {
            ZStack {
                MarginColors.background
                    .ignoresSafeArea()

                if isLoading {
                    ProgressView()
                        .tint(MarginColors.accent)
                } else if groupThreads.isEmpty {
                    emptyStateView
                } else {
                    threadsContent
                }
            }
            .navigationTitle("My Groups")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingCreateSheet = true
                    } label: {
                        Image(systemName: "plus.circle")
                            .foregroundColor(MarginColors.accent)
                    }
                }
            }
            .sheet(isPresented: $showingCreateSheet) {
                CreateGroupThreadSheet { newThread in
                    groupThreads.insert(newThread, at: 0)
                }
            }
            .sheet(item: $selectedThread) { thread in
                GroupThreadDetailView(thread: thread, moments: getMoments(for: thread))
            }
        }
        .task {
            await loadGroupThreads()
        }
    }

    private var threadsContent: some View {
        ScrollView {
            LazyVStack(spacing: MarginSpacing.md) {
                ForEach(groupThreads) { thread in
                    GroupThreadCard(thread: thread) {
                        selectedThread = thread
                    }
                }
            }
            .padding(MarginSpacing.lg)
            .padding(.bottom, 100)
        }
        .refreshable {
            await loadGroupThreads()
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: MarginSpacing.lg) {
            Image(systemName: "person.2.circle")
                .font(.system(size: 64))
                .foregroundColor(MarginColors.accent.opacity(0.2))

            Text("Private group threads")
                .font(MarginFonts.subheading)
                .foregroundColor(MarginColors.primaryText)

            Text("Start a thread with close friends or family. Share moments anonymously within your group — only your chosen name is visible.")
                .font(MarginFonts.body)
                .foregroundColor(MarginColors.secondaryText)
                .multilineTextAlignment(.center)

            Button {
                showingCreateSheet = true
            } label: {
                Text("Start a group")
                    .font(MarginFonts.body)
                    .foregroundColor(.white)
                    .padding(.horizontal, MarginSpacing.xl)
                    .padding(.vertical, MarginSpacing.md)
                    .background(MarginColors.accent)
                    .cornerRadius(12)
            }
            .padding(.top, MarginSpacing.md)
        }
        .padding(MarginSpacing.xxl)
    }

    private func loadGroupThreads() async {
        isLoading = true
        // R9: In a real app, this would fetch from a server
        // For now, generate sample data
        groupThreads = generateSampleGroupThreads()
        isLoading = false
    }

    private func getMoments(for thread: GroupThread) -> [GroupSharedMoment] {
        // Generate sample moments for the thread
        return generateSampleGroupMoments(for: thread)
    }

    private func generateSampleGroupThreads() -> [GroupThread] {
        [
            GroupThread(
                name: "Late Night Thinkers",
                memberCount: 4,
                memberInitials: ["A", "M", "S", "J"],
                momentCount: 12,
                lastActivityAt: Date().addingTimeInterval(-1800)
            ),
            GroupThread(
                name: "Family Margin",
                memberCount: 3,
                memberInitials: ["M", "D", "S"],
                momentCount: 7,
                lastActivityAt: Date().addingTimeInterval(-7200)
            )
        ]
    }

    private func generateSampleGroupMoments(for thread: GroupThread) -> [GroupSharedMoment] {
        [
            GroupSharedMoment(
                text: "Does anyone else find that 11pm thoughts are always the most interesting?",
                moodTag: .curious,
                contextType: "🚗 night",
                fromName: "Alex",
                fromInitials: "A",
                timestamp: Date().addingTimeInterval(-600),
                likeCount: 2
            ),
            GroupSharedMoment(
                text: "Yes — it's like my brain finally stops performing and starts actually thinking.",
                moodTag: .calm,
                contextType: "🏠 night",
                fromName: "Sam",
                fromInitials: "S",
                timestamp: Date().addingTimeInterval(-1200),
                likeCount: 1
            ),
            GroupSharedMoment(
                text: "I had a really good idea about my project tonight. I almost forgot it.",
                moodTag: .creative,
                contextType: "☕ night",
                fromName: "Maya",
                fromInitials: "M",
                timestamp: Date().addingTimeInterval(-2400),
                likeCount: 3
            )
        ]
    }
}

// MARK: - Group Thread Card

struct GroupThreadCard: View {
    let thread: GroupThread
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: MarginSpacing.md) {
                // Member avatars
                HStack(spacing: -8) {
                    ForEach(Array(thread.memberInitials.prefix(3).enumerated()), id: \.offset) { _, initial in
                        Circle()
                            .fill(avatarColor(for: initial))
                            .frame(width: 28, height: 28)
                            .overlay(
                                Text(initial)
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(.white)
                            )
                    }
                    if thread.memberCount > 3 {
                        Circle()
                            .fill(MarginColors.divider)
                            .frame(width: 28, height: 28)
                            .overlay(
                                Text("+\(thread.memberCount - 3)")
                                    .font(.system(size: 10))
                                    .foregroundColor(MarginColors.secondaryText)
                            )
                    }
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(thread.name)
                        .font(MarginFonts.subheading)
                        .foregroundColor(MarginColors.primaryText)

                    HStack(spacing: MarginSpacing.sm) {
                        Text("\(thread.memberCount) members")
                            .font(MarginFonts.caption)
                            .foregroundColor(MarginColors.secondaryText)

                        Text("·")
                            .foregroundColor(MarginColors.divider)

                        Text("\(thread.momentCount) shared")
                            .font(MarginFonts.caption)
                            .foregroundColor(MarginColors.secondaryText)

                        Text("·")
                            .foregroundColor(MarginColors.divider)

                        Text(thread.timeAgo)
                            .font(MarginFonts.caption)
                            .foregroundColor(MarginColors.secondaryText)
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundColor(MarginColors.secondaryText)
            }
            .padding(MarginSpacing.md)
            .background(MarginColors.surface)
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }

    private func avatarColor(for initial: String) -> Color {
        let colors: [Color] = [
            Color(hex: "C4A882"),
            Color(hex: "9AAEAB"),
            Color(hex: "A8B5A0"),
            Color(hex: "B8A090"),
            Color(hex: "9AADAB")
        ]
        let index = abs(initial.hashValue) % colors.count
        return colors[index]
    }
}

// MARK: - Group Thread Detail View

struct GroupThreadDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let thread: GroupThread
    let moments: [GroupSharedMoment]

    @State private var replyText = ""
    @State private var sharedMoments: [GroupSharedMoment] = []

    var body: some View {
        NavigationStack {
            ZStack {
                MarginColors.background
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Thread header
                    threadHeader

                    // Moments
                    ScrollView {
                        LazyVStack(spacing: MarginSpacing.md) {
                            ForEach(sharedMoments) { moment in
                                GroupSharedMomentCard(moment: moment)
                            }
                        }
                        .padding(MarginSpacing.lg)
                        .padding(.bottom, 80)
                    }

                    // Reply bar
                    replyBar
                }
            }
            .navigationTitle(thread.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(MarginColors.accent)
                }
            }
        }
        .onAppear {
            sharedMoments = moments
        }
    }

    private var threadHeader: some View {
        HStack(spacing: MarginSpacing.md) {
            HStack(spacing: -6) {
                ForEach(Array(thread.memberInitials.prefix(4).enumerated()), id: \.offset) { _, initial in
                    Circle()
                        .fill(avatarColor(for: initial))
                        .frame(width: 24, height: 24)
                        .overlay(
                            Text(initial)
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(.white)
                        )
                }
            }

            Text("\(thread.memberCount) members")
                .font(MarginFonts.caption)
                .foregroundColor(MarginColors.secondaryText)

            Spacer()

            Text(thread.timeAgo)
                .font(MarginFonts.caption)
                .foregroundColor(MarginColors.secondaryText)
        }
        .padding(MarginSpacing.md)
        .background(MarginColors.surface)
    }

    private var replyBar: some View {
        HStack(spacing: MarginSpacing.sm) {
            TextField("Share a thought...", text: $replyText)
                .font(MarginFonts.body)
                .padding(.horizontal, MarginSpacing.md)
                .padding(.vertical, MarginSpacing.sm)
                .background(MarginColors.surface)
                .cornerRadius(20)

            Button {
                sendReply()
            } label: {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 28))
                    .foregroundColor(replyText.isEmpty ? MarginColors.divider : MarginColors.accent)
            }
            .disabled(replyText.isEmpty)
        }
        .padding(MarginSpacing.md)
        .background(MarginColors.background)
    }

    private func sendReply() {
        let moment = GroupSharedMoment(
            text: replyText,
            fromName: "You",
            fromInitials: "Y",
            timestamp: Date()
        )
        sharedMoments.append(moment)
        replyText = ""
    }

    private func avatarColor(for initial: String) -> Color {
        let colors: [Color] = [
            Color(hex: "C4A882"),
            Color(hex: "9AAEAB"),
            Color(hex: "A8B5A0"),
            Color(hex: "B8A090"),
            Color(hex: "9AADAB")
        ]
        let index = abs(initial.hashValue) % colors.count
        return colors[index]
    }
}

// MARK: - Group Shared Moment Card

struct GroupSharedMomentCard: View {
    let moment: GroupSharedMoment

    var body: some View {
        VStack(alignment: .leading, spacing: MarginSpacing.sm) {
            HStack {
                // Avatar
                Circle()
                    .fill(Color(hex: "C4A882").opacity(0.3))
                    .frame(width: 28, height: 28)
                    .overlay(
                        Text(moment.fromInitials)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(MarginColors.accent)
                    )

                VStack(alignment: .leading, spacing: 2) {
                    Text(moment.fromName)
                        .font(MarginFonts.caption)
                        .foregroundColor(MarginColors.primaryText)

                    HStack(spacing: 4) {
                        if let ctx = moment.contextType {
                            Text(ctx)
                                .font(MarginFonts.caption)
                                .foregroundColor(MarginColors.accentSecondary)
                        }
                        Text("·")
                            .foregroundColor(MarginColors.divider)
                        Text(moment.timeAgo)
                            .font(MarginFonts.caption)
                            .foregroundColor(MarginColors.secondaryText)
                    }
                }

                Spacer()

                if let mood = moment.moodTag {
                    Text(mood.emoji)
                        .font(.system(size: 14))
                }
            }

            Text(moment.text)
                .font(MarginFonts.body)
                .foregroundColor(MarginColors.primaryText)
                .lineLimit(4)

            HStack {
                Button {
                    // Like action
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "heart")
                            .font(.system(size: 12))
                        Text("\(moment.likeCount)")
                            .font(MarginFonts.caption)
                    }
                    .foregroundColor(MarginColors.secondaryText)
                }
                .buttonStyle(.plain)

                Button {
                    // Reply action
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "bubble.right")
                            .font(.system(size: 12))
                        if moment.hasReplied {
                            Text("Replied")
                                .font(MarginFonts.caption)
                        }
                    }
                    .foregroundColor(MarginColors.secondaryText)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(MarginSpacing.md)
        .background(MarginColors.surface)
        .cornerRadius(12)
    }
}

// MARK: - Create Group Thread Sheet

struct CreateGroupThreadSheet: View {
    @Environment(\.dismiss) private var dismiss
    let onCreated: (GroupThread) -> Void

    @State private var groupName = ""
    @State private var memberCount = 2
    @State private var yourName = ""

    var body: some View {
        NavigationStack {
            ZStack {
                MarginColors.background
                    .ignoresSafeArea()

                VStack(spacing: MarginSpacing.xl) {
                    VStack(alignment: .leading, spacing: MarginSpacing.sm) {
                        Text("Give your group a name")
                            .font(MarginFonts.subheading)
                            .foregroundColor(MarginColors.primaryText)

                        TextField("e.g., Late Night Thinkers", text: $groupName)
                            .font(MarginFonts.body)
                            .padding(MarginSpacing.md)
                            .background(MarginColors.surface)
                            .cornerRadius(12)
                    }

                    VStack(alignment: .leading, spacing: MarginSpacing.sm) {
                        Text("Your display name in this group")
                            .font(MarginFonts.subheading)
                            .foregroundColor(MarginColors.primaryText)

                        TextField("e.g., Alex", text: $yourName)
                            .font(MarginFonts.body)
                            .padding(MarginSpacing.md)
                            .background(MarginColors.surface)
                            .cornerRadius(12)

                        Text("Others will see this name, not your real identity.")
                            .font(MarginFonts.caption)
                            .foregroundColor(MarginColors.secondaryText)
                    }

                    VStack(alignment: .leading, spacing: MarginSpacing.sm) {
                        Text("Group size")
                            .font(MarginFonts.subheading)
                            .foregroundColor(MarginColors.primaryText)

                        Text("Small groups work best. You can always invite more later.")
                            .font(MarginFonts.caption)
                            .foregroundColor(MarginColors.secondaryText)
                    }

                    Spacer()

                    Button {
                        createGroup()
                    } label: {
                        Text("Create Group")
                            .font(MarginFonts.body)
                            .fontWeight(.medium)
                            .frame(maxWidth: .infinity)
                            .padding(MarginSpacing.md)
                            .background(MarginColors.accent)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    .disabled(groupName.isEmpty || yourName.isEmpty)
                }
                .padding(MarginSpacing.xl)
            }
            .navigationTitle("New Group")
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

    private func createGroup() {
        let initials = String(yourName.prefix(1)).uppercased()
        let thread = GroupThread(
            name: groupName,
            memberCount: 1,
            memberInitials: [initials],
            momentCount: 0,
            lastActivityAt: Date(),
            isJoined: true
        )
        onCreated(thread)
        dismiss()
    }
}

#Preview {
    GroupThreadsView()
        .environmentObject(AppState())
}
