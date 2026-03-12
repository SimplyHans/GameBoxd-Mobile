import Foundation

struct HomeGame: Identifiable, Codable, Hashable {
    let id: UUID
    let title: String
    let imageName: String
    let genres: [String]
    let platform: String
    let rating: Double
    let hoursPlayed: Int
    let shortDescription: String
    let releaseYear: Int
    let isTrending: Bool
}

struct HomeSection: Identifiable, Hashable {
    let id: String
    let title: String
    let subtitle: String
    let items: [HomeGame]
}

struct HomeContent {
    let featuredGame: HomeGame
    let sections: [HomeSection]
    let notificationCount: Int
}

private struct HomeUserState: Codable {
    var favoriteGameIDs: [UUID]
    var recentGameIDs: [UUID]
    var lastRefresh: Date?

    static let empty = HomeUserState(favoriteGameIDs: [], recentGameIDs: [], lastRefresh: nil)
}

protocol HomeServicing {
    func loadHomeContent(for user: User?) -> HomeContent
    func toggleFavorite(gameID: UUID, for user: User?) -> HomeContent
    func markPlayed(gameID: UUID, for user: User?) -> HomeContent
    func isFavorite(gameID: UUID, for user: User?) -> Bool
}

final class HomeService: HomeServicing {
    static let shared = HomeService()

    private let defaults = UserDefaults.standard

    private init() {}

    func loadHomeContent(for user: User?) -> HomeContent {
        let state = loadState(for: user)
        return buildContent(using: state)
    }

    func toggleFavorite(gameID: UUID, for user: User?) -> HomeContent {
        var state = loadState(for: user)

        if let index = state.favoriteGameIDs.firstIndex(of: gameID) {
            state.favoriteGameIDs.remove(at: index)
        } else {
            state.favoriteGameIDs.insert(gameID, at: 0)
        }

        saveState(state, for: user)
        return buildContent(using: state)
    }

    func markPlayed(gameID: UUID, for user: User?) -> HomeContent {
        var state = loadState(for: user)
        state.recentGameIDs.removeAll { $0 == gameID }
        state.recentGameIDs.insert(gameID, at: 0)
        state.recentGameIDs = Array(state.recentGameIDs.prefix(8))
        state.lastRefresh = Date()
        saveState(state, for: user)
        return buildContent(using: state)
    }

    func isFavorite(gameID: UUID, for user: User?) -> Bool {
        loadState(for: user).favoriteGameIDs.contains(gameID)
    }

    private func buildContent(using state: HomeUserState) -> HomeContent {
        let featuredGame = state.recentGameIDs
            .compactMap(game(for:))
            .first ?? Self.catalog.max(by: { $0.rating < $1.rating }) ?? Self.catalog[0]

        let favoriteGames = state.favoriteGameIDs.compactMap(game(for:))
        let recentGames = state.recentGameIDs.compactMap(game(for:))

        let preferredGenres = Set(favoriteGames.flatMap(\.genres))
        let recommendedGames = Self.catalog
            .filter { !favoriteGames.contains($0) }
            .sorted { lhs, rhs in
                let lhsScore = recommendationScore(for: lhs, preferredGenres: preferredGenres)
                let rhsScore = recommendationScore(for: rhs, preferredGenres: preferredGenres)
                if lhsScore == rhsScore {
                    return lhs.rating > rhs.rating
                }
                return lhsScore > rhsScore
            }

        let trendingGames = Self.catalog
            .filter(\.isTrending)
            .sorted { $0.rating > $1.rating }

        let recentSectionItems = recentGames.isEmpty
            ? Array(Self.catalog.sorted { $0.hoursPlayed > $1.hoursPlayed }.prefix(5))
            : recentGames

        let sections = [
            HomeSection(
                id: "trending",
                title: "Trending",
                subtitle: "What players are checking out right now",
                items: Array(trendingGames.prefix(5))
            ),
            HomeSection(
                id: "recommended",
                title: "Recommended",
                subtitle: favoriteGames.isEmpty ? "Start marking favorites to personalize this section" : "Picked from your favorite genres",
                items: Array(recommendedGames.prefix(5))
            ),
            HomeSection(
                id: "recent",
                title: "Recently Played",
                subtitle: recentGames.isEmpty ? "Your activity will show up here after you play something" : "Jump back into your latest sessions",
                items: recentSectionItems
            )
        ]

        let notificationCount = max(1, min(9, favoriteGames.count + recentGames.count))

        return HomeContent(
            featuredGame: featuredGame,
            sections: sections,
            notificationCount: notificationCount
        )
    }

    private func recommendationScore(for game: HomeGame, preferredGenres: Set<String>) -> Int {
        let overlap = Set(game.genres).intersection(preferredGenres).count
        return overlap * 10 + game.hoursPlayed
    }

    private func loadState(for user: User?) -> HomeUserState {
        guard
            let data = defaults.data(forKey: storageKey(for: user)),
            let state = try? JSONDecoder().decode(HomeUserState.self, from: data)
        else {
            return HomeUserState.empty
        }

        return state
    }

    private func saveState(_ state: HomeUserState, for user: User?) {
        guard let encoded = try? JSONEncoder().encode(state) else { return }
        defaults.set(encoded, forKey: storageKey(for: user))
    }

    private func storageKey(for user: User?) -> String {
        let userKey = user?.id.uuidString ?? "guest"
        return "home.state.\(userKey)"
    }

    private func game(for id: UUID) -> HomeGame? {
        Self.catalog.first { $0.id == id }
    }

    private static let catalog: [HomeGame] = [
        HomeGame(
            id: UUID(uuidString: "A1B3C111-0E2C-4D5F-8010-111111111111")!,
            title: "Minecraft",
            imageName: "minecraft",
            genres: ["Sandbox", "Survival", "Co-op"],
            platform: "PC, Console",
            rating: 4.8,
            hoursPlayed: 180,
            shortDescription: "Build, survive, and explore in a world that keeps evolving.",
            releaseYear: 2011,
            isTrending: true
        ),
        HomeGame(
            id: UUID(uuidString: "A1B3C111-0E2C-4D5F-8010-222222222222")!,
            title: "DOOM",
            imageName: "doom",
            genres: ["Shooter", "Action", "Campaign"],
            platform: "PC, Console",
            rating: 4.7,
            hoursPlayed: 94,
            shortDescription: "A fast single-player shooter with heavy combat and aggressive pacing.",
            releaseYear: 2016,
            isTrending: true
        ),
        HomeGame(
            id: UUID(uuidString: "A1B3C111-0E2C-4D5F-8010-333333333333")!,
            title: "Fortnite",
            imageName: "Image",
            genres: ["Battle Royale", "Shooter", "Multiplayer"],
            platform: "PC, Console, Mobile",
            rating: 4.4,
            hoursPlayed: 211,
            shortDescription: "Drop in, squad up, and chase the win in a fast live-service battle royale.",
            releaseYear: 2017,
            isTrending: true
        ),
        HomeGame(
            id: UUID(uuidString: "A1B3C111-0E2C-4D5F-8010-444444444444")!,
            title: "Overwatch 2",
            imageName: "Image",
            genres: ["Hero Shooter", "Team", "Competitive"],
            platform: "PC, Console",
            rating: 4.2,
            hoursPlayed: 132,
            shortDescription: "Pick a role, coordinate with your team, and play around map control.",
            releaseYear: 2022,
            isTrending: false
        ),
        HomeGame(
            id: UUID(uuidString: "A1B3C111-0E2C-4D5F-8010-555555555555")!,
            title: "Rocket League",
            imageName: "Image",
            genres: ["Sports", "Competitive", "Multiplayer"],
            platform: "PC, Console",
            rating: 4.5,
            hoursPlayed: 88,
            shortDescription: "High-speed car football with a steep but rewarding skill curve.",
            releaseYear: 2015,
            isTrending: false
        ),
        HomeGame(
            id: UUID(uuidString: "A1B3C111-0E2C-4D5F-8010-666666666666")!,
            title: "Valorant",
            imageName: "Image",
            genres: ["Tactical", "Shooter", "Competitive"],
            platform: "PC",
            rating: 4.6,
            hoursPlayed: 156,
            shortDescription: "Tactical rounds, agent abilities, and tight gunplay built around teamwork.",
            releaseYear: 2020,
            isTrending: true
        )
    ]
}
