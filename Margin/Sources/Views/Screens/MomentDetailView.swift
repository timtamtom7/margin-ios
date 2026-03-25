import SwiftUI

struct MomentDetailView: View {
    @EnvironmentObject var appState: AppState
    let moment: Moment
    @State private var reflectionAnswer: String
    @State private var isEditing = false

    init(moment: Moment) {
        self.moment = moment
        _reflectionAnswer = State(initialValue: moment.reflectionAnswer ?? "")
    }

    var body: some View {
        ZStack {
            MarginColors.background
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: MarginSpacing.lg) {
                    // Header
                    VStack(alignment: .leading, spacing: MarginSpacing.xs) {
                        Text(moment.formattedDate)
                            .font(MarginFonts.caption)
                            .foregroundColor(MarginColors.secondaryText)

                        Text(moment.formattedTime)
                            .font(MarginFonts.subheading)
                            .foregroundColor(MarginColors.primaryText)
                    }

                    // Context pills
                    HStack(spacing: MarginSpacing.sm) {
                        ContextPill(label: moment.timeOfDay.capitalized)
                        if let ctx = moment.contextType {
                            ContextPill(label: ctx)
                        }
                        ContextPill(label: moment.dayOfWeek)
                    }

                    // Main thought
                    Text(moment.text)
                        .font(MarginFonts.body)
                        .foregroundColor(MarginColors.primaryText)
                        .padding(MarginSpacing.md)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(MarginColors.surface)
                        .cornerRadius(12)

                    // Reflection section
                    if let prompt = moment.reflectionPrompt {
                        VStack(alignment: .leading, spacing: MarginSpacing.sm) {
                            Text("Reflection")
                                .font(MarginFonts.caption)
                                .foregroundColor(MarginColors.secondaryText)

                            Text(prompt)
                                .font(MarginFonts.handwritten)
                                .foregroundColor(MarginColors.secondaryText)
                                .italic()

                            if !reflectionAnswer.isEmpty {
                                Text(reflectionAnswer)
                                    .font(MarginFonts.body)
                                    .foregroundColor(MarginColors.primaryText)
                                    .padding(MarginSpacing.md)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(MarginColors.surface)
                                    .cornerRadius(12)
                            } else if isEditing {
                                TextEditor(text: $reflectionAnswer)
                                    .font(MarginFonts.body)
                                    .foregroundColor(MarginColors.primaryText)
                                    .scrollContentBackground(.hidden)
                                    .background(MarginColors.surface)
                                    .frame(minHeight: 80)
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(MarginColors.divider, lineWidth: 1)
                                    )

                                Button("Save") {
                                    saveReflection()
                                }
                                .font(MarginFonts.body)
                                .foregroundColor(MarginColors.accent)
                            } else {
                                Button("Add reflection") {
                                    isEditing = true
                                }
                                .font(MarginFonts.body)
                                .foregroundColor(MarginColors.secondaryText)
                            }
                        }
                    }

                    Spacer()
                }
                .padding(MarginSpacing.lg)
            }
        }
        .navigationTitle("Moment")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func saveReflection() {
        Task {
            try? await appState.databaseService.updateMomentReflection(
                momentId: moment.id,
                prompt: moment.reflectionPrompt,
                answer: reflectionAnswer.isEmpty ? nil : reflectionAnswer
            )
            isEditing = false
        }
    }
}

#Preview {
    NavigationStack {
        MomentDetailView(moment: Moment(
            text: "Thinking about the presentation tomorrow. Should I lead with the quarterly numbers or the narrative?",
            timestamp: Date(),
            timeOfDay: "afternoon",
            dayOfWeek: "Tuesday",
            contextType: "☕ coffee break",
            reflectionPrompt: "What were you just thinking about?"
        ))
    }
    .environmentObject(AppState())
}
