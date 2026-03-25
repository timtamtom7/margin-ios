import SwiftUI
import UIKit

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @State private var columnVisibility: NavigationSplitViewVisibility = .all

    var body: some View {
        Group {
            if UIDevice.current.userInterfaceIdiom == .pad {
                iPadContentView
            } else {
                iPhoneContentView
            }
        }
    }

    private var iPhoneContentView: some View {
        ZStack {
            TabView(selection: $appState.selectedTab) {
                HomeView()
                    .tabItem {
                        Label("Home", systemImage: "house")
                    }
                    .tag(AppState.Tab.home)

                MomentStreamView()
                    .tabItem {
                        Label("Stream", systemImage: "list.bullet")
                    }
                    .tag(AppState.Tab.stream)

                PatternAnalysisView()
                    .tabItem {
                        Label("Patterns", systemImage: "sparkles")
                    }
                    .tag(AppState.Tab.patterns)

                ThreadsListView()
                    .tabItem {
                        Label("Threads", systemImage: "link")
                    }
                    .tag(AppState.Tab.threads)

                SharedFeedView()
                    .tabItem {
                        Label("Community", systemImage: "person.3")
                    }
                    .tag(AppState.Tab.community)

                GroupThreadsView()
                    .tabItem {
                        Label("Groups", systemImage: "person.2")
                    }
                    .tag(AppState.Tab.groups)
            }
            .tint(MarginColors.accent)

            VStack {
                Spacer()
                HStack {
                    Spacer()
                    CaptureButton {
                        appState.isShowingCapture = true
                    }
                    .padding(.trailing, MarginSpacing.lg)
                    .padding(.bottom, MarginSpacing.lg)
                }
            }
        }
        .sheet(isPresented: $appState.isShowingCapture) {
            CaptureView()
                .environmentObject(appState)
        }
    }

    private var iPadContentView: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            // Sidebar
            List {
                NavigationLink(destination: HomeView()) {
                    Label("Home", systemImage: "house")
                }
                NavigationLink(destination: MomentStreamView()) {
                    Label("Stream", systemImage: "list.bullet")
                }
                NavigationLink(destination: PatternAnalysisView()) {
                    Label("Patterns", systemImage: "sparkles")
                }
                NavigationLink(destination: ThreadsListView()) {
                    Label("Threads", systemImage: "link")
                }
                NavigationLink(destination: SharedFeedView()) {
                    Label("Community", systemImage: "person.3")
                }
                NavigationLink(destination: GroupThreadsView()) {
                    Label("Groups", systemImage: "person.2")
                }
                NavigationLink(destination: WeeklySummaryView()) {
                    Label("Weekly Summary", systemImage: "calendar")
                }
            }
            .navigationTitle("Margin")
            .navigationSplitViewColumnWidth(min: 220, ideal: 260, max: 300)
        } detail: {
            NavigationStack {
                ZStack {
                    MarginColors.background.ignoresSafeArea()
                    VStack(spacing: MarginSpacing.lg) {
                        Image(systemName: "text.quote")
                            .font(.system(size: 72))
                            .foregroundColor(MarginColors.accent.opacity(0.1))
                        Text("Select a view from the sidebar")
                            .font(.title3)
                            .foregroundColor(MarginColors.secondaryText)
                    }
                }
                .navigationTitle("Margin")
                .navigationBarTitleDisplayMode(.large)
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button {
                            appState.isShowingCapture = true
                        } label: {
                            Image(systemName: "square.and.pencil")
                                .foregroundColor(MarginColors.accent)
                        }
                    }
                }
            }
        }
        .tint(MarginColors.accent)
        .sheet(isPresented: $appState.isShowingCapture) {
            CaptureView()
                .environmentObject(appState)
        }
    }
}

// MARK: - Threads List View

struct ThreadsListView: View {
    @EnvironmentObject var appState: AppState
    @State private var threads: [MomentThread] = []
    @State private var threadMoments: [UUID: [Moment]] = [:]
    @State private var isLoading = true

    var body: some View {
        NavigationStack {
            ZStack {
                MarginColors.background
                    .ignoresSafeArea()

                if isLoading {
                    ProgressView()
                        .tint(MarginColors.accent)
                } else if threads.isEmpty {
                    emptyStateView
                } else {
                    threadsContent
                }
            }
            .navigationTitle("Threads")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        WeeklySummaryView()
                    } label: {
                        Image(systemName: "calendar")
                            .foregroundColor(MarginColors.secondaryText)
                    }
                }
            }
        }
        .task {
            await loadThreads()
        }
    }

    private var threadsContent: some View {
        ScrollView {
            LazyVStack(spacing: MarginSpacing.md) {
                let abandoned = threads.filter { !$0.isActive }
                if !abandoned.isEmpty {
                    Section {
                        ForEach(abandoned) { thread in
                            if let moments = threadMoments[thread.id], !moments.isEmpty {
                                AbandonedThreadReminderView(thread: thread, moments: moments)
                            }
                        }
                    } header: {
                        HStack {
                            Text("Abandoned threads")
                                .font(MarginFonts.caption)
                                .foregroundColor(MarginColors.secondaryText)
                            Spacer()
                        }
                        .padding(.horizontal, MarginSpacing.lg)
                    }
                }

                let active = threads.filter { $0.isActive }
                if !active.isEmpty {
                    Section {
                        ForEach(active) { thread in
                            NavigationLink {
                                ThreadView(thread: thread)
                            } label: {
                                if let moments = threadMoments[thread.id] {
                                    ThreadPreviewCard(thread: thread, moments: moments)
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    } header: {
                        HStack {
                            Text("Active threads")
                                .font(MarginFonts.caption)
                                .foregroundColor(MarginColors.secondaryText)
                            Spacer()
                        }
                        .padding(.horizontal, MarginSpacing.lg)
                    }
                }
            }
            .padding(.vertical, MarginSpacing.md)
            .padding(.bottom, 100)
        }
        .refreshable {
            await loadThreads()
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: MarginSpacing.lg) {
            MarginEmptyIllustration(size: 160)

            Text("No threads yet")
                .font(MarginFonts.subheading)
                .foregroundColor(MarginColors.primaryText)

            Text("When a thought keeps coming back, Margin will link them together into a thread.")
                .font(MarginFonts.body)
                .foregroundColor(MarginColors.secondaryText)
                .multilineTextAlignment(.center)

            NavigationLink {
                WeeklySummaryView()
            } label: {
                Text("View weekly summary")
                    .font(MarginFonts.body)
                    .foregroundColor(MarginColors.accent)
            }
            .padding(.top, MarginSpacing.md)
        }
        .padding(MarginSpacing.xxl)
    }

    private func loadThreads() async {
        isLoading = true
        do {
            threads = try await appState.databaseService.fetchActiveThreads()
            for thread in threads {
                let moments = try await appState.databaseService.fetchMoments(inThread: thread.id)
                threadMoments[thread.id] = moments
            }
        } catch {
            print("Load threads error: \(error)")
        }
        isLoading = false
    }
}
