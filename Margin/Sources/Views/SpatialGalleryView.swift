import SwiftUI

/// R14: Vision Pro spatial gallery
/// Immersive reflection gallery
struct SpatialGalleryView: View {
    @State private var selectedMoment: MomentDisplay?
    @State private var isImmersiveMode = false

    struct MomentDisplay: Identifiable {
        let id = UUID()
        let text: String
        let category: String
        let timestamp: Date
        let mood: String
    }

    private let mockMoments: [MomentDisplay] = [
        MomentDisplay(text: "Morning coffee, the quiet before the world wakes", category: "Mindfulness", timestamp: Date(), mood: "Peaceful"),
        MomentDisplay(text: "Watching the sunset paint the sky in orange and pink", category: "Nature", timestamp: Date().addingTimeInterval(-86400), mood: "Grateful"),
        MomentDisplay(text: "The laughter of friends echoing through the park", category: "Connection", timestamp: Date().addingTimeInterval(-172800), mood: "Joyful"),
        MomentDisplay(text: "Rain against the window, a book in hand", category: "Solitude", timestamp: Date().addingTimeInterval(-259200), mood: "Content"),
        MomentDisplay(text: "The first snow of winter falling silently", category: "Nature", timestamp: Date().addingTimeInterval(-345600), mood: "Awed")
    ]

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "1A1A2E"), Color(hex: "16213E"), Color(hex: "0F3460")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 24) {
                Text("Your Moments")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.top)

                galleryGrid
            }
        }
        .sheet(item: $selectedMoment) { moment in
            SpatialMomentDetailView(moment: moment)
        }
    }

    private var galleryGrid: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 16) {
                ForEach(mockMoments) { moment in
                    SpatialMomentCard(moment: moment)
                        .onTapGesture {
                            selectedMoment = moment
                        }
                }
            }
            .padding()
        }
    }
}

struct SpatialMomentCard: View {
    let moment: SpatialGalleryView.MomentDisplay

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            RoundedRectangle(cornerRadius: 12)
                .fill(gradient)
                .frame(height: 100)
                .overlay {
                    Image(systemName: categoryIcon)
                        .font(.largeTitle)
                        .foregroundColor(.white.opacity(0.6))
                }

            Text(moment.text)
                .font(.caption)
                .foregroundColor(.white)
                .lineLimit(2)
                .multilineTextAlignment(.leading)

            Text(moment.timestamp.formatted(date: .abbreviated, time: .omitted))
                .font(.caption2)
                .foregroundColor(.gray)
        }
        .padding(8)
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
    }

    private var gradient: LinearGradient {
        let colors: [Color] = {
            switch moment.category {
            case "Mindfulness": return [.purple, .blue]
            case "Nature": return [.green, .teal]
            case "Connection": return [.orange, .pink]
            case "Solitude": return [.gray, .blue]
            default: return [.blue, .purple]
            }
        }()
        return LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    private var categoryIcon: String {
        switch moment.category {
        case "Mindfulness": return "brain.head.profile"
        case "Nature": return "leaf.fill"
        case "Connection": return "person.2.fill"
        case "Solitude": return "moon.fill"
        default: return "sparkle"
        }
    }
}

struct SpatialMomentDetailView: View {
    let moment: SpatialGalleryView.MomentDisplay

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "1A1A2E"), Color(hex: "16213E")],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()

                Text(moment.text)
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)

                HStack(spacing: 16) {
                    Label(moment.category, systemImage: "tag.fill")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))

                    Label(moment.mood, systemImage: "heart.fill")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }

                Text(moment.timestamp.formatted(date: .long, time: .shortened))
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.5))

                Spacer()

                Button("Close") {
                    // Dismiss handled by sheet
                }
                .buttonStyle(.borderedProminent)
                .padding(.bottom, 40)
            }
        }
    }
}
