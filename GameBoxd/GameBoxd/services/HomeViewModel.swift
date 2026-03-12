import Foundation
import Combine

@MainActor
final class HomeViewModel: ObservableObject {
    @Published private(set) var featuredGame: HomeGame?
    @Published private(set) var sections: [HomeSection] = []
    @Published private(set) var notificationCount: Int = 0
    @Published private(set) var isLoading: Bool = false
    @Published var selectedGame: HomeGame?

    private let service: HomeServicing

    init(service: HomeServicing? = nil) {
        self.service = service ?? HomeService.shared
    }

    func load(for user: User?) {
        apply(service.loadHomeContent(for: user))
    }

    func refresh(for user: User?) async {
        isLoading = true
        try? await Task.sleep(nanoseconds: 350_000_000)
        apply(service.loadHomeContent(for: user))
        isLoading = false
    }

    func markPlayed(_ game: HomeGame, for user: User?) {
        apply(service.markPlayed(gameID: game.id, for: user))
    }

    func toggleFavorite(_ game: HomeGame, for user: User?) {
        apply(service.toggleFavorite(gameID: game.id, for: user))
    }

    func isFavorite(_ game: HomeGame, for user: User?) -> Bool {
        service.isFavorite(gameID: game.id, for: user)
    }

    private func apply(_ content: HomeContent) {
        featuredGame = content.featuredGame
        sections = content.sections
        notificationCount = content.notificationCount
    }
}
