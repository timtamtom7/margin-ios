import SwiftUI

struct WeeklySummaryView: View {
    @EnvironmentObject var appState: AppState
    @State private var weeklySummary: WeeklySummary?
    @State private var isLoading = true
    @State private var isGenerating = false

    var body: some View {
        NavigationStack {
            ZStack {
                MarginColors.background
                    .ignoresSafeArea()

                if isLoading {
                    ProgressView()
                        .tint(MarginColors.accent)
                } else if let summary = weeklySummary {
                    summaryContent(summary)
                } else if isGenerating {
                    generatingView
                } else {
                    emptyStateView
                }
            }
            .navigationTitle("Weekly Summary")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task { await generateWeeklySummary() }
                    } label: {
                        if isGenerating {
                            ProgressView()
                                .tint(MarginColors.accent)
                        } else {
                            Image(systemName: "arrow.triangle.2.circlepath")
                                .foregroundColor(MarginColors.secondaryText)
                        }
                    }
                    .disabled(isGenerating)
                }
            }
        }
        .task {
            await loadWeeklySummary()
        }
    }

    private func summaryContent(_ summary: WeeklySummary) -> some View {
        ScrollView {
            VStack(spacing: MarginSpacing.lg) {
                // Week header card
                weekHeaderCard(summary)

                // Main insight card
                insightCard(summary)

                // Recurring thoughts
                if !summary.recurringThoughts.isEmpty {
                    recurringThoughtsCard(summary.recurringThoughts)
                }

                // Top moods
                if !summary.topMoods.isEmpty {
                    moodsCard(summary.topMoods)
                }

                // Stats breakdown
                statsCard(summary)

                // Tips
                tipsCard(summary)
            }
            .padding(MarginSpacing.lg)
            .padding(.bottom, 100)
        }
    }

    private func weekHeaderCard(_ summary: WeeklySummary) -> some View {
        VStack(alignment: .leading, spacing: MarginSpacing.sm) {
            Text("Week of")
                .font(MarginFonts.caption)
                .foregroundColor(MarginColors.secondaryText)

            Text(summary.formattedWeekRange)
                .font(MarginFonts.heading)
                .foregroundColor(MarginColors.primaryText)

            // Decorative line
            handdrawnLine
        }
        .padding(MarginSpacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(MarginColors.surface)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
    }

    private func insightCard(_ summary: WeeklySummary) -> some View {
        VStack(alignment: .leading, spacing: MarginSpacing.md) {
            HStack {
                Image(systemName: "sparkles")
                    .font(.system(size: 14))
                    .foregroundColor(MarginColors.accent)
                Text("Your Week")
                    .font(MarginFonts.subheading)
                    .foregroundColor(MarginColors.primaryText)
            }

            Text(summary.weeklyInsight)
                .font(MarginFonts.handwritten)
                .foregroundColor(MarginColors.primaryText)
                .italic()
        }
        .padding(MarginSpacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(MarginColors.surface)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
        // Slight rotation for handwritten feel
        .rotationEffect(.degrees(Double.random(in: -0.5...0.5)))
    }

    private func recurringThoughtsCard(_ recurring: [RecurringThought]) -> some View {
        VStack(alignment: .leading, spacing: MarginSpacing.md) {
            HStack {
                Image(systemName: "repeat")
                    .font(.system(size: 14))
                    .foregroundColor(MarginColors.accentSecondary)
                Text("Recurring Thoughts")
                    .font(MarginFonts.subheading)
                    .foregroundColor(MarginColors.primaryText)
            }

            ForEach(recurring) { thought in
                HStack(alignment: .top, spacing: MarginSpacing.sm) {
                    Text("\(thought.occurrenceCount)×")
                        .font(MarginFonts.caption)
                        .foregroundColor(MarginColors.accent)
                        .frame(width: 30, alignment: .leading)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(thought.thoughtText)
                            .font(MarginFonts.body)
                            .foregroundColor(MarginColors.primaryText)

                        if !thought.contexts.isEmpty {
                            Text(thought.contexts.joined(separator: ", "))
                                .font(MarginFonts.caption)
                                .foregroundColor(MarginColors.secondaryText)
                        }
                    }
                }
            }
        }
        .padding(MarginSpacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(MarginColors.surface)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
    }

    private func moodsCard(_ moods: [MoodTag]) -> some View {
        VStack(alignment: .leading, spacing: MarginSpacing.md) {
            HStack {
                Image(systemName: "heart.fill")
                    .font(.system(size: 14))
                    .foregroundColor(MarginColors.destructive)
                Text("How You Felt")
                    .font(MarginFonts.subheading)
                    .foregroundColor(MarginColors.primaryText)
            }

            HStack(spacing: MarginSpacing.lg) {
                ForEach(moods, id: \.self) { mood in
                    VStack(spacing: 4) {
                        Text(mood.emoji)
                            .font(.system(size: 28))
                        Text(mood.displayName)
                            .font(MarginFonts.caption)
                            .foregroundColor(MarginColors.secondaryText)
                    }
                }
            }
        }
        .padding(MarginSpacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(MarginColors.surface)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
    }

    private func statsCard(_ summary: WeeklySummary) -> some View {
        VStack(alignment: .leading, spacing: MarginSpacing.md) {
            HStack {
                Image(systemName: "chart.bar.doc.horizontal")
                    .font(.system(size: 14))
                    .foregroundColor(MarginColors.accent)
                Text("The Numbers")
                    .font(MarginFonts.subheading)
                    .foregroundColor(MarginColors.primaryText)
            }

            HStack(spacing: MarginSpacing.xl) {
                statBox(value: "\(summary.totalMoments)", label: "Total moments")
                statBox(value: "\(summary.totalDeadTimeMinutes)", label: "Minutes captured")
                statBox(value: "\(summary.deepThoughtCount)", label: "Deep thoughts")
            }

            if !summary.topContexts.isEmpty {
                VStack(alignment: .leading, spacing: MarginSpacing.xs) {
                    Text("Most common contexts:")
                        .font(MarginFonts.caption)
                        .foregroundColor(MarginColors.secondaryText)

                    HStack(spacing: MarginSpacing.sm) {
                        ForEach(summary.topContexts, id: \.self) { ctx in
                            Text(ctx)
                                .font(MarginFonts.caption)
                                .foregroundColor(MarginColors.accentSecondary)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(MarginColors.accentSecondary.opacity(0.15))
                                .cornerRadius(8)
                        }
                    }
                }
            }
        }
        .padding(MarginSpacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(MarginColors.surface)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
    }

    private func statBox(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 24, weight: .light, design: .serif))
                .foregroundColor(MarginColors.accent)
            Text(label)
                .font(MarginFonts.caption)
                .foregroundColor(MarginColors.secondaryText)
                .multilineTextAlignment(.center)
        }
    }

    private func tipsCard(_ summary: WeeklySummary) -> some View {
        VStack(alignment: .leading, spacing: MarginSpacing.md) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .font(.system(size: 14))
                    .foregroundColor(MarginColors.accent)
                Text("Weekly Observation")
                    .font(MarginFonts.subheading)
                    .foregroundColor(MarginColors.primaryText)
            }

            let tips = generateTips(from: summary)
            ForEach(tips, id: \.self) { tip in
                HStack(alignment: .top, spacing: MarginSpacing.sm) {
                    Text("→")
                        .foregroundColor(MarginColors.accent)
                    Text(tip)
                        .font(MarginFonts.body)
                        .foregroundColor(MarginColors.secondaryText)
                }
            }
        }
        .padding(MarginSpacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(MarginColors.surface)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
    }

    private var generatingView: some View {
        VStack(spacing: MarginSpacing.lg) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(MarginColors.accent)

            Text("Analyzing your week...")
                .font(MarginFonts.subheading)
                .foregroundColor(MarginColors.secondaryText)

            Text("Looking for patterns across your moments")
                .font(MarginFonts.caption)
                .foregroundColor(MarginColors.secondaryText)
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: MarginSpacing.lg) {
            MarginEmptyIllustration(size: 160)

            Text("No weekly summary yet")
                .font(MarginFonts.subheading)
                .foregroundColor(MarginColors.primaryText)

            Text("Capture more moments throughout the week and I'll summarize what your dead time reveals.")
                .font(MarginFonts.body)
                .foregroundColor(MarginColors.secondaryText)
                .multilineTextAlignment(.center)

            Button {
                Task { await generateWeeklySummary() }
            } label: {
                Text("Generate Summary")
                    .font(MarginFonts.body)
                    .foregroundColor(MarginColors.accent)
            }
            .padding(.top, MarginSpacing.md)
        }
        .padding(MarginSpacing.xxl)
    }

    private var handdrawnLine: some View {
        Path { path in
            path.move(to: CGPoint(x: 0, y: 0))
            path.addQuadCurve(to: CGPoint(x: 150, y: 2), control: CGPoint(x: 75, y: -2))
        }
        .stroke(MarginColors.accent.opacity(0.4), lineWidth: 1.5)
        .frame(height: 4)
    }

    private func loadWeeklySummary() async {
        isLoading = true
        do {
            weeklySummary = try await appState.databaseService.fetchWeeklySummary(forWeekContaining: Date())
        } catch {
            print("Load weekly summary error: \(error)")
        }
        isLoading = false
    }

    private func generateWeeklySummary() async {
        isGenerating = true
        do {
            let allMoments = try await appState.databaseService.fetchAllMoments()
            let summary = appState.aiService.generateWeeklySummary(moments: allMoments)
            try await appState.databaseService.saveWeeklySummary(summary)
            weeklySummary = summary
        } catch {
            print("Generate weekly summary error: \(error)")
        }
        isGenerating = false
    }

    private func generateTips(from summary: WeeklySummary) -> [String] {
        var tips: [String] = []

        if summary.deepThoughtCount > 5 {
            tips.append("You had \(summary.deepThoughtCount) deep thoughts this week — your most reflective week yet.")
        }

        if summary.totalMoments > 30 {
            tips.append("You're capturing a lot of moments. That's great for pattern detection.")
        }

        if let firstRecurring = summary.recurringThoughts.first, firstRecurring.occurrenceCount > 5 {
            tips.append("'\(firstRecurring.thoughtText)' keeps coming up. It might be worth addressing directly.")
        }

        if summary.topContexts.count > 0 {
            let topCtx = summary.topContexts.first ?? ""
            tips.append("Most of your dead time happens during \(topCtx). That's your thinking hotspot.")
        }

        if tips.isEmpty {
            tips.append("Keep capturing — the more moments, the clearer your patterns become.")
        }

        return tips
    }
}

#Preview {
    WeeklySummaryView()
        .environmentObject(AppState())
}
