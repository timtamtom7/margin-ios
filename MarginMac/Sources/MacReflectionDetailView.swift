import SwiftUI

struct MacReflectionDetailView: View {
    let moment: Moment
    let onEdit: (Moment) -> Void

    @State private var isEditing = false
    @State private var editedText: String = ""
    @State private var showingInsight = false

    private let aiService = AIService()

    private var aiInsight: String? {
        guard moment.isDeepThought else { return nil }
        return aiService.generateReflectionPrompt()
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(moment.formattedDate)
                            .font(MarginFonts.caption)
                            .foregroundColor(MarginColors.secondaryText)

                        HStack(spacing: 8) {
                            Text(moment.formattedTime)
                                .font(MarginFonts.caption)
                                .foregroundColor(MarginColors.accent)

                            if let tag = moment.moodTag {
                                Text(tag.emoji)
                                    .font(.system(size: 12))
                            }

                            if moment.isDeepThought {
                                Text("deep thought")
                                    .font(MarginFonts.caption)
                                    .foregroundColor(MarginColors.accentSecondary)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(MarginColors.accentSecondary.opacity(0.15))
                                    .cornerRadius(4)
                            }
                        }
                    }

                    Spacer()

                    Button(action: { isEditing.toggle() }) {
                        Image(systemName: isEditing ? "checkmark.circle.fill" : "pencil")
                            .font(.system(size: 16))
                            .foregroundColor(isEditing ? MarginColors.accent : MarginColors.secondaryText)
                    }
                    .buttonStyle(.plain)
                }

                Divider()
                    .background(MarginColors.divider)

                // Main text
                if isEditing {
                    VStack(alignment: .leading, spacing: 8) {
                        TextEditor(text: $editedText)
                            .font(.custom("Georgia", size: 18))
                            .foregroundColor(MarginColors.primaryText)
                            .scrollContentBackground(.hidden)
                            .background(Color.clear)
                            .frame(minHeight: 150)

                        HStack {
                            Spacer()
                            Button("Done") {
                                var updated = moment
                                updated.text = editedText
                                onEdit(updated)
                                isEditing = false
                            }
                            .font(MarginFonts.body)
                            .foregroundColor(MarginColors.surface)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(MarginColors.accent)
                            .cornerRadius(6)
                        }
                    }
                } else {
                    Text(moment.text)
                        .font(.custom("Georgia", size: 18))
                        .foregroundColor(MarginColors.primaryText)
                        .lineSpacing(6)
                        .fixedSize(horizontal: false, vertical: true)
                }

                // AI Insight card
                if showingInsight, let insight = aiInsight {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 6) {
                            Image(systemName: "brain")
                                .font(.system(size: 12))
                            Text("AI Pattern")
                                .font(MarginFonts.caption)
                        }
                        .foregroundColor(MarginColors.accentSecondary)

                        Text(insight)
                            .font(MarginFonts.handwritten)
                            .foregroundColor(MarginColors.primaryText)
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(MarginColors.accentSecondary.opacity(0.1))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(MarginColors.accentSecondary.opacity(0.3), lineWidth: 1)
                    )
                }

                // Reflection prompt
                if let prompt = moment.reflectionPrompt {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 6) {
                            Image(systemName: "text.bubble")
                                .font(.system(size: 12))
                            Text("Reflection")
                                .font(MarginFonts.caption)
                        }
                        .foregroundColor(MarginColors.secondaryText)

                        Text(prompt)
                            .font(MarginFonts.handwritten)
                            .foregroundColor(MarginColors.secondaryText)
                            .italic()

                        if let answer = moment.reflectionAnswer {
                            Text(answer)
                                .font(MarginFonts.body)
                                .foregroundColor(MarginColors.primaryText)
                        }
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(MarginColors.surface)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(MarginColors.divider, lineWidth: 1)
                    )
                }

                // Context
                HStack(spacing: 12) {
                    if let context = moment.contextType {
                        ContextPill(label: context, color: MarginColors.accent)
                    }
                    if let location = moment.locationLabel {
                        ContextPill(label: location, color: MarginColors.accentSecondary)
                    }
                }

                Spacer()
            }
            .padding(24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(MarginColors.background)
        .onAppear {
            editedText = moment.text
            // Show insight after a short delay
            if moment.isDeepThought {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    showingInsight = true
                }
            }
        }
    }
}

// MARK: - Context Pill

struct ContextPill: View {
    let label: String
    let color: Color

    var body: some View {
        HStack(spacing: 4) {
            Text(label)
                .font(MarginFonts.caption)
        }
        .foregroundColor(color)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(color.opacity(0.12))
        .cornerRadius(12)
    }
}

#Preview {
    MacReflectionDetailView(
        moment: Moment(
            text: "Right now I'm thinking about how strange it is that we only notice the passage of time when something breaks the routine.",
            timestamp: Date(),
            timeOfDay: "afternoon",
            dayOfWeek: "Friday",
            reflectionPrompt: "What were you just thinking about?",
            isDeepThought: true,
            moodTag: .curious
        ),
        onEdit: { _ in }
    )
}
