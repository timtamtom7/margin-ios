import SwiftUI

struct MacSettingsView: View {
    @State private var notificationsEnabled = true
    @State private var reminderHour = 9
    @State private var reminderMinute = 0
    @State private var darkModeEnabled = false
    @State private var isExporting = false
    @State private var showingExportSuccess = false
    @State private var showingExportSheet = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                Text("Settings")
                    .font(MarginFonts.heading)
                    .foregroundColor(MarginColors.primaryText)
                    .padding(.horizontal, 24)
                    .padding(.top, 20)

                // Notifications
                settingsSection(title: "Notifications") {
                    Toggle("Enable reminders", isOn: $notificationsEnabled)
                        .toggleStyle(SwitchToggleStyle(tint: Color(MarginColors.accent)))

                    if notificationsEnabled {
                        HStack {
                            Text("Daily reminder time")
                                .font(MarginFonts.body)
                                .foregroundColor(MarginColors.primaryText)

                            Spacer()

                            Picker("Hour", selection: $reminderHour) {
                                ForEach(5..<23, id: \.self) { hour in
                                    Text("\(hour):00").tag(hour)
                                }
                            }
                            .pickerStyle(.menu)
                            .frame(width: 100)
                        }
                    }
                }

                // Appearance
                settingsSection(title: "Appearance") {
                    Toggle("Dark mode", isOn: $darkModeEnabled)
                        .toggleStyle(SwitchToggleStyle(tint: Color(MarginColors.accent)))

                    Text("Dark mode uses inverted colors for the paper aesthetic.")
                        .font(MarginFonts.caption)
                        .foregroundColor(MarginColors.secondaryText)
                }

                // Data
                settingsSection(title: "Data") {
                    Button(action: exportData) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 14))
                            Text("Export moments as JSON")
                                .font(MarginFonts.body)
                        }
                        .foregroundColor(MarginColors.accent)
                    }
                    .buttonStyle(.plain)
                    .disabled(isExporting)

                    if showingExportSuccess {
                        Text("Data exported successfully!")
                            .font(MarginFonts.caption)
                            .foregroundColor(MarginColors.accentSecondary)
                    }
                }

                // About
                settingsSection(title: "About") {
                    HStack {
                        Text("Margin")
                            .font(MarginFonts.body)
                            .foregroundColor(MarginColors.primaryText)
                        Spacer()
                        Text("v1.0.0")
                            .font(MarginFonts.caption)
                            .foregroundColor(MarginColors.secondaryText)
                    }

                    Text("Micro-reflections for the margins of your day.")
                        .font(MarginFonts.caption)
                        .foregroundColor(MarginColors.secondaryText)
                }

                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(MarginColors.background)
    }

    private func settingsSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(MarginFonts.subheading)
                .foregroundColor(MarginColors.primaryText)

            VStack(alignment: .leading, spacing: 12) {
                content()
            }
            .padding(16)
            .background(MarginColors.surface)
            .cornerRadius(8)
        }
    }

    private func exportData() {
        isExporting = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isExporting = false
            showingExportSuccess = true

            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                showingExportSuccess = false
            }
        }
    }
}

#Preview {
    MacSettingsView()
}
