import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    @AppStorage("cloudKitSync") private var cloudKitSync = false

    var body: some View {
        NavigationStack {
            ZStack {
                MarginColors.background
                    .ignoresSafeArea()

                List {
                    Section {
                        Toggle("iCloud Sync", isOn: $cloudKitSync)
                            .tint(MarginColors.accent)
                    } header: {
                        Text("Sync")
                    } footer: {
                        Text("When enabled, your moments sync across devices via iCloud. Your data stays private.")
                            .font(MarginFonts.caption)
                    }

                    Section {
                        HStack {
                            Text("Version")
                            Spacer()
                            Text("1.0.0")
                                .foregroundColor(MarginColors.secondaryText)
                        }
                    } header: {
                        Text("About")
                    }

                    Section {
                        Button(role: .destructive) {
                            exportData()
                        } label: {
                            Text("Export Data")
                        }
                    } header: {
                        Text("Data")
                    } footer: {
                        Text("Export all your moments as a JSON file.")
                    }
                }
                .scrollContentBackground(.hidden)
                .listStyle(.insetGrouped)
            }
            .navigationTitle("Settings")
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

    private func exportData() {
        Task {
            do {
                let moments = try await appState.databaseService.fetchAllMoments()
                let encoder = JSONEncoder()
                encoder.outputFormatting = .prettyPrinted
                encoder.dateEncodingStrategy = .iso8601
                let data = try encoder.encode(moments)

                let url = FileManager.default.temporaryDirectory.appendingPathComponent("margin_export.json")
                try data.write(to: url)

                await MainActor.run {
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let window = windowScene.windows.first,
                       let rootVC = window.rootViewController {
                        let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
                        rootVC.present(activityVC, animated: true)
                    }
                }
            } catch {
                print("Export error: \(error)")
            }
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(AppState())
}
