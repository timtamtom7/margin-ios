import SwiftUI

struct MacContentView: View {
    @EnvironmentObject var appState: MacAppState
    @State private var selectedTab: MacTab = .home
    @State private var selectedMoment: Moment?
    @State private var showingCapture = false

    enum MacTab: String, CaseIterable {
        case home = "Home"
        case timeline = "Timeline"
        case insights = "Insights"
        case settings = "Settings"

        var icon: String {
            switch self {
            case .home: return "house"
            case .timeline: return "calendar"
            case .insights: return "lightbulb"
            case .settings: return "gearshape"
            }
        }
    }

    var body: some View {
        NavigationSplitView {
            sidebarContent
        } detail: {
            detailContent
        }
        .frame(minWidth: 800, idealWidth: 900, minHeight: 500, idealHeight: 600)
        .background(MarginColors.background)
        .sheet(isPresented: $showingCapture) {
            MacCaptureView { moment in
                appState.moments.insert(moment, at: 0)
                selectedMoment = moment
            }
        }
    }

    // MARK: - Sidebar

    private var sidebarContent: some View {
        VStack(spacing: 0) {
            // Logo / Title
            HStack {
                Text("Margin")
                    .font(MarginFonts.heading)
                    .foregroundColor(MarginColors.primaryText)
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 16)

            // Tab selector
            VStack(spacing: 4) {
                ForEach(MacTab.allCases, id: \.self) { tab in
                    TabRowButton(
                        title: tab.rawValue,
                        icon: tab.icon,
                        isSelected: selectedTab == tab
                    ) {
                        selectedTab = tab
                        if tab != .home {
                            selectedMoment = nil
                        }
                    }
                }
            }
            .padding(.horizontal, 12)

            Divider()
                .padding(.vertical, 12)
                .background(MarginColors.divider)

            // Recent moments list
            VStack(alignment: .leading, spacing: 0) {
                Text("Recent")
                    .font(MarginFonts.caption)
                    .foregroundColor(MarginColors.secondaryText)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 8)

                if appState.moments.isEmpty {
                    VStack(spacing: 8) {
                        Image(systemName: "note.text")
                            .font(.system(size: 24))
                            .foregroundColor(MarginColors.divider)
                        Text("No moments yet")
                            .font(MarginFonts.caption)
                            .foregroundColor(MarginColors.secondaryText)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 40)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 2) {
                            ForEach(appState.moments.prefix(10)) { moment in
                                MomentRowItem(moment: moment, isSelected: selectedMoment?.id == moment.id) {
                                    selectedMoment = moment
                                }
                            }
                        }
                        .padding(.horizontal, 12)
                    }
                }
            }

            Spacer()

            // Quick capture button
            Button(action: { showingCapture = true }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 16))
                    Text("Capture a thought")
                        .font(MarginFonts.body)
                }
                .foregroundColor(MarginColors.surface)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(MarginColors.accent)
                .cornerRadius(8)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .frame(minWidth: 220, idealWidth: 240)
        .background(MarginColors.surface)
    }

    // MARK: - Detail Content

    @ViewBuilder
    private var detailContent: some View {
        switch selectedTab {
        case .home:
            if let moment = selectedMoment {
                MacReflectionDetailView(moment: moment, onEdit: { edited in
                    if let idx = appState.moments.firstIndex(where: { $0.id == edited.id }) {
                        appState.moments[idx] = edited
                    }
                    selectedMoment = edited
                })
            } else {
                MacWelcomeView(onCapture: { showingCapture = true })
            }

        case .timeline:
            MacTimelineView(moments: appState.moments) { moment in
                selectedMoment = moment
                selectedTab = .home
            }

        case .insights:
            MacInsightsView(moments: appState.moments)

        case .settings:
            MacSettingsView()
        }
    }
}

// MARK: - Tab Row Button

struct TabRowButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .frame(width: 18)
                Text(title)
                    .font(MarginFonts.body)
                Spacer()
            }
            .foregroundColor(isSelected ? MarginColors.primaryText : MarginColors.secondaryText)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? MarginColors.background : Color.clear)
            .cornerRadius(6)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Moment Row Item

struct MomentRowItem: View {
    let moment: Moment
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(moment.formattedTime)
                        .font(MarginFonts.caption)
                        .foregroundColor(MarginColors.accent)
                    Spacer()
                    if let tag = moment.moodTag {
                        Text(tag.emoji)
                            .font(.system(size: 10))
                    }
                }
                Text(moment.text)
                    .font(MarginFonts.body)
                    .foregroundColor(MarginColors.primaryText)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? MarginColors.background : Color.clear)
            .cornerRadius(6)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Welcome View

struct MacWelcomeView: View {
    let onCapture: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "note.text")
                .font(.system(size: 48))
                .foregroundColor(MarginColors.divider)

            VStack(spacing: 8) {
                Text("Your micro-reflections")
                    .font(MarginFonts.heading)
                    .foregroundColor(MarginColors.primaryText)

                Text("Capture thoughts in the margins of your day.\nWaiting in line. Coffee brewing. Red light.")
                    .font(MarginFonts.body)
                    .foregroundColor(MarginColors.secondaryText)
                    .multilineTextAlignment(.center)
            }

            Button(action: onCapture) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Capture your first thought")
                }
                .font(MarginFonts.body)
                .foregroundColor(MarginColors.surface)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(MarginColors.accent)
                .cornerRadius(8)
            }
            .buttonStyle(.plain)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(MarginColors.background)
    }
}

#Preview {
    MacContentView()
        .environmentObject(MacAppState())
}
