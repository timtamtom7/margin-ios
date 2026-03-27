import SwiftUI

struct CaptureButton: View {
    let action: () -> Void

    @State private var isPulsing = false
    @State private var isPressed = false

    var body: some View {
        Button(action: {
            Theme.Haptic.medium()
            action()
        }) {
            ZStack {
                // Outer pulse ring
                Circle()
                    .fill(MarginColors.accent.opacity(0.2))
                    .frame(width: 80, height: 80)
                    .scaleEffect(isPulsing ? 1.1 : 0.95)
                    .opacity(isPulsing ? 0 : 1)

                // Main circle
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                MarginColors.accent,
                                MarginColors.accent.opacity(0.8)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 64, height: 64)
                    .shadow(color: MarginColors.accent.opacity(0.4), radius: isPressed ? 4 : 8, x: 0, y: isPressed ? 2 : 4)
                    .scaleEffect(isPressed ? 0.95 : (isPulsing ? 1.03 : 1.0))

                // Inner highlight
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.white.opacity(0.3),
                                Color.white.opacity(0)
                            ]),
                            startPoint: .top,
                            endPoint: .center
                        )
                    )
                    .frame(width: 56, height: 30)
                    .offset(y: -10)

                // Plus icon
                Image(systemName: "plus")
                    .font(.system(size: 22, weight: .medium))
                    .foregroundColor(.white)
                    .shadow(color: Color.black.opacity(0.1), radius: 1, x: 0, y: 1)
            }
        }
        .buttonStyle(CaptureButtonStyle())
        .accessibilityLabel("Capture new thought")
        .accessibilityHint("Opens the capture screen to record a new micro-thought")
        .onAppear {
            withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
                isPulsing = true
            }
        }
    }
}

struct CaptureButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.92 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

#Preview {
    CaptureButton(action: {})
        .padding()
        .background(MarginColors.background)
}
