import SwiftUI

struct PatternCard: View {
    let pattern: Pattern
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: MarginSpacing.sm) {
            // Header with illustration
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(pattern.trigger)
                        .font(MarginFonts.subheading)
                        .foregroundColor(MarginColors.primaryText)

                    HStack(spacing: MarginSpacing.xs) {
                        Text(pattern.confidenceEmoji)
                            .font(.system(size: 11))
                        Text(pattern.confidenceLabel)
                            .font(MarginFonts.caption)
                            .foregroundColor(MarginColors.secondaryText)
                    }
                }

                Spacer()

                // R2: Simple line drawing illustration based on trigger
                patternIllustration
            }

            Text(pattern.patternDescription)
                .font(MarginFonts.body)
                .foregroundColor(MarginColors.secondaryText)

            // R2: Insights section
            if !pattern.insights.isEmpty && isExpanded {
                VStack(alignment: .leading, spacing: MarginSpacing.xs) {
                    ForEach(pattern.insights, id: \.self) { insight in
                        HStack(spacing: MarginSpacing.xs) {
                            Image(systemName: "lightbulb")
                                .font(.system(size: 9))
                                .foregroundColor(MarginColors.accent)
                            Text(insight)
                                .font(MarginFonts.caption)
                                .foregroundColor(MarginColors.secondaryText)
                        }
                    }
                }
                .padding(.top, MarginSpacing.xs)
            }

            // Suggested actions
            if !pattern.suggestedActions.isEmpty && isExpanded {
                VStack(alignment: .leading, spacing: MarginSpacing.xs) {
                    ForEach(pattern.suggestedActions, id: \.self) { action in
                        HStack(spacing: MarginSpacing.xs) {
                            Image(systemName: "arrow.right.circle")
                                .font(.system(size: 9))
                                .foregroundColor(MarginColors.accentSecondary)
                            Text(action)
                                .font(MarginFonts.caption)
                                .foregroundColor(MarginColors.accentSecondary)
                        }
                    }
                }
                .padding(.top, MarginSpacing.xs)
            }

            Divider()
                .background(MarginColors.divider)

            HStack {
                Image(systemName: "chart.bar.fill")
                    .font(.system(size: 11))
                    .foregroundColor(MarginColors.accent)

                Text("\(pattern.momentCount) moments observed")
                    .font(MarginFonts.caption)
                    .foregroundColor(MarginColors.secondaryText)

                Spacer()

                // R2: Expand/collapse for additional insights
                if !pattern.insights.isEmpty || !pattern.suggestedActions.isEmpty {
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isExpanded.toggle()
                        }
                    } label: {
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .font(.system(size: 11))
                            .foregroundColor(MarginColors.secondaryText)
                    }
                }
            }
        }
        .padding(MarginSpacing.md)
        .background(MarginColors.surface)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
        // R2: Slight rotation for hand-drawn feel
        .rotationEffect(.degrees(Double.random(in: -0.3...0.3)))
    }

    // R2: Simple line drawing illustrations based on trigger type
    @ViewBuilder
    private var patternIllustration: some View {
        let trigger = pattern.trigger.lowercased()
        ZStack {
            switch trigger {
            case let t where t.contains("traffic") || t.contains("commute"):
                trafficLineDrawing
            case let t where t.contains("coffee") || t.contains("break"):
                coffeeLineDrawing
            case let t where t.contains("elevator"):
                elevatorLineDrawing
            case let t where t.contains("morning"):
                morningLineDrawing
            case let t where t.contains("evening") || t.contains("night"):
                eveningLineDrawing
            default:
                genericLineDrawing
            }
        }
        .frame(width: 44, height: 44)
    }

    private var trafficLineDrawing: some View {
        ZStack {
            // Road
            Path { path in
                path.move(to: CGPoint(x: 5, y: 38))
                path.addLine(to: CGPoint(x: 39, y: 38))
            }
            .stroke(MarginColors.divider, lineWidth: 1.5)

            // Car silhouette
            Path { path in
                path.addRoundedRect(in: CGRect(x: 12, y: 28, width: 18, height: 8), cornerSize: CGSize(width: 2, height: 2))
            }
            .fill(MarginColors.accent.opacity(0.4))

            // Traffic light
            Circle().fill(MarginColors.destructive).frame(width: 4, height: 4).offset(x: -12, y: -8)
        }
    }

    private var coffeeLineDrawing: some View {
        ZStack {
            // Cup
            Path { path in
                path.move(to: CGPoint(x: 12, y: 15))
                path.addLine(to: CGPoint(x: 14, y: 35))
                path.addLine(to: CGPoint(x: 30, y: 35))
                path.addLine(to: CGPoint(x: 32, y: 15))
            }
            .stroke(MarginColors.accent.opacity(0.5), lineWidth: 1.5)

            // Steam
            Path { path in
                path.move(to: CGPoint(x: 18, y: 12))
                path.addQuadCurve(to: CGPoint(x: 22, y: 8), control: CGPoint(x: 16, y: 8))
                path.move(to: CGPoint(x: 24, y: 11))
                path.addQuadCurve(to: CGPoint(x: 28, y: 7), control: CGPoint(x: 22, y: 7))
            }
            .stroke(MarginColors.secondaryText.opacity(0.4), lineWidth: 1)
        }
    }

    private var elevatorLineDrawing: some View {
        ZStack {
            // Elevator shaft
            Path { path in
                path.addRect(CGRect(x: 14, y: 8, width: 20, height: 30))
            }
            .stroke(MarginColors.divider, lineWidth: 1.5)

            // Floor indicator
            Path { path in
                path.move(to: CGPoint(x: 10, y: 22))
                path.addLine(to: CGPoint(x: 14, y: 22))
                path.move(to: CGPoint(x: 34, y: 22))
                path.addLine(to: CGPoint(x: 38, y: 22))
            }
            .stroke(MarginColors.accent.opacity(0.5), lineWidth: 1.5)

            // Arrows
            Image(systemName: "arrow.up")
                .font(.system(size: 8))
                .foregroundColor(MarginColors.accent.opacity(0.5))
                .offset(x: -14, y: 4)
            Image(systemName: "arrow.down")
                .font(.system(size: 8))
                .foregroundColor(MarginColors.accent.opacity(0.5))
                .offset(x: 14, y: -4)
        }
    }

    private var morningLineDrawing: some View {
        ZStack {
            // Sun rays
            ForEach(0..<6, id: \.self) { i in
                let angle = Double(i) * .pi / 3
                Path { path in
                    let startX = 22 + cos(angle) * 10
                    let startY = 20 + sin(angle) * 10
                    let endX = 22 + cos(angle) * 15
                    let endY = 20 + sin(angle) * 15
                    path.move(to: CGPoint(x: startX, y: startY))
                    path.addLine(to: CGPoint(x: endX, y: endY))
                }
                .stroke(MarginColors.accent.opacity(0.4), lineWidth: 1)
            }

            // Sun circle
            Circle()
                .fill(MarginColors.accent.opacity(0.3))
                .frame(width: 14, height: 14)
                .offset(x: 0, y: 0)

            // Horizon line
            Path { path in
                path.move(to: CGPoint(x: 4, y: 34))
                path.addLine(to: CGPoint(x: 40, y: 34))
            }
            .stroke(MarginColors.divider, lineWidth: 1)
        }
    }

    private var eveningLineDrawing: some View {
        ZStack {
            // Moon
            Path { path in
                path.addEllipse(in: CGRect(x: 16, y: 10, width: 16, height: 16))
            }
            .fill(MarginColors.accent.opacity(0.3))

            // Stars
            Circle().fill(MarginColors.secondaryText.opacity(0.4)).frame(width: 2, height: 2).position(x: 35, y: 14)
            Circle().fill(MarginColors.secondaryText.opacity(0.4)).frame(width: 2, height: 2).position(x: 38, y: 22)
            Circle().fill(MarginColors.secondaryText.opacity(0.4)).frame(width: 1.5, height: 1.5).position(x: 32, y: 28)

            // Horizon
            Path { path in
                path.move(to: CGPoint(x: 4, y: 34))
                path.addLine(to: CGPoint(x: 40, y: 34))
            }
            .stroke(MarginColors.divider, lineWidth: 1)
        }
    }

    private var genericLineDrawing: some View {
        ZStack {
            // Simple thought bubble
            Path { path in
                path.addEllipse(in: CGRect(x: 8, y: 8, width: 28, height: 20))
            }
            .stroke(MarginColors.accent.opacity(0.4), lineWidth: 1.5)

            // Small bubbles
            Circle().stroke(MarginColors.accent.opacity(0.3), lineWidth: 1).frame(width: 6, height: 6).position(x: 10, y: 32)
            Circle().stroke(MarginColors.accent.opacity(0.3), lineWidth: 1).frame(width: 4, height: 4).position(x: 6, y: 38)

            // Sparkle
            Path { path in
                path.move(to: CGPoint(x: 28, y: 16))
                path.addLine(to: CGPoint(x: 28, y: 22))
                path.move(to: CGPoint(x: 25, y: 19))
                path.addLine(to: CGPoint(x: 31, y: 19))
            }
            .stroke(MarginColors.accent.opacity(0.5), lineWidth: 1)
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        PatternCard(pattern: Pattern(
            trigger: "Traffic lights",
            thoughtCategory: "relationships",
            patternDescription: "When you're at traffic lights, you tend to think about relationships and people in your life.",
            momentCount: 7,
            confidence: 0.75,
            insights: ["2 of these were deep thoughts", "Your dominant mood here: curious"],
            suggestedActions: ["Try setting a 'done thinking about it' boundary"]
        ))

        PatternCard(pattern: Pattern(
            trigger: "Coffee shops",
            thoughtCategory: "creative",
            patternDescription: "When you're at coffee shops, your mind wanders to creative ideas and projects.",
            momentCount: 5,
            confidence: 0.6
        ))
    }
    .padding()
    .background(MarginColors.background)
}
