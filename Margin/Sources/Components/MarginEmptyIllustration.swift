import SwiftUI

/// A paper-like notebook illustration for Margin's empty states.
struct MarginEmptyIllustration: View {
    let size: CGFloat

    private let background = Color(hex: "F5F2EB")
    private let surface = Color(hex: "FDFCF8")
    private let primaryText = Color(hex: "2C2A26")
    private let secondaryText = Color(hex: "7A776F")
    private let accent = Color(hex: "C4A882")
    private let divider = Color(hex: "E0DDD4")
    private let sage = Color(hex: "9AAEAB")

    var body: some View {
        Canvas { context, canvasSize in
            let center = CGPoint(x: canvasSize.width / 2, y: canvasSize.height / 2)
            let scale = size / 300

            // Soft paper glow
            context.fill(
                Path(ellipseIn: CGRect(
                    x: center.x - 100 * scale,
                    y: center.y - 100 * scale,
                    width: 200 * scale,
                    height: 200 * scale
                )),
                with: .radialGradient(
                    Gradient(colors: [accent.opacity(0.08), Color.clear]),
                    center: center,
                    startRadius: 0,
                    endRadius: 100 * scale
                )
            )

            // Notebook / journal
            let nbX = center.x
            let nbY = center.y
            let nbW: CGFloat = 140 * scale
            let nbH: CGFloat = 180 * scale

            // Notebook shadow
            context.fill(
                Path(roundedRect: CGRect(
                    x: nbX - nbW / 2 + 6 * scale,
                    y: nbY - nbH / 2 + 8 * scale,
                    width: nbW,
                    height: nbH
                ), cornerRadius: 4 * scale),
                with: .color(secondaryText.opacity(0.1))
            )

            // Notebook body
            context.fill(
                Path(roundedRect: CGRect(
                    x: nbX - nbW / 2,
                    y: nbY - nbH / 2,
                    width: nbW,
                    height: nbH
                ), cornerRadius: 4 * scale),
                with: .color(surface)
            )

            // Notebook lines
            let lineSpacing = 22 * scale
            let lineStartY = nbY - nbH / 2 + 30 * scale
            let lineEndY = nbY + nbH / 2 - 20 * scale
            let lineStartX = nbX - nbW / 2 + 30 * scale
            let lineEndX = nbX + nbW / 2 - 15 * scale

            var lineIndex: CGFloat = 0
            var ly = lineStartY
            while ly < lineEndY {
                var linePath = Path()
                linePath.move(to: CGPoint(x: lineStartX, y: ly))
                linePath.addLine(to: CGPoint(x: lineEndX, y: ly))
                context.stroke(linePath, with: .color(divider), lineWidth: 0.8 * scale)
                ly = lineStartY + lineIndex * lineSpacing
                lineIndex += 1
            }

            // Margin line (vertical)
            var marginPath = Path()
            marginPath.move(to: CGPoint(x: nbX - nbW / 2 + 25 * scale, y: nbY - nbH / 2 + 10 * scale))
            marginPath.addLine(to: CGPoint(x: nbX - nbW / 2 + 25 * scale, y: nbY + nbH / 2 - 15 * scale))
            context.stroke(marginPath, with: .color(accent.opacity(0.4)), lineWidth: 1 * scale)

            // Handwritten text (abstract lines in margin)
            var marginLine1 = Path()
            marginLine1.addRect(CGRect(x: nbX - nbW / 2 + 8 * scale, y: nbY - nbH / 2 + 35 * scale, width: 14 * scale, height: 2 * scale))
            context.fill(marginLine1, with: .color(accent.opacity(0.5)))

            var marginLine2 = Path()
            marginLine2.addRect(CGRect(x: nbX - nbW / 2 + 8 * scale, y: nbY - nbH / 2 + 57 * scale, width: 12 * scale, height: 2 * scale))
            context.fill(marginLine2, with: .color(accent.opacity(0.4)))

            var marginLine3 = Path()
            marginLine3.addRect(CGRect(x: nbX - nbW / 2 + 8 * scale, y: nbY - nbH / 2 + 79 * scale, width: 15 * scale, height: 2 * scale))
            context.fill(marginLine3, with: .color(accent.opacity(0.3)))

            // Notebook binding (left edge)
            var bindingPath = Path()
            bindingPath.addRect(CGRect(
                x: nbX - nbW / 2 - 8 * scale,
                y: nbY - nbH / 2,
                width: 10 * scale,
                height: nbH
            ))
            context.fill(bindingPath, with: .color(accent.opacity(0.2)))

            // Binding rings
            let ringYs = [nbY - nbH / 2 + 40 * scale, nbY - nbH / 2 + 90 * scale, nbY - nbH / 2 + 140 * scale]
            for ry in ringYs {
                var ringPath = Path()
                ringPath.addEllipse(in: CGRect(
                    x: nbX - nbW / 2 - 10 * scale,
                    y: ry - 4 * scale,
                    width: 12 * scale,
                    height: 8 * scale
                ))
                context.stroke(ringPath, with: .color(accent), lineWidth: 1.5 * scale)
            }

            // Pencil (decorative)
            let pencilX = nbX + nbW / 2 + 15 * scale
            let pencilY = nbY + nbH / 4
            // Pencil body
            var pencilPath = Path()
            pencilPath.move(to: CGPoint(x: pencilX - 60 * scale, y: pencilY + 40 * scale))
            pencilPath.addLine(to: CGPoint(x: pencilX, y: pencilY))
            pencilPath.addLine(to: CGPoint(x: pencilX - 60 * scale, y: pencilY - 40 * scale))
            pencilPath.closeSubpath()
            context.fill(pencilPath, with: .color(accent.opacity(0.3)))
            context.stroke(pencilPath, with: .color(accent.opacity(0.5)), lineWidth: 1 * scale)

            // Pencil tip
            var tipPath = Path()
            tipPath.move(to: CGPoint(x: pencilX, y: pencilY))
            tipPath.addLine(to: CGPoint(x: pencilX - 60 * scale, y: pencilY + 40 * scale))
            tipPath.addLine(to: CGPoint(x: pencilX - 70 * scale, y: pencilY))
            tipPath.closeSubpath()
            context.fill(tipPath, with: .color(secondaryText.opacity(0.4)))

            // Decorative dots
            let dots: [(CGPoint, CGFloat)] = [
                (CGPoint(x: 40 * scale, y: 80 * scale), 2 * scale),
                (CGPoint(x: 260 * scale, y: 60 * scale), 3 * scale),
                (CGPoint(x: 30 * scale, y: 240 * scale), 2 * scale),
                (CGPoint(x: 270 * scale, y: 220 * scale), 2 * scale),
            ]
            for (pos, r) in dots {
                var dotPath = Path()
                dotPath.addEllipse(in: CGRect(
                    x: pos.x - r,
                    y: pos.y - r,
                    width: r * 2,
                    height: r * 2
                ))
                context.fill(dotPath, with: .color(divider.opacity(0.5)))
            }
        }
        .frame(width: size, height: size)
    }
}

#Preview {
    ZStack {
        MarginColors.background.ignoresSafeArea()
        MarginEmptyIllustration(size: 200)
    }
}
