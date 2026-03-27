import SwiftUI

struct DailyDigestCard: View {
    let digest: DailyDigest

    var body: some View {
        VStack(alignment: .leading, spacing: MarginSpacing.md) {
            // Header with handwritten feel
            HStack {
                Text("Today's Margin")
                    .font(MarginFonts.subheading)
                    .foregroundColor(MarginColors.primaryText)
                    .italic()

                Spacer()

                Text(digest.formattedDate)
                    .font(MarginFonts.caption)
                    .foregroundColor(MarginColors.secondaryText)
            }

            // Stats in hand-drawn table style
            HStack(spacing: MarginSpacing.lg) {
                statItem(value: "\(digest.totalMoments)", label: "moments", icon: "square.stack")
                statItem(value: "\(digest.estimatedDeadTimeMinutes)", label: "minutes", icon: "clock")
                if let category = digest.topThoughtCategory {
                    statItem(value: String(category.prefix(8)), label: "top thought", icon: "brain")
                }
            }

            // R2: Decorative hand-drawn divider
            handdrawnDivider

            // Summary with handwritten style
            Text(digest.summary)
                .font(MarginFonts.handwritten)
                .foregroundColor(MarginColors.secondaryText)
                .italic()

            // R2: Decorative squiggles
            HStack {
                squiggle(width: 40)
                Spacer()
                Circle().fill(MarginColors.accent.opacity(0.3)).frame(width: 6, height: 6)
                Spacer()
                squiggle(width: 40)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Today's Margin digest: \(digest.totalMoments) moments, \(digest.estimatedDeadTimeMinutes) minutes of dead time")
        .padding(MarginSpacing.lg)
        .background(
            ZStack {
                MarginColors.surface
                // Subtle lined paper effect
                VStack(spacing: 12) {
                    ForEach(0..<12, id: \.self) { _ in
                        Rectangle()
                            .fill(MarginColors.divider.opacity(0.3))
                            .frame(height: 1)
                        Spacer().frame(height: 12)
                    }
                }
                .padding(.top, 40)
            }
        )
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 3)
        .overlay(
            // R2: Corner fold effect
            cornerFold
        )
    }

    private func statItem(value: String, label: String, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 10))
                    .foregroundColor(MarginColors.accent.opacity(0.6))
                Text(value)
                    .font(.system(size: 28, weight: .light, design: .serif))
                    .foregroundColor(MarginColors.accent)
            }
            Text(label)
                .font(MarginFonts.caption)
                .foregroundColor(MarginColors.secondaryText)
        }
    }

    // R2: Hand-drawn style divider
    private var handdrawnDivider: some View {
        Path { path in
            path.move(to: CGPoint(x: 0, y: 0))
            // Slightly wobbly line
            let points: [CGPoint] = [
                CGPoint(x: 0, y: 0),
                CGPoint(x: 40, y: 1.5),
                CGPoint(x: 80, y: -0.5),
                CGPoint(x: 120, y: 1),
                CGPoint(x: 160, y: -1),
                CGPoint(x: 200, y: 0.5),
                CGPoint(x: 240, y: 0),
                CGPoint(x: 280, y: -0.5),
                CGPoint(x: 320, y: 1)
            ]
            for point in points {
                path.addLine(to: point)
            }
        }
        .stroke(MarginColors.divider, lineWidth: 1)
        .frame(height: 2)
    }

    // R2: Simple squiggle decoration
    private func squiggle(width: CGFloat) -> some View {
        Path { path in
            path.move(to: CGPoint(x: 0, y: 0))
            let steps = 4
            let stepWidth = width / CGFloat(steps)
            for i in 0..<steps {
                let x = CGFloat(i) * stepWidth + stepWidth / 2
                let y = i % 2 == 0 ? -3.0 : 3.0
                path.addQuadCurve(to: CGPoint(x: x + stepWidth / 2, y: 0), control: CGPoint(x: x, y: y))
            }
        }
        .stroke(MarginColors.accent.opacity(0.3), lineWidth: 1)
        .frame(width: width, height: 6)
    }

    // R2: Corner fold effect
    private var cornerFold: some View {
        GeometryReader { geo in
            let size: CGFloat = 20
            Path { path in
                path.move(to: CGPoint(x: geo.size.width - size, y: 0))
                path.addLine(to: CGPoint(x: geo.size.width, y: size))
                path.addLine(to: CGPoint(x: geo.size.width - size, y: size))
                path.closeSubpath()
            }
            .fill(MarginColors.divider.opacity(0.5))
        }
        .frame(width: 20, height: 20)
        .offset(x: 8, y: -8)
        .rotationEffect(.degrees(0))
    }
}

#Preview {
    DailyDigestCard(digest: DailyDigest(
        date: Date(),
        totalMoments: 12,
        estimatedDeadTimeMinutes: 24,
        topThoughtCategory: "work",
        topContext: "afternoon",
        summary: "Today you had 12 micro-moments, about 24 minutes of dead time. You thought most about work. Most of these happened in the afternoon."
    ))
    .padding()
    .background(MarginColors.background)
}
