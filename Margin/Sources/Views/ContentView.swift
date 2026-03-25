import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
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
}

#Preview {
    ContentView()
        .environmentObject(AppState())
}
