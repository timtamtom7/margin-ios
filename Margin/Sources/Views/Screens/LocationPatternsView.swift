import SwiftUI

// R7: Location Patterns View — privacy-first insights about where you think
struct LocationPatternsView: View {
    @EnvironmentObject var appState: AppState
    @State private var locationPatterns: [LocationPattern] = []
    @State private var isLoading = true
    @State private var selectedPattern: LocationPattern?

    var body: some View {
        NavigationStack {
            ZStack {
                MarginColors.background
                    .ignoresSafeArea()

                if isLoading {
                    ProgressView()
                        .tint(MarginColors.accent)
                } else if locationPatterns.isEmpty {
                    emptyStateView
                } else {
                    patternsContent
                }
            }
            .navigationTitle("Where You Think")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        LocationPrivacyInfoView()
                    } label: {
                        Image(systemName: "lock.shield")
                            .foregroundColor(MarginColors.secondaryText)
                    }
                }
            }
            .sheet(item: $selectedPattern) { pattern in
                LocationPatternDetailView(pattern: pattern)
            }
        }
        .task {
            await loadLocationPatterns()
        }
    }

    private var patternsContent: some View {
        ScrollView {
            VStack(spacing: MarginSpacing.lg) {
                // Privacy notice
                privacyBanner

                Text("Your thoughts by location")
                    .font(MarginFonts.subheading)
                    .foregroundColor(MarginColors.primaryText)
                    .frame(maxWidth: .infinity, alignment: .leading)

                ForEach(locationPatterns) { pattern in
                    LocationPatternCard(pattern: pattern) {
                        selectedPattern = pattern
                    }
                }

                Text("Location is inferred from time patterns — no GPS coordinates are stored.")
                    .font(MarginFonts.caption)
                    .foregroundColor(MarginColors.secondaryText)
                    .italic()
                    .padding(.top, MarginSpacing.sm)
            }
            .padding(MarginSpacing.lg)
            .padding(.bottom, 100)
        }
        .refreshable {
            await loadLocationPatterns()
        }
    }

    private var privacyBanner: some View {
        HStack(spacing: MarginSpacing.sm) {
            Image(systemName: "lock.fill")
                .font(.system(size: 12))
                .foregroundColor(MarginColors.accentSecondary)

            Text("Privacy-first: your location is estimated from time of day, never from GPS.")
                .font(MarginFonts.caption)
                .foregroundColor(MarginColors.secondaryText)

            Spacer()
        }
        .padding(MarginSpacing.sm)
        .background(MarginColors.accentSecondary.opacity(0.1))
        .cornerRadius(8)
    }

    private var emptyStateView: some View {
        VStack(spacing: MarginSpacing.lg) {
            Image(systemName: "mappin.and.ellipse")
                .font(.system(size: 64))
                .foregroundColor(MarginColors.accent.opacity(0.2))

            Text("Location patterns")
                .font(MarginFonts.subheading)
                .foregroundColor(MarginColors.primaryText)

            Text("As you capture moments, Margin learns what you think about in different places — inferred from time patterns, not GPS.")
                .font(MarginFonts.body)
                .foregroundColor(MarginColors.secondaryText)
                .multilineTextAlignment(.center)

            NavigationLink {
                LocationPrivacyInfoView()
            } label: {
                Text("Learn about privacy")
                    .font(MarginFonts.caption)
                    .foregroundColor(MarginColors.accent)
            }
        }
        .padding(MarginSpacing.xxl)
    }

    private func loadLocationPatterns() async {
        isLoading = true
        do {
            let moments = try await appState.databaseService.fetchAllMoments()
            locationPatterns = appState.aiService.generateLocationPatterns(moments: moments)
        } catch {
            print("Load location patterns error: \(error)")
        }
        isLoading = false
    }
}

// MARK: - Location Pattern Card

struct LocationPatternCard: View {
    let pattern: LocationPattern
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: MarginSpacing.md) {
                HStack {
                    Text(pattern.locationEmoji)
                        .font(.system(size: 24))

                    Text(pattern.locationType.capitalized)
                        .font(MarginFonts.subheading)
                        .foregroundColor(MarginColors.primaryText)

                    Spacer()

                    Text("\(pattern.momentCount) moments")
                        .font(MarginFonts.caption)
                        .foregroundColor(MarginColors.secondaryText)
                }

                if let mood = pattern.dominantMood {
                    HStack(spacing: 4) {
                        Text(mood.emoji)
                            .font(.system(size: 14))
                        Text("Mostly \(mood.displayName.lowercased())")
                            .font(MarginFonts.caption)
                            .foregroundColor(MarginColors.secondaryText)
                    }
                }

                HStack(spacing: MarginSpacing.sm) {
                    Image(systemName: "clock")
                        .font(.system(size: 11))
                        .foregroundColor(MarginColors.accentSecondary)
                    Text("Peak: \(pattern.averageTimeOfDay)")
                        .font(MarginFonts.caption)
                        .foregroundColor(MarginColors.accentSecondary)
                }

                // Preview of top thoughts
                if !pattern.topThoughts.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(pattern.topThoughts.prefix(2), id: \.self) { thought in
                            Text("• \"\(thought.prefix(60))...\"")
                                .font(MarginFonts.caption)
                                .foregroundColor(MarginColors.secondaryText)
                                .lineLimit(1)
                        }
                    }
                    .padding(.top, 4)
                }
            }
            .padding(MarginSpacing.lg)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(MarginColors.surface)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Location Pattern Detail View

struct LocationPatternDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let pattern: LocationPattern

    var body: some View {
        NavigationStack {
            ZStack {
                MarginColors.background
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: MarginSpacing.xl) {
                        // Header
                        HStack {
                            Text(pattern.locationEmoji)
                                .font(.system(size: 48))
                            VStack(alignment: .leading) {
                                Text(pattern.locationType.capitalized)
                                    .font(MarginFonts.heading)
                                    .foregroundColor(MarginColors.primaryText)
                                Text("\(pattern.momentCount) moments captured here")
                                    .font(MarginFonts.caption)
                                    .foregroundColor(MarginColors.secondaryText)
                            }
                        }

                        Divider().background(MarginColors.divider)

                        // Stats
                        HStack(spacing: MarginSpacing.xl) {
                            statItem(value: pattern.averageTimeOfDay.capitalized, label: "Peak time")
                            if let mood = pattern.dominantMood {
                                statItem(value: mood.emoji + " " + mood.displayName, label: "Dominant mood")
                            }
                        }

                        // Top thoughts
                        if !pattern.topThoughts.isEmpty {
                            VStack(alignment: .leading, spacing: MarginSpacing.md) {
                                Text("What you think about here")
                                    .font(MarginFonts.subheading)
                                    .foregroundColor(MarginColors.primaryText)

                                ForEach(pattern.topThoughts, id: \.self) { thought in
                                    HStack(alignment: .top, spacing: MarginSpacing.sm) {
                                        Text("→")
                                            .foregroundColor(MarginColors.accent)
                                        Text(thought)
                                            .font(MarginFonts.body)
                                            .foregroundColor(MarginColors.primaryText)
                                    }
                                }
                            }
                        }

                        // Privacy note
                        HStack(spacing: MarginSpacing.sm) {
                            Image(systemName: "lock.shield.fill")
                                .font(.system(size: 12))
                                .foregroundColor(MarginColors.accentSecondary)
                            Text(pattern.privacyNote)
                                .font(MarginFonts.caption)
                                .foregroundColor(MarginColors.secondaryText)
                        }
                        .padding(MarginSpacing.md)
                        .background(MarginColors.accentSecondary.opacity(0.1))
                        .cornerRadius(8)
                    }
                    .padding(MarginSpacing.xl)
                }
            }
            .navigationTitle("Location Insight")
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
    }

    private func statItem(value: String, label: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(value)
                .font(MarginFonts.body)
                .foregroundColor(MarginColors.primaryText)
            Text(label)
                .font(MarginFonts.caption)
                .foregroundColor(MarginColors.secondaryText)
        }
    }
}

// MARK: - Location Privacy Info View

struct LocationPrivacyInfoView: View {
    var body: some View {
        ZStack {
            MarginColors.background
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: MarginSpacing.xl) {
                    HStack {
                        Image(systemName: "lock.shield.fill")
                            .font(.system(size: 32))
                            .foregroundColor(MarginColors.accent)
                        Text("Your Location Privacy")
                            .font(MarginFonts.heading)
                            .foregroundColor(MarginColors.primaryText)
                    }

                    VStack(alignment: .leading, spacing: MarginSpacing.md) {
                        privacyPoint(
                            icon: "clock",
                            title: "Time-based inference",
                            body: "Margin estimates your location from the time of day and day of week — not from GPS or actual coordinates."
                        )

                        privacyPoint(
                            icon: "map",
                            title: "No GPS stored",
                            body: "Your device's precise location is never recorded, transmitted, or stored. Margin only knows 'morning on a weekday = probably at work.'"
                        )

                        privacyPoint(
                            icon: "icloud.slash",
                            title: "Local only",
                            body: "Even the time-based estimates stay on your device. Nothing is sent to any server."
                        )

                        privacyPoint(
                            icon: "eye.slash",
                            title: "You control everything",
                            body: "Turn off location estimation anytime in Settings. Margin will only use the time-of-day context."
                        )
                    }

                    Text("Margin is designed to understand context without compromising privacy. The insights come from patterns in when you think, not where you are.")
                        .font(MarginFonts.body)
                        .foregroundColor(MarginColors.secondaryText)
                        .italic()
                        .padding(.top, MarginSpacing.md)
                }
                .padding(MarginSpacing.xl)
            }
        }
        .navigationTitle("Privacy")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func privacyPoint(icon: String, title: String, body: String) -> some View {
        HStack(alignment: .top, spacing: MarginSpacing.md) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(MarginColors.accent)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(MarginFonts.subheading)
                    .foregroundColor(MarginColors.primaryText)
                Text(body)
                    .font(MarginFonts.body)
                    .foregroundColor(MarginColors.secondaryText)
            }
        }
    }
}

#Preview {
    LocationPatternsView()
        .environmentObject(AppState())
}
