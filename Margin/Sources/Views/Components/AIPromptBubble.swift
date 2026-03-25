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

            HStack {
                TextField("Your reflection...", text: $answer, axis: .vertical)
                    .font(MarginFonts.body)
                    .foregroundColor(MarginColors.primaryText)
                    .lineLimit(1...4)
                    .focused($isFocused)
                    .padding(MarginSpacing.sm)
                    .background(MarginColors.background)
                    .cornerRadius(8)

                Button(action: onSubmit) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(MarginColors.accent)
                }
                .disabled(answer.isEmpty)
            }
        }
        .padding(MarginSpacing.md)
        .background(MarginColors.surface)
        .cornerRadius(12)
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
