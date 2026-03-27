import SwiftUI

struct AIPromptBubble: View {
    let prompt: String
    @Binding var answer: String
    let onSubmit: () -> Void

    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: MarginSpacing.sm) {
            Text(prompt)
                .font(MarginFonts.handwritten)
                .foregroundColor(MarginColors.secondaryText)
                .italic()
                .padding(.top, MarginSpacing.sm)
                .accessibilityLabel("AI prompt: \(prompt)")

            HStack {
                TextField("Your reflection...", text: $answer, axis: .vertical)
                    .font(MarginFonts.body)
                    .foregroundColor(MarginColors.primaryText)
                    .lineLimit(1...4)
                    .focused($isFocused)
                    .padding(MarginSpacing.sm)
                    .background(MarginColors.background)
                    .cornerRadius(Theme.CornerRadius.sm)
                    .accessibilityLabel("Reflection answer")
                    .accessibilityHint("Enter your reflection response")

                Button(action: {
                    Theme.Haptic.light()
                    onSubmit()
                }) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(answer.isEmpty ? MarginColors.divider : MarginColors.accent)
                }
                .disabled(answer.isEmpty)
                .accessibilityLabel("Submit reflection")
                .accessibilityHint("Submits your reflection response")
            }
        }
        .padding(MarginSpacing.md)
        .background(MarginColors.surface)
        .cornerRadius(Theme.CornerRadius.md)
        .shadow(color: Color.black.opacity(0.03), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    AIPromptBubble(
        prompt: "What were you just thinking about?",
        answer: .constant(""),
        onSubmit: {}
    )
    .padding()
    .background(MarginColors.background)
}
