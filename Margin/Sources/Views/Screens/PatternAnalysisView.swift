import SwiftUI

struct PatternAnalysisView: View {
    @EnvironmentObject var appState: AppState
    @State private var patterns: [Pattern] = []
    @State private var isLoading = true
    @State private var isAnalyzing = false

    var body: some View {
        NavigationStack {
            ZStack {
                MarginColors.background
                    .ignoresSafeArea()

                if isLoading {
                    ProgressView()
                        .tint(MarginColors.accent)
                } else if patterns.isEmpty {
                    emptyStateView
                } else {
                    patternsContent
                }
            }
            .navigationTitle("Patterns")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task { await analyzePatterns() }
                    } label: {
                        if isAnalyzing {
                            ProgressView()
                                .tint(MarginColors.accent)
                        } else {
                            Image(systemName: "arrow.triangle.2.circlepath")
                                .foregroundColor(MarginColors.secondaryText)
                        }
                    }
                    .disabled(isAnalyzing)
                }
            }
        }
        .task {
            await loadPatterns()
        }
    }

    private var patternsContent: some View {
        ScrollView {
            VStack(spacing: MarginSpacing.lg) {
                Text("What your dead time reveals")
                    .font(MarginFonts.body)
                    .foregroundColor(MarginColors.secondaryText)
                    .frame(maxWidth: .infinity, alignment: .leading)

                ForEach(patterns) { pattern in
                    PatternCard(pattern: pattern)
                }

                Text("Patterns emerge after capturing several moments. Keep journaling to reveal yours.")
                    .font(MarginFonts.caption)
                    .foregroundColor(MarginColors.secondaryText)
                    .italic()
                    .padding(.top, MarginSpacing.md)
            }
            .padding(MarginSpacing.lg)
            .padding(.bottom, 100)
        }
        .refreshable {
            await loadPatterns()
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: MarginSpacing.lg) {
            Image(systemName: "sparkles")
                .font(.system(size: 48))
                .foregroundColor(MarginColors.divider)

            Text("Patterns emerge over time")
                .font(MarginFonts.subheading)
                .foregroundColor(MarginColors.primaryText)

            Text("Keep capturing your micro-moments.\nAs you collect more thoughts in different contexts, AI will surface what your mind wanders to most.")
                .font(MarginFonts.body)
                .foregroundColor(MarginColors.secondaryText)
                .multilineTextAlignment(.center)

            if !isAnalyzing {
                Button {
                    Task { await analyzePatterns() }
                } label: {
                    Text("Analyze now")
                        .font(MarginFonts.body)
                        .foregroundColor(MarginColors.accent)
                }
                .padding(.top, MarginSpacing.md)
            } else {
                VStack(spacing: MarginSpacing.sm) {
                    ProgressView()
                        .tint(MarginColors.accent)
                    Text("Looking for patterns...")
                        .font(MarginFonts.caption)
                        .foregroundColor(MarginColors.secondaryText)
                }
            }
        }
        .padding(MarginSpacing.xxl)
    }

    private func loadPatterns() async {
        isLoading = true
        do {
            patterns = try await appState.databaseService.fetchAllPatterns()
        } catch {
            print("Load patterns error: \(error)")
        }
        isLoading = false
    }

    private func analyzePatterns() async {
        isAnalyzing = true
        do {
            try await appState.databaseService.deleteAllPatterns()
            let moments = try await appState.databaseService.fetchAllMoments()
            let newPatterns = await appState.aiService.analyzePatterns(moments: moments)
            for pattern in newPatterns {
                try await appState.databaseService.savePattern(pattern)
            }
            patterns = newPatterns
        } catch {
            print("Analyze error: \(error)")
        }
        isAnalyzing = false
    }
}

#Preview {
    PatternAnalysisView()
        .environmentObject(AppState())
}
