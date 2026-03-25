import SwiftUI

struct DailyDigestView: View {
    @EnvironmentObject var appState: AppState
    @State private var digest: DailyDigest?
    @State private var isLoading = true

    var body: some View {
        NavigationStack {
            ZStack {
                MarginColors.background
                    .ignoresSafeArea()

                if isLoading {
                    ProgressView()
                        .tint(MarginColors.accent)
                } else if let digest = digest {
                    ScrollView {
                        VStack(spacing: MarginSpacing.lg) {
                            DailyDigestCard(digest: digest)

                            Text("Your daily digest captures the texture of your dead time — the moments between moments.")
                                .font(MarginFonts.caption)
                                .foregroundColor(MarginColors.secondaryText)
                                .italic()
                                .multilineTextAlignment(.center)
                        }
                        .padding(MarginSpacing.lg)
                    }
                } else {
                    Text("No digest available for today.")
                        .font(MarginFonts.body)
                        .foregroundColor(MarginColors.secondaryText)
                }
            }
            .navigationTitle("Daily Digest")
            .navigationBarTitleDisplayMode(.inline)
        }
        .task {
            await loadDigest()
        }
    }

    private func loadDigest() async {
        isLoading = true
        do {
            digest = try await appState.databaseService.fetchDigest(for: Date())
        } catch {
            print("Load digest error: \(error)")
        }
        isLoading = false
    }
}

#Preview {
    DailyDigestView()
        .environmentObject(AppState())
}
