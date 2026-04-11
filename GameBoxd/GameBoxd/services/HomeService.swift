import Foundation

struct HomeGame: Identifiable, Codable, Hashable {
    let id: UUID
    let titleKey: String
    let imageName: String
    let imageURLString: String?
    let genres: [String]
    let platform: String
    let rating: Double
    let hoursPlayed: Int
    let descriptionKey: String
    let releaseYear: Int
    let isTrending: Bool

    init(
        id: UUID,
        titleKey: String,
        imageName: String,
        imageURLString: String? = nil,
        genres: [String],
        platform: String,
        rating: Double,
        hoursPlayed: Int,
        descriptionKey: String,
        releaseYear: Int,
        isTrending: Bool
    ) {
        self.id = id
        self.titleKey = titleKey
        self.imageName = imageName
        self.imageURLString = imageURLString
        self.genres = genres
        self.platform = platform
        self.rating = rating
        self.hoursPlayed = hoursPlayed
        self.descriptionKey = descriptionKey
        self.releaseYear = releaseYear
        self.isTrending = isTrending
    }

    var title: String {
        NSLocalizedString(titleKey, comment: "Game title")
    }

    var shortDescription: String {
        NSLocalizedString(descriptionKey, comment: "Game description")
    }

    var imageURL: URL? {
        guard let imageURLString, let url = URL(string: imageURLString) else {
            return nil
        }
        return url
    }

    func applying(remoteMatch: RAWGGameArtworkMatch) -> HomeGame {
        HomeGame(
            id: id,
            titleKey: titleKey,
            imageName: imageName,
            imageURLString: remoteMatch.imageURLString ?? imageURLString,
            genres: remoteMatch.genres.isEmpty ? genres : remoteMatch.genres,
            platform: remoteMatch.platformDisplay ?? platform,
            rating: remoteMatch.rating ?? rating,
            hoursPlayed: hoursPlayed,
            descriptionKey: descriptionKey,
            releaseYear: remoteMatch.releaseYear ?? releaseYear,
            isTrending: isTrending
        )
    }
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

enum HomeServiceError: Error, LocalizedError {
    case gameAlreadyExists(id: UUID)
    case gameNotFound(id: UUID)
    case unknownError

    var errorDescription: String? {
        switch self {
        case .gameAlreadyExists(let id):
            return "A game with ID \(id.uuidString) already exists in the catalog."
        case .gameNotFound(let id):
            return "No game found in the catalog with ID \(id.uuidString)."
        case .unknownError:
            return "An unknown error occurred."
        }
    }
}

enum GameSortType {
    case titleAscending
    case titleDescending
    case ratingAscending
    case ratingDescending
    case hoursPlayedAscending
    case hoursPlayedDescending
    case releaseYearAscending
    case releaseYearDescending
}

protocol HomeServicing {
    func loadHomeContent(for user: User?) -> HomeContent
    func toggleFavorite(gameID: UUID, for user: User?) -> HomeContent
    func markPlayed(gameID: UUID, for user: User?) -> HomeContent
    func isFavorite(gameID: UUID, for user: User?) -> Bool
    func addGame(_ game: HomeGame) throws
    func addGames(_ games: [HomeGame]) throws
    func updateGame(_ game: HomeGame) throws
    func removeGame(id: UUID) throws
    func removeGames(ids: [UUID]) throws
    func allGames() -> [HomeGame]
    func searchGames(query: String) -> [HomeGame]
    func games(forGenre genre: String) -> [HomeGame]
    func games(forPlatform platform: String) -> [HomeGame]
    func gamesSorted(by sortType: GameSortType) -> [HomeGame]
}

protocol HomeCatalogRefreshing {
    func refreshCatalogIfPossible(force: Bool) async
}

extension Notification.Name {
    static let homeServiceCatalogDidChange = Notification.Name("HomeServiceCatalogDidChange")
    static let homeServiceUserStateDidChange = Notification.Name("HomeServiceUserStateDidChange")
}

final class HomeService: HomeServicing, HomeCatalogRefreshing {
    static let shared = HomeService()

    private static let catalogStorageKey = "home.catalog"
    private static let remoteSyncDateKey = "home.catalog.lastRemoteSync"
    private static let remoteSyncInterval: TimeInterval = 6 * 60 * 60

    static let seedCatalog: [HomeGame] = [
        HomeGame(
            id: UUID(uuidString: "A1B3C111-0E2C-4D5F-8010-111111111111")!,
            titleKey: "game.minecraft.title",
            imageName: "minecraft",
            genres: ["Sandbox", "Survival", "Co-op"],
            platform: "PC, Console",
            rating: 4.8,
            hoursPlayed: 180,
            descriptionKey: "game.minecraft.description",
            releaseYear: 2011,
            isTrending: true
        ),
        HomeGame(
            id: UUID(uuidString: "A1B3C111-0E2C-4D5F-8010-222222222222")!,
            titleKey: "game.doom.title",
            imageName: "doom",
            genres: ["Shooter", "Action", "Campaign"],
            platform: "PC, Console",
            rating: 4.7,
            hoursPlayed: 94,
            descriptionKey: "game.doom.description",
            releaseYear: 2016,
            isTrending: true
        ),
        HomeGame(
            id: UUID(uuidString: "A1B3C111-0E2C-4D5F-8010-333333333333")!,
            titleKey: "game.fortnite.title",
            imageName: "Image",
            genres: ["Battle Royale", "Shooter", "Multiplayer"],
            platform: "PC, Console, Mobile",
            rating: 4.4,
            hoursPlayed: 211,
            descriptionKey: "game.fortnite.description",
            releaseYear: 2017,
            isTrending: true
        ),
        HomeGame(
            id: UUID(uuidString: "A1B3C111-0E2C-4D5F-8010-444444444444")!,
            titleKey: "game.overwatch2.title",
            imageName: "Image",
            genres: ["Hero Shooter", "Team", "Competitive"],
            platform: "PC, Console",
            rating: 4.2,
            hoursPlayed: 132,
            descriptionKey: "game.overwatch2.description",
            releaseYear: 2022,
            isTrending: false
        ),
        HomeGame(
            id: UUID(uuidString: "A1B3C111-0E2C-4D5F-8010-555555555555")!,
            titleKey: "game.rocketleague.title",
            imageName: "Image",
            genres: ["Sports", "Competitive", "Multiplayer"],
            platform: "PC, Console",
            rating: 4.5,
            hoursPlayed: 88,
            descriptionKey: "game.rocketleague.description",
            releaseYear: 2015,
            isTrending: false
        ),
        HomeGame(
            id: UUID(uuidString: "A1B3C111-0E2C-4D5F-8010-666666666666")!,
            titleKey: "game.valorant.title",
            imageName: "Image",
            genres: ["Tactical", "Shooter", "Competitive"],
            platform: "PC",
            rating: 4.6,
            hoursPlayed: 156,
            descriptionKey: "game.valorant.description",
            releaseYear: 2020,
            isTrending: true
        )
    ]

    private let defaults = UserDefaults.standard
    private let remoteArtworkService: RAWGArtworkServicing
    private let appStateService: AppStateServicing
    private let catalogLock = NSLock()

    private var catalogStorage: [HomeGame] = HomeService.seedCatalog

    private init(
        remoteArtworkService: RAWGArtworkServicing = RAWGArtworkService.shared,
        appStateService: AppStateServicing = AppStateService.shared
    ) {
        self.remoteArtworkService = remoteArtworkService
        self.appStateService = appStateService
        loadCatalogFromPersistence()
    }

    func loadHomeContent(for user: User?) -> HomeContent {
        let state = loadState(for: user)
        return buildContent(using: allGames(), state: state, user: user)
    }

    func refreshCatalogIfPossible(force: Bool = false) async {
        guard remoteArtworkService.isConfigured else { return }
        guard force || shouldRefreshRemoteArtwork() else { return }

        let currentCatalog = allGames()
        let enrichedCatalog = await remoteArtworkService.enrich(games: currentCatalog)
        defaults.set(Date(), forKey: Self.remoteSyncDateKey)

        guard enrichedCatalog != currentCatalog else { return }
        replaceCatalog(with: enrichedCatalog)
    }

    func toggleFavorite(gameID: UUID, for user: User?) -> HomeContent {
        var state = loadState(for: user)
        guard let game = game(for: gameID, in: allGames()) else {
            return buildContent(using: allGames(), state: state, user: user)
        }

        if let index = state.favoriteGameIDs.firstIndex(of: gameID) {
            state.favoriteGameIDs.remove(at: index)
            appStateService.recordFavoriteChange(game: game, isFavorite: false, for: user)
        } else {
            state.favoriteGameIDs.insert(gameID, at: 0)
            appStateService.recordFavoriteChange(game: game, isFavorite: true, for: user)
        }

        saveState(state, for: user)
        return buildContent(using: allGames(), state: state, user: user)
    }

    func markPlayed(gameID: UUID, for user: User?) -> HomeContent {
        var state = loadState(for: user)
        if let game = game(for: gameID, in: allGames()) {
            appStateService.recordPlayed(game: game, for: user)
        }
        state.recentGameIDs.removeAll { $0 == gameID }
        state.recentGameIDs.insert(gameID, at: 0)
        state.recentGameIDs = Array(state.recentGameIDs.prefix(8))
        state.lastRefresh = Date()
        saveState(state, for: user)
        return buildContent(using: allGames(), state: state, user: user)
    }

    func isFavorite(gameID: UUID, for user: User?) -> Bool {
        loadState(for: user).favoriteGameIDs.contains(gameID)
    }

    func addGame(_ game: HomeGame) throws {
        try updateCatalog { catalog in
            guard !catalog.contains(where: { $0.id == game.id }) else {
                throw HomeServiceError.gameAlreadyExists(id: game.id)
            }
            catalog.append(game)
        }
    }

    func addGames(_ games: [HomeGame]) throws {
        try updateCatalog { catalog in
            let existingIDs = Set(catalog.map(\.id))
            let newIDs = Set(games.map(\.id))
            if let duplicate = existingIDs.intersection(newIDs).first {
                throw HomeServiceError.gameAlreadyExists(id: duplicate)
            }
            catalog.append(contentsOf: games)
        }
    }

    func updateGame(_ game: HomeGame) throws {
        try updateCatalog { catalog in
            guard let index = catalog.firstIndex(where: { $0.id == game.id }) else {
                throw HomeServiceError.gameNotFound(id: game.id)
            }
            catalog[index] = game
        }
    }

    func removeGame(id: UUID) throws {
        try updateCatalog { catalog in
            guard catalog.contains(where: { $0.id == id }) else {
                throw HomeServiceError.gameNotFound(id: id)
            }
            catalog.removeAll { $0.id == id }
        }
    }

    func removeGames(ids: [UUID]) throws {
        try updateCatalog { catalog in
            let existingIDs = Set(catalog.map(\.id))
            let missingIDs = Set(ids).subtracting(existingIDs)
            if let missingID = missingIDs.first {
                throw HomeServiceError.gameNotFound(id: missingID)
            }
            catalog.removeAll { ids.contains($0.id) }
        }
    }

    func allGames() -> [HomeGame] {
        catalogLock.withLock {
            catalogStorage
        }
    }

    func searchGames(query: String) -> [HomeGame] {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else { return allGames() }

        let lowercasedQuery = trimmedQuery.lowercased()
        return allGames().filter { game in
            game.title.lowercased().contains(lowercasedQuery) ||
            game.shortDescription.lowercased().contains(lowercasedQuery) ||
            game.genres.joined(separator: " ").lowercased().contains(lowercasedQuery) ||
            game.platform.lowercased().contains(lowercasedQuery)
        }
    }

    func games(forGenre genre: String) -> [HomeGame] {
        allGames().filter { game in
            game.genres.contains { $0.caseInsensitiveCompare(genre) == .orderedSame }
        }
    }

    func games(forPlatform platform: String) -> [HomeGame] {
        let lowercasedPlatform = platform.lowercased()
        return allGames().filter { game in
            game.platform
                .components(separatedBy: ",")
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() }
                .contains(lowercasedPlatform)
        }
    }

    func gamesSorted(by sortType: GameSortType) -> [HomeGame] {
        let games = allGames()
        switch sortType {
        case .titleAscending:
            return games.sorted { $0.title.localizedCompare($1.title) == .orderedAscending }
        case .titleDescending:
            return games.sorted { $0.title.localizedCompare($1.title) == .orderedDescending }
        case .ratingAscending:
            return games.sorted { $0.rating < $1.rating }
        case .ratingDescending:
            return games.sorted { $0.rating > $1.rating }
        case .hoursPlayedAscending:
            return games.sorted { $0.hoursPlayed < $1.hoursPlayed }
        case .hoursPlayedDescending:
            return games.sorted { $0.hoursPlayed > $1.hoursPlayed }
        case .releaseYearAscending:
            return games.sorted { $0.releaseYear < $1.releaseYear }
        case .releaseYearDescending:
            return games.sorted { $0.releaseYear > $1.releaseYear }
        }
    }

    private func shouldRefreshRemoteArtwork() -> Bool {
        guard let lastRefresh = defaults.object(forKey: Self.remoteSyncDateKey) as? Date else {
            return true
        }

        if allGames().contains(where: { $0.imageURL == nil }) {
            return true
        }

        return Date().timeIntervalSince(lastRefresh) > Self.remoteSyncInterval
    }

    private func buildContent(using catalog: [HomeGame], state: HomeUserState, user: User?) -> HomeContent {
        let safeCatalog = catalog.isEmpty ? HomeService.seedCatalog : catalog

        let featuredGame = state.recentGameIDs
            .compactMap { game(for: $0, in: safeCatalog) }
            .first ?? safeCatalog.max(by: { $0.rating < $1.rating }) ?? HomeService.seedCatalog[0]

        let favoriteGames = state.favoriteGameIDs.compactMap { game(for: $0, in: safeCatalog) }
        let recentGames = state.recentGameIDs.compactMap { game(for: $0, in: safeCatalog) }

        let preferredGenres = Set(favoriteGames.flatMap(\.genres))
        let recommendedGames = safeCatalog
            .filter { !favoriteGames.contains($0) }
            .sorted { lhs, rhs in
                let lhsScore = recommendationScore(for: lhs, preferredGenres: preferredGenres)
                let rhsScore = recommendationScore(for: rhs, preferredGenres: preferredGenres)
                if lhsScore == rhsScore {
                    return lhs.rating > rhs.rating
                }
                return lhsScore > rhsScore
            }

        let trendingGames = safeCatalog
            .filter(\.isTrending)
            .sorted { $0.rating > $1.rating }

        let recentSectionItems = recentGames.isEmpty
            ? Array(safeCatalog.sorted { $0.hoursPlayed > $1.hoursPlayed }.prefix(5))
            : recentGames

        let sections = [
            HomeSection(
                id: "trending",
                title: NSLocalizedString("section.trending", comment: "Trending section title"),
                subtitle: NSLocalizedString("section.trending.subtitle", comment: "Trending section subtitle"),
                items: Array(trendingGames.prefix(5))
            ),
            HomeSection(
                id: "recommended",
                title: NSLocalizedString("section.recommended", comment: "Recommended section title"),
                subtitle: favoriteGames.isEmpty
                    ? NSLocalizedString("section.recommended.empty.subtitle", comment: "Recommended empty section subtitle")
                    : NSLocalizedString("section.recommended.subtitle", comment: "Recommended section subtitle"),
                items: Array(recommendedGames.prefix(5))
            ),
            HomeSection(
                id: "recent",
                title: NSLocalizedString("section.recent", comment: "Recent section title"),
                subtitle: recentGames.isEmpty
                    ? NSLocalizedString("section.recent.empty.subtitle", comment: "Recent empty section subtitle")
                    : NSLocalizedString("section.recent.subtitle", comment: "Recent section subtitle"),
                items: recentSectionItems
            )
        ]

        let notificationCount = appStateService.unreadNotificationCount(for: user)

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
            return .empty
        }
        return state
    }

    private func saveState(_ state: HomeUserState, for user: User?) {
        guard let encoded = try? JSONEncoder().encode(state) else { return }
        defaults.set(encoded, forKey: storageKey(for: user))
        NotificationCenter.default.post(name: .homeServiceUserStateDidChange, object: user)
    }

    private func storageKey(for user: User?) -> String {
        let userKey = user?.id.uuidString ?? "guest"
        return "home.state.\(userKey)"
    }

    private func game(for id: UUID, in catalog: [HomeGame]) -> HomeGame? {
        catalog.first { $0.id == id }
    }

    private func loadCatalogFromPersistence() {
        guard
            let data = defaults.data(forKey: Self.catalogStorageKey),
            let savedCatalog = try? JSONDecoder().decode([HomeGame].self, from: data),
            !savedCatalog.isEmpty
        else {
            return
        }

        catalogLock.withLock {
            catalogStorage = savedCatalog
        }
    }

    private func replaceCatalog(with newCatalog: [HomeGame]) {
        catalogLock.withLock {
            catalogStorage = newCatalog
            saveCatalogLocked()
        }
        NotificationCenter.default.post(name: .homeServiceCatalogDidChange, object: nil)
    }

    private func updateCatalog(_ update: (inout [HomeGame]) throws -> Void) throws {
        try catalogLock.withLock {
            try update(&catalogStorage)
            saveCatalogLocked()
        }
        NotificationCenter.default.post(name: .homeServiceCatalogDidChange, object: nil)
    }

    private func saveCatalogLocked() {
        guard let encoded = try? JSONEncoder().encode(catalogStorage) else { return }
        defaults.set(encoded, forKey: Self.catalogStorageKey)
    }
}

final class MockHomeService: HomeServicing, HomeCatalogRefreshing {
    private var games: [HomeGame]
    private var userStates: [String: HomeUserState] = [:]

    init(games: [HomeGame]? = nil) {
        self.games = games ?? HomeService.seedCatalog
    }

    func refreshCatalogIfPossible(force: Bool) async {}

    func loadHomeContent(for user: User?) -> HomeContent {
        let state = userStates[storageKey(for: user)] ?? .empty
        return buildContent(using: games, state: state)
    }

    func toggleFavorite(gameID: UUID, for user: User?) -> HomeContent {
        let key = storageKey(for: user)
        var state = userStates[key] ?? .empty

        if let index = state.favoriteGameIDs.firstIndex(of: gameID) {
            state.favoriteGameIDs.remove(at: index)
        } else {
            state.favoriteGameIDs.insert(gameID, at: 0)
        }

        userStates[key] = state
        return buildContent(using: games, state: state)
    }

    func markPlayed(gameID: UUID, for user: User?) -> HomeContent {
        let key = storageKey(for: user)
        var state = userStates[key] ?? .empty
        state.recentGameIDs.removeAll { $0 == gameID }
        state.recentGameIDs.insert(gameID, at: 0)
        state.recentGameIDs = Array(state.recentGameIDs.prefix(8))
        userStates[key] = state
        return buildContent(using: games, state: state)
    }

    func isFavorite(gameID: UUID, for user: User?) -> Bool {
        let state = userStates[storageKey(for: user)] ?? .empty
        return state.favoriteGameIDs.contains(gameID)
    }

    func addGame(_ game: HomeGame) throws {
        guard !games.contains(where: { $0.id == game.id }) else {
            throw HomeServiceError.gameAlreadyExists(id: game.id)
        }
        games.append(game)
    }

    func addGames(_ games: [HomeGame]) throws {
        let existingIDs = Set(self.games.map(\.id))
        let newIDs = Set(games.map(\.id))
        if let duplicate = existingIDs.intersection(newIDs).first {
            throw HomeServiceError.gameAlreadyExists(id: duplicate)
        }
        self.games.append(contentsOf: games)
    }

    func updateGame(_ game: HomeGame) throws {
        guard let index = games.firstIndex(where: { $0.id == game.id }) else {
            throw HomeServiceError.gameNotFound(id: game.id)
        }
        games[index] = game
    }

    func removeGame(id: UUID) throws {
        guard games.contains(where: { $0.id == id }) else {
            throw HomeServiceError.gameNotFound(id: id)
        }
        games.removeAll { $0.id == id }
    }

    func removeGames(ids: [UUID]) throws {
        let existingIDs = Set(games.map(\.id))
        let missingIDs = Set(ids).subtracting(existingIDs)
        if let missingID = missingIDs.first {
            throw HomeServiceError.gameNotFound(id: missingID)
        }
        games.removeAll { ids.contains($0.id) }
    }

    func allGames() -> [HomeGame] {
        games
    }

    func searchGames(query: String) -> [HomeGame] {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else { return games }

        let lowercasedQuery = trimmedQuery.lowercased()
        return games.filter { game in
            game.title.lowercased().contains(lowercasedQuery) ||
            game.shortDescription.lowercased().contains(lowercasedQuery) ||
            game.genres.joined(separator: " ").lowercased().contains(lowercasedQuery) ||
            game.platform.lowercased().contains(lowercasedQuery)
        }
    }

    func games(forGenre genre: String) -> [HomeGame] {
        games.filter { game in
            game.genres.contains { $0.caseInsensitiveCompare(genre) == .orderedSame }
        }
    }

    func games(forPlatform platform: String) -> [HomeGame] {
        let lowercasedPlatform = platform.lowercased()
        return games.filter { game in
            game.platform
                .components(separatedBy: ",")
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() }
                .contains(lowercasedPlatform)
        }
    }

    func gamesSorted(by sortType: GameSortType) -> [HomeGame] {
        switch sortType {
        case .titleAscending:
            return games.sorted { $0.title.localizedCompare($1.title) == .orderedAscending }
        case .titleDescending:
            return games.sorted { $0.title.localizedCompare($1.title) == .orderedDescending }
        case .ratingAscending:
            return games.sorted { $0.rating < $1.rating }
        case .ratingDescending:
            return games.sorted { $0.rating > $1.rating }
        case .hoursPlayedAscending:
            return games.sorted { $0.hoursPlayed < $1.hoursPlayed }
        case .hoursPlayedDescending:
            return games.sorted { $0.hoursPlayed > $1.hoursPlayed }
        case .releaseYearAscending:
            return games.sorted { $0.releaseYear < $1.releaseYear }
        case .releaseYearDescending:
            return games.sorted { $0.releaseYear > $1.releaseYear }
        }
    }

    private func buildContent(using catalog: [HomeGame], state: HomeUserState) -> HomeContent {
        let safeCatalog = catalog.isEmpty ? HomeService.seedCatalog : catalog

        let featuredGame = state.recentGameIDs
            .compactMap { id in safeCatalog.first(where: { $0.id == id }) }
            .first ?? safeCatalog.max(by: { $0.rating < $1.rating }) ?? HomeService.seedCatalog[0]

        let favoriteGames = state.favoriteGameIDs.compactMap { id in safeCatalog.first(where: { $0.id == id }) }
        let recentGames = state.recentGameIDs.compactMap { id in safeCatalog.first(where: { $0.id == id }) }
        let preferredGenres = Set(favoriteGames.flatMap(\.genres))

        let recommendedGames = safeCatalog
            .filter { !favoriteGames.contains($0) }
            .sorted { lhs, rhs in
                let lhsScore = recommendationScore(for: lhs, preferredGenres: preferredGenres)
                let rhsScore = recommendationScore(for: rhs, preferredGenres: preferredGenres)
                if lhsScore == rhsScore {
                    return lhs.rating > rhs.rating
                }
                return lhsScore > rhsScore
            }

        let trendingGames = safeCatalog
            .filter(\.isTrending)
            .sorted { $0.rating > $1.rating }

        let recentSectionItems = recentGames.isEmpty
            ? Array(safeCatalog.sorted { $0.hoursPlayed > $1.hoursPlayed }.prefix(5))
            : recentGames

        return HomeContent(
            featuredGame: featuredGame,
            sections: [
                HomeSection(
                    id: "trending",
                    title: NSLocalizedString("section.trending", comment: "Trending section title"),
                    subtitle: NSLocalizedString("section.trending.subtitle", comment: "Trending section subtitle"),
                    items: Array(trendingGames.prefix(5))
                ),
                HomeSection(
                    id: "recommended",
                    title: NSLocalizedString("section.recommended", comment: "Recommended section title"),
                    subtitle: favoriteGames.isEmpty
                        ? NSLocalizedString("section.recommended.empty.subtitle", comment: "Recommended empty section subtitle")
                        : NSLocalizedString("section.recommended.subtitle", comment: "Recommended section subtitle"),
                    items: Array(recommendedGames.prefix(5))
                ),
                HomeSection(
                    id: "recent",
                    title: NSLocalizedString("section.recent", comment: "Recent section title"),
                    subtitle: recentGames.isEmpty
                        ? NSLocalizedString("section.recent.empty.subtitle", comment: "Recent empty section subtitle")
                        : NSLocalizedString("section.recent.subtitle", comment: "Recent section subtitle"),
                    items: recentSectionItems
                )
            ],
            notificationCount: max(1, min(9, favoriteGames.count + recentGames.count))
        )
    }

    private func recommendationScore(for game: HomeGame, preferredGenres: Set<String>) -> Int {
        let overlap = Set(game.genres).intersection(preferredGenres).count
        return overlap * 10 + game.hoursPlayed
    }

    private func storageKey(for user: User?) -> String {
        user?.id.uuidString ?? "guest"
    }
}

private extension NSLock {
    func withLock<T>(_ body: () throws -> T) rethrows -> T {
        lock()
        defer { unlock() }
        return try body()
    }
}
