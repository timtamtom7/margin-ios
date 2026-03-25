import SwiftUI

struct MomentCard: View {
    let moment: Moment
    var onDelete: (() -> Void)?
    var showThreadIndicator: Bool = false

    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: MarginSpacing.sm) {
            // Header row
            HStack {
                Text(moment.formattedTime)
                    .font(MarginFonts.caption)
                    .foregroundColor(MarginColors.secondaryText)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(MarginColors.divider.opacity(0.5))
                    .cornerRadius(4)

                Spacer()

                // R2: Deep thought indicator
                if moment.isDeepThought {
                    Image(systemName: "sparkles")
                        .font(.system(size: 10))
                        .foregroundColor(MarginColors.accent)
                        .padding(4)
                        .background(MarginColors.accent.opacity(0.15))
                        .cornerRadius(4)
                }

                // R2: Mood tag
                if let mood = moment.moodTag {
                    HStack(spacing: 2) {
                        Text(mood.emoji)
                            .font(.system(size: 10))
                        Text(mood.displayName)
                            .font(MarginFonts.caption)
                            .foregroundColor(MarginColors.secondaryText)
                    }
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(MarginColors.accentSecondary.opacity(0.1))
                    .cornerRadius(6)
                }

                if let context = moment.contextType {
                    Text(context)
                        .font(MarginFonts.caption)
                        .foregroundColor(MarginColors.accentSecondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(MarginColors.accentSecondary.opacity(0.15))
                        .cornerRadius(4)
                }

                // R2: Thread indicator
                if showThreadIndicator && moment.threadId != nil {
                    Image(systemName: "link")
                        .font(.system(size: 10))
                        .foregroundColor(MarginColors.secondaryText)
                        .padding(4)
                        .background(MarginColors.divider.opacity(0.5))
                        .cornerRadius(4)
                }

                // R2: Abandoned thread warning
                if moment.isAbandonedThread {
                    Image(systemName: "exclamationmark.circle")
                        .font(.system(size: 10))
                        .foregroundColor(MarginColors.destructive)
                        .padding(4)
                        .background(MarginColors.destructive.opacity(0.15))
                        .cornerRadius(4)
                }
            }

            // Main thought text
            Text(moment.text)
                .font(MarginFonts.body)
                .foregroundColor(MarginColors.primaryText)
                .lineLimit(isExpanded ? nil : 3)
                .fixedSize(horizontal: false, vertical: true)

            // R2: Location tag (privacy-first, shows type not coordinates)
            if let locationLabel = moment.locationLabel {
                HStack(spacing: 4) {
                    Image(systemName: "location.fill")
                        .font(.system(size: 9))
                    Text(locationLabel)
                        .font(MarginFonts.caption)
                }
                .foregroundColor(MarginColors.secondaryText.opacity(0.7))
            }

            // Reflection section
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
        // R2: Paper texture background + torn-edge effect
        .background(
            ZStack {
                MarginColors.surface
                // Subtle paper grain texture
                if let grainImage = UIImage(named: "paper_grain") {
                    Image(uiImage: grainImage)
                        .resizable(resizingMode: .tile)
                        .opacity(0.03)
                        .blendMode(.multiply)
                }
            }
        )
        .overlay(
            // R2: Torn edge effect at bottom
            tornEdgeOverlay
        )
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
        .rotationEffect(.degrees(Double.random(in: -0.5...0.5)))
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.2)) {
                isExpanded.toggle()
            }
        }
    }

    // R2: Torn edge effect - subtle irregular bottom edge
    @ViewBuilder
    private var tornEdgeOverlay: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let height: CGFloat = 4

            Path { path in
                path.move(to: CGPoint(x: 0, y: 0))
                // Create slight irregularity
                var x: CGFloat = 0
                let segments = 20
                let segmentWidth = width / CGFloat(segments)

                while x < width {
                    let wobble = CGFloat.random(in: -1...1)
                    path.addLine(to: CGPoint(x: x + segmentWidth, y: wobble))
                    x += segmentWidth
                }
                path.addLine(to: CGPoint(x: width, y: 0))
                path.addLine(to: CGPoint(x: width, y: height))
                path.addLine(to: CGPoint(x: 0, y: height))
                path.closeSubpath()
            }
            .fill(MarginColors.background.opacity(0.5))
            .offset(y: geo.size.height - height)
        }
        .allowsHitTesting(false)
        .opacity(0.3)
    }
}

// R2: Thread preview card
struct ThreadPreviewCard: View {
    let thread: MomentThread
    let moments: [Moment]

    var body: some View {
        VStack(alignment: .leading, spacing: MarginSpacing.sm) {
            HStack {
                Image(systemName: "link")
                    .font(.system(size: 12))
                    .foregroundColor(MarginColors.accent)

                Text("Thread — \(moments.count) moments")
                    .font(MarginFonts.caption)
                    .foregroundColor(MarginColors.secondaryText)

                Spacer()

                if thread.isActive {
                    Text("active")
                        .font(MarginFonts.caption)
                        .foregroundColor(MarginColors.accentSecondary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(MarginColors.accentSecondary.opacity(0.15))
                        .cornerRadius(4)
                } else {
                    Text("resolved")
                        .font(MarginFonts.caption)
                        .foregroundColor(MarginColors.secondaryText)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(MarginColors.divider.opacity(0.5))
                        .cornerRadius(4)
                }
            }

            Text(moments.first?.text ?? "")
                .font(MarginFonts.body)
                .foregroundColor(MarginColors.primaryText)
                .lineLimit(2)

            if let lastMoment = moments.last {
                HStack {
                    Text("Last thought:")
                        .font(MarginFonts.caption)
                        .foregroundColor(MarginColors.secondaryText)
                    Text(lastMoment.text)
                        .font(MarginFonts.caption)
                        .foregroundColor(MarginColors.primaryText)
                        .lineLimit(1)
                }
            }
        }
        .padding(MarginSpacing.md)
        .background(MarginColors.surface)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    VStack(spacing: 20) {
        MomentCard(moment: Moment(
            text: "Thinking about the presentation tomorrow. Should I lead with the quarterly numbers or the narrative?",
            timestamp: Date(),
            timeOfDay: "afternoon",
            dayOfWeek: "Tuesday",
            contextType: "☕ coffee break",
            locationType: "work",
            reflectionPrompt: "What were you just thinking about?",
            isDeepThought: true,
            moodTag: .curious
        ))

        MomentCard(moment: Moment(
            text: "Running through the grocery list in my head. Do we need eggs? I think we have eggs.",
            timestamp: Date(),
            timeOfDay: "morning",
            dayOfWeek: "Wednesday",
            contextType: "🚗 commute"
        ))

        MomentCard(moment: Moment(
            text: "This thought about the project has been following me for 3 days now. I should revisit it.",
            timestamp: Date(),
            timeOfDay: "evening",
            dayOfWeek: "Monday",
            threadId: UUID(),
            isAbandonedThread: true
        ))
    }
    .padding()
    .background(MarginColors.background)
}
