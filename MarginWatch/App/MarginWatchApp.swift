import SwiftUI
import WatchKit

@main
struct MarginWatchApp: App {
    var body: some Scene {
        WindowGroup {
            WatchHomeView()
        }
    }
}

struct WatchHomeView: View {
    @State private var todayMoments: [WatchMoment] = []
    @State private var isLoading = true

    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView()
                } else if todayMoments.isEmpty {
                    emptyStateView
                } else {
                    momentListView
                }
            }
            .navigationTitle("Margin")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: CaptureWatchView(onSave: {
                        loadTodayMoments()
                    })) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(accentColor)
                    }
                }
            }
            .onAppear {
                loadTodayMoments()
            }
        }
    }

    private var accentColor: Color {
        Color(red: 0.769, green: 0.659, blue: 0.510)
    }

    private func loadTodayMoments() {
        isLoading = true
        let defaults = UserDefaults.standard
        if let data = defaults.data(forKey: "watchTodayMoments"),
           let moments = try? JSONDecoder().decode([WatchMoment].self, from: data) {
            todayMoments = moments
        }
        isLoading = false
    }

    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "text.quote")
                .font(.largeTitle)
                .foregroundColor(accentColor.opacity(0.5))

            Text("No moments today")
                .font(.headline)

            NavigationLink(destination: CaptureWatchView(onSave: {
                loadTodayMoments()
            })) {
                Label("Capture Moment", systemImage: "plus")
                    .font(.caption)
            }
            .buttonStyle(.borderedProminent)
            .tint(accentColor)
        }
        .padding()
    }

    private var momentListView: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                ForEach(todayMoments) { moment in
                    momentRow(moment)
                }
            }
            .padding()
        }
    }

    private func momentRow(_ moment: WatchMoment) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(moment.text)
                .font(.caption)
                .lineLimit(3)

            HStack {
                if let mood = moment.moodTag {
                    Text(mood.emoji)
                }
                Spacer()
                Text(moment.timestamp.formatted(date: .omitted, time: .shortened))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(8)
        .background(accentColor.opacity(0.1))
        .cornerRadius(8)
    }
}

// MARK: - Capture Watch View

struct CaptureWatchView: View {
    let onSave: () -> Void
    @Environment(\.dismiss) private var dismiss

    @State private var text = ""
    @State private var selectedMood: MoodTag?
    @State private var isSaving = false

    private let accentColor = Color(red: 0.769, green: 0.659, blue: 0.510)

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                Text("What's on your mind?")
                    .font(.headline)
                    .foregroundColor(accentColor)

                // Text input
                TextField("A thought, feeling, or idea...", text: $text, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(3...6)
                    .font(.caption)

                // Mood picker
                VStack(alignment: .leading, spacing: 6) {
                    Text("Mood (optional)")
                        .font(.caption2)
                        .foregroundColor(.secondary)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 6) {
                            ForEach(MoodTag.allCases, id: \.self) { mood in
                                Button {
                                    if selectedMood == mood {
                                        selectedMood = nil
                                    } else {
                                        selectedMood = mood
                                    }
                                } label: {
                                    Text(mood.emoji)
                                        .font(.title3)
                                        .padding(6)
                                        .background(selectedMood == mood ? accentColor.opacity(0.3) : Color.clear)
                                        .cornerRadius(8)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }

                Button {
                    saveMoment()
                } label: {
                    if isSaving {
                        ProgressView()
                    } else {
                        Text("Save Moment")
                            .font(.headline)
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(accentColor)
                .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isSaving)
            }
            .padding()
        }
        .navigationTitle("Capture")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func saveMoment() {
        isSaving = true

        let moment = WatchMoment(
            text: text,
            moodTag: selectedMood,
            timestamp: Date()
        )

        // Save to shared UserDefaults
        let defaults = UserDefaults.standard
        var moments: [WatchMoment] = []
        if let data = defaults.data(forKey: "watchTodayMoments"),
           let existing = try? JSONDecoder().decode([WatchMoment].self, from: data) {
            moments = existing
        }
        moments.insert(moment, at: 0)
        if let data = try? JSONEncoder().encode(moments) {
            defaults.set(data, forKey: "watchTodayMoments")
        }

        // Also save to shared app group
        if let sharedDefaults = UserDefaults(suiteName: "group.com.margin.thoughts") {
            if let data = try? JSONEncoder().encode(moment) {
                sharedDefaults.set(data, forKey: "watchLatestMoment")
            }
        }

        WKInterfaceDevice.current().play(.success)
        isSaving = false
        onSave()
        dismiss()
    }
}

// MARK: - Shared Models

struct WatchMoment: Codable, Identifiable {
    let id: UUID
    let text: String
    let moodTag: MoodTag?
    let timestamp: Date

    init(id: UUID = UUID(), text: String, moodTag: MoodTag?, timestamp: Date) {
        self.id = id
        self.text = text
        self.moodTag = moodTag
        self.timestamp = timestamp
    }
}

enum MoodTag: String, CaseIterable, Codable, Identifiable {
    case anxious = "anxious"
    case curious = "curious"
    case creative = "creative"
    case melancholy = "melancholy"
    case excited = "excited"
    case calm = "calm"
    case worried = "worried"
    case hopeful = "hopeful"
    case nostalgic = "nostalgic"
    case focused = "focused"

    var id: String { rawValue }

    var emoji: String {
        switch self {
        case .anxious: return "😰"
        case .curious: return "🤔"
        case .creative: return "💡"
        case .melancholy: return "😢"
        case .excited: return "✨"
        case .calm: return "😌"
        case .worried: return "😟"
        case .hopeful: return "🌱"
        case .nostalgic: return "📼"
        case .focused: return "🎯"
        }
    }
}
