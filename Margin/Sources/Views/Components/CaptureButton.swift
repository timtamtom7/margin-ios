import SwiftUI

struct CaptureButton: View {
    let action: () -> Void

    @State private var isPulsing = false

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(MarginColors.accent)
                    .frame(width: 64, height: 64)
                    .shadow(color: MarginColors.accent.opacity(0.3), radius: 8, x: 0, y: 4)

                Image(systemName: "plus")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(.white)
                    .rotationEffect(.degrees(isPulsing ? 0 : 0))
            }
            .scaleEffect(isPulsing ? 1.05 : 1.0)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                isPulsing = true
            }
        }
    }
}

#Preview {
    CaptureButton(action: {})
        .padding()
        .background(MarginColors.background)
}
