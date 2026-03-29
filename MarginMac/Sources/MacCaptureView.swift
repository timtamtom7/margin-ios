import SwiftUI
import Combine

struct MacCaptureView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var text = ""
    @State private var autoSaveTimer: AnyCancellable?
    @State private var isSaving = false
    @FocusState private var isFocused: Bool

    let onSave: (Moment) -> Void
    let aiService = AIService()

    private let prompts = [
        "Right now I'm thinking about...",
        "I'm noticing...",
        "I'm feeling..."
    ]

    private var timeOfDay: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "morning"
        case 12..<17: return "afternoon"
        case 17..<21: return "evening"
        default: return "night"
        }
    }

    private var dayOfWeek: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: Date())
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                .font(MarginFonts.body)
                .foregroundColor(MarginColors.secondaryText)

                Spacer()

                Text("New Moment")
                    .font(MarginFonts.subheading)
                    .foregroundColor(MarginColors.primaryText)

                Spacer()

                Button("Save") {
                    saveMoment()
                }
                .font(MarginFonts.body)
                .foregroundColor(text.isEmpty ? MarginColors.divider : MarginColors.accent)
                .disabled(text.isEmpty)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
            .background(MarginColors.surface)

            Divider()
                .background(MarginColors.divider)

            // Prompt suggestions
            VStack(alignment: .leading, spacing: 12) {
                Text("What's on your mind?")
                    .font(MarginFonts.subheading)
                    .foregroundColor(MarginColors.primaryText)

                HStack(spacing: 8) {
                    ForEach(prompts, id: \.self) { prompt in
                        Button(action: {
                            text = prompt + " "
                            isFocused = true
                        }) {
                            Text(prompt)
                                .font(MarginFonts.caption)
                                .foregroundColor(MarginColors.secondaryText)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(MarginColors.background)
                                .cornerRadius(4)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
            .padding(.bottom, 12)

            // Text area
            ZStack(alignment: .topLeading) {
                if text.isEmpty {
                    Text("Start typing your thought...")
                        .font(MarginFonts.body)
                        .foregroundColor(MarginColors.divider)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 8)
                }

                TextEditor(text: $text)
                    .font(MarginFonts.body)
                    .foregroundColor(MarginColors.primaryText)
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                    .focused($isFocused)
                    .onChange(of: text) { _, _ in
                        resetAutoSaveTimer()
                    }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(MarginColors.surface)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(MarginColors.divider, lineWidth: 1)
            )
            .padding(.horizontal, 24)

            Spacer()

            // Footer
            HStack {
                Text(timeOfDay.capitalized + " · " + dayOfWeek)
                    .font(MarginFonts.caption)
                    .foregroundColor(MarginColors.secondaryText)

                Spacer()

                if isSaving {
                    Text("Saving...")
                        .font(MarginFonts.caption)
                        .foregroundColor(MarginColors.secondaryText)
                } else if !text.isEmpty {
                    Text("Auto-saves in 3s")
                        .font(MarginFonts.caption)
                        .foregroundColor(MarginColors.divider)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(MarginColors.background)
        .onAppear {
            isFocused = true
        }
    }

    private func resetAutoSaveTimer() {
        autoSaveTimer?.cancel()
        autoSaveTimer = Timer.publish(every: 3, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                if !text.isEmpty {
                    saveMoment()
                }
            }
    }

    private func saveMoment() {
        guard !text.isEmpty else { return }
        isSaving = true

        let mood = aiService.detectMood(from: text)
        let isDeep = aiService.isDeepThought(text: text)
        let prompt = aiService.generateReflectionPrompt()

        let moment = Moment(
            text: text,
            timestamp: Date(),
            timeOfDay: timeOfDay,
            dayOfWeek: dayOfWeek,
            reflectionPrompt: prompt,
            isDeepThought: isDeep,
            moodTag: mood
        )

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            onSave(moment)
            dismiss()
        }
    }
}

#Preview {
    MacCaptureView { _ in }
}
