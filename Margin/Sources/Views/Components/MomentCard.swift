import SwiftUI

struct MomentCard: View {
    let moment: Moment
    var onDelete: (() -> Void)?

    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: MarginSpacing.sm) {
            HStack {
                Text(moment.formattedTime)
                    .font(MarginFonts.caption)
                    .foregroundColor(MarginColors.secondaryText)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(MarginColors.divider.opacity(0.5))
                    .cornerRadius(4)

                Spacer()

                if let context = moment.contextType {
                    Text(context)
                        .font(MarginFonts.caption)
                        .foregroundColor(MarginColors.accentSecondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(MarginColors.accentSecondary.opacity(0.15))
                        .cornerRadius(4)
                }
            }

            Text(moment.text)
                .font(MarginFonts.body)
                .foregroundColor(MarginColors.primaryText)
                .lineLimit(isExpanded ? nil : 2)
                .fixedSize(horizontal: false, vertical: true)

            if let prompt = moment.reflectionPrompt, !prompt.isEmpty {
                Divider()
                    .background(MarginColors.divider)

                Text(prompt)
                    .font(MarginFonts.handwritten)
                    .foregroundColor(MarginColors.secondaryText)
                    .italic()
            }
        }
        .padding(MarginSpacing.md)
        .background(MarginColors.surface)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
        .rotationEffect(.degrees(Double.random(in: -0.5...0.5)))
    }
}

#Preview {
    MomentCard(moment: Moment(
        text: "Thinking about the presentation tomorrow. Should I lead with the quarterly numbers or the narrative?",
        timestamp: Date(),
        timeOfDay: "afternoon",
        dayOfWeek: "Tuesday",
        contextType: "☕ coffee break",
        reflectionPrompt: "What were you just thinking about?"
    ))
    .padding()
    .background(MarginColors.background)
}
