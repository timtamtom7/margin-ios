import Foundation

// R11: Groups, Threads, Insights for Margin
@MainActor
final class MarginR11Service: ObservableObject {
    static let shared = MarginR11Service()

    @Published var groups: [MarginGroup] = []
    @Published var communityInsights: CommunityInsights?

    private init() {}

    // MARK: - Groups

    struct MarginGroup: Identifiable {
        let id = UUID()
        var name: String
        var members: [GroupMember]
        var moments: [Moment]
        var settings: GroupSettings

        struct GroupMember: Identifiable {
            let id: UUID
            var name: String
            var avatarSeed: Int
        }

        struct GroupSettings {
            var requireApproval: Bool
            var anonymousAllowed: Bool
        }
    }

    struct Moment: Identifiable {
        let id = UUID()
        var content: String
        var mood: Mood
        var authorId: UUID?
        var timestamp: Date
        var reactions: [Reaction]
        var threadReplies: [ThreadReply]

        enum Mood: String {
            case happy, sad, anxious, peaceful, excited, neutral
        }

        struct Reaction {
            let emoji: String
            var count: Int
        }

        struct ThreadReply: Identifiable {
            let id = UUID()
            var content: String
            var authorId: UUID?
        }
    }

    func createGroup(name: String, maxMembers: Int = 20) -> MarginGroup {
        MarginGroup(
            id: UUID(),
            name: name,
            members: [],
            moments: [],
            settings: MarginGroup.GroupSettings(requireApproval: false, anonymousAllowed: true)
        )
    }

    func postToGroup(_ groupId: UUID, content: String, mood: Moment.Mood) {
        guard let index = groups.firstIndex(where: { $0.id == groupId }) else { return }
        let moment = Moment(
            id: UUID(),
            content: content,
            mood: mood,
            authorId: nil,
            timestamp: Date(),
            reactions: [],
            threadReplies: []
        )
        groups[index].moments.insert(moment, at: 0)
    }

    // MARK: - Community Insights

    struct CommunityInsights {
        let totalMomentsThisWeek: Int
        let topMoods: [String: Int]
        let trendingTopics: [String]
        let weekOverWeekChange: Double
    }

    func fetchCommunityInsights() async -> CommunityInsights {
        CommunityInsights(
            totalMomentsThisWeek: 0,
            topMoods: [:],
            trendingTopics: [],
            weekOverWeekChange: 0
        )
    }
}
