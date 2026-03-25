import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    @AppStorage("cloudKitSync") private var cloudKitSync = false

    // R2: Location settings
    @State private var locationPermissionGranted = false

    var body: some View {
        NavigationStack {
            ZStack {
                MarginColors.background
                    .ignoresSafeArea()

                List {
                    // R2: Location section
                    Section {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Location Context")
                                    .font(MarginFonts.body)
                                Text("Tag moments with where you are")
                                    .font(MarginFonts.caption)
                                    .foregroundColor(MarginColors.secondaryText)
                            }

                            Spacer()

                            if appState.contextService.locationPermissionGranted {
                                Text("Enabled")
                                    .font(MarginFonts.caption)
                                    .foregroundColor(MarginColors.accentSecondary)
                            } else {
                                Button("Enable") {
                                    Task {
                                        _ = await appState.contextService.requestLocationPermission()
                                        locationPermissionGranted = appState.contextService.locationPermissionGranted
                                    }
                                }
                                .font(MarginFonts.caption)
                                .foregroundColor(MarginColors.accent)
                            }
                        }

                        if appState.contextService.locationPermissionGranted {
                            HStack {
                                Image(systemName: "location.fill")
                                    .font(.system(size: 12))
                                    .foregroundColor(MarginColors.accentSecondary)
                                Text("Location data never leaves your device")
                                    .font(MarginFonts.caption)
                                    .foregroundColor(MarginColors.secondaryText)
                            }
                        }
                    } header: {
                        Text("Context")
                    }

                    Section {
                        Toggle("iCloud Sync", isOn: $cloudKitSync)
                            .tint(MarginColors.accent)
                    } header: {
                        Text("Sync")
                    } footer: {
                        Text("When enabled, your moments sync across devices via iCloud. Your data stays private.")
                            .font(MarginFonts.caption)
                    }

                    // R2: Thread management
                    Section {
                        NavigationLink {
                            ThreadManagementView()
                        } label: {
                            HStack {
                                Image(systemName: "link")
                                    .foregroundColor(MarginColors.accentSecondary)
                                Text("Manage Threads")
                            }
                        }
                    } header: {
                        Text("Threads")
                    } footer: {
                        Text("View and manage your thought threads.")
                    }

                    // R2: Anonymous social
                    Section {
                        NavigationLink {
                            CommonThoughtsView()
                        } label: {
                            HStack {
                                Image(systemName: "person.3")
                                    .foregroundColor(MarginColors.accentSecondary)
                                Text("Common Thoughts")
                            }
                        }
                    } header: {
                        Text("Community")
                    } footer: {
                        Text("See what others in similar situations are thinking about.")
                    }

                    Section {
                        HStack {
                            Text("Version")
                            Spacer()
                            Text("1.0.0")
                                .foregroundColor(MarginColors.secondaryText)
                        }

                        HStack {
                            Text("Build")
                            Spacer()
                            Text("R2")
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
            .onAppear {
                locationPermissionGranted = appState.contextService.locationPermissionGranted
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

// R2: Thread management view
struct ThreadManagementView: View {
    @EnvironmentObject var appState: AppState
    @State private var threads: [MomentThread] = []
    @State private var isLoading = true

    var body: some View {
        ZStack {
            MarginColors.background
                .ignoresSafeArea()

            if isLoading {
                ProgressView()
                    .tint(MarginColors.accent)
            } else if threads.isEmpty {
                VStack(spacing: MarginSpacing.lg) {
                    Image(systemName: "link")
                        .font(.system(size: 48))
                        .foregroundColor(MarginColors.divider)
                    Text("No threads")
                        .font(MarginFonts.subheading)
                        .foregroundColor(MarginColors.primaryText)
                }
            } else {
                List {
                    ForEach(threads) { thread in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(thread.title ?? "Untitled thread")
                                    .font(MarginFonts.body)
                                    .foregroundColor(MarginColors.primaryText)
                                Text("\(thread.momentIds.count) moments")
                                    .font(MarginFonts.caption)
                                    .foregroundColor(MarginColors.secondaryText)
                            }

                            Spacer()

                            if thread.isActive {
                                Text("Active")
                                    .font(MarginFonts.caption)
                                    .foregroundColor(MarginColors.accentSecondary)
                            } else {
                                Text("Resolved")
                                    .font(MarginFonts.caption)
                                    .foregroundColor(MarginColors.secondaryText)
                            }
                        }
                    }
                    .onDelete(perform: deleteThreads)
                }
                .scrollContentBackground(.hidden)
            }
        }
        .navigationTitle("Threads")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadThreads()
        }
    }

    private func loadThreads() async {
        isLoading = true
        do {
            threads = try await appState.databaseService.fetchAllThreads()
        } catch {
            print("Load threads error: \(error)")
        }
        isLoading = false
    }

    private func deleteThreads(at offsets: IndexSet) {
        for index in offsets {
            let thread = threads[index]
            try? appState.databaseService.deleteThread(id: thread.id)
        }
        threads.remove(atOffsets: offsets)
    }
}

#Preview {
    SettingsView()
        .environmentObject(AppState())
}
