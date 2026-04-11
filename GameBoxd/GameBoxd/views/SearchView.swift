import Foundation
import SwiftUI

struct SearchView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel
    @State private var query = ""
    @State private var catalog: [HomeGame] = []
    @State private var displayedGames: [HomeGame] = []
    @State private var selectedGame: HomeGame?

    private let service: HomeServicing = HomeService.shared

    private var trimmedQuery: String {
        query.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var trendingGames: [HomeGame] {
        catalog.filter(\.isTrending)
    }

    private var quickGenres: [String] {
        Array(Set(catalog.flatMap(\.genres))).sorted().prefix(6).map { $0 }
    }

    var body: some View {
        NavigationStack {
            AppBackground {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 22) {
                        AppScreenHeader(
                            eyebrow: "Discover",
                            title: "Search",
                            subtitle: trimmedQuery.isEmpty
                                ? "Browse your catalog, trending picks, and genre shortcuts."
                                : "\(displayedGames.count) results for \"\(trimmedQuery)\""
                        )
                        .padding(.horizontal, 20)
                        .padding(.top, 12)

                        SearchBar(text: $query)
                            .padding(.horizontal, 20)

                        if trimmedQuery.isEmpty {
                            discoverContent
                        } else if displayedGames.isEmpty {
                            AppEmptyState(
                                title: "No matches yet",
                                message: "Try another game title, platform, or genre keyword.",
                                systemImage: "magnifyingglass"
                            )
                            .padding(.horizontal, 20)
                        } else {
                            VStack(spacing: 14) {
                                ForEach(displayedGames) { game in
                                    Button {
                                        selectedGame = game
                                    } label: {
                                        GameRow(game: game)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                    .padding(.bottom, 32)
                }
            }
            .task {
                await refreshCatalogIfNeeded(force: false)
                reloadGames()
            }
            .onChange(of: query) { _, _ in
                reloadGames()
            }
            .onReceive(NotificationCenter.default.publisher(for: .homeServiceCatalogDidChange)) { _ in
                reloadGames()
            }
            .sheet(item: $selectedGame) { game in
                GameDetailsSheet(
                    game: game,
                    isFavorite: service.isFavorite(gameID: game.id, for: authViewModel.currentUser),
                    onFavoriteToggle: {
                        _ = service.toggleFavorite(gameID: game.id, for: authViewModel.currentUser)
                        reloadGames()
                    },
                    onMarkPlayed: {
                        _ = service.markPlayed(gameID: game.id, for: authViewModel.currentUser)
                        reloadGames()
                    }
                )
                .presentationDetents([.medium, .large])
            }
        }
    }

    private var discoverContent: some View {
        VStack(alignment: .leading, spacing: 22) {
            VStack(alignment: .leading, spacing: 12) {
                AppSectionHeader(
                    title: "Browse by genre",
                    subtitle: "Fast ways to jump into your library."
                )

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(quickGenres, id: \.self) { genre in
                            Button {
                                query = genre
                            } label: {
                                AppTag(title: genre, systemImage: "tag.fill")
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .padding(.horizontal, 20)

            VStack(alignment: .leading, spacing: 14) {
                AppSectionHeader(
                    title: "Trending right now",
                    subtitle: "The games people keep checking."
                )
                .padding(.horizontal, 20)

                HorizontalGamesRow(items: trendingGames) { game in
                    selectedGame = game
                }
            }

            VStack(alignment: .leading, spacing: 14) {
                AppSectionHeader(
                    title: "All games",
                    subtitle: "Everything currently in your catalog."
                )
                .padding(.horizontal, 20)

                VStack(spacing: 14) {
                    ForEach(catalog) { game in
                        Button {
                            selectedGame = game
                        } label: {
                            GameRow(game: game)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }

    private func refreshCatalogIfNeeded(force: Bool) async {
        await HomeService.shared.refreshCatalogIfPossible(force: force)
    }

    private func reloadGames() {
        catalog = service.allGames()
        displayedGames = trimmedQuery.isEmpty ? catalog : service.searchGames(query: trimmedQuery)
    }
}

struct GameRow: View {
    let game: HomeGame

    var body: some View {
        AppSurface(cornerRadius: 22, padding: 14, fill: AppTheme.surface) {
            HStack(spacing: 14) {
                GameArtworkView(game: game)
                    .frame(width: 72, height: 86)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

                VStack(alignment: .leading, spacing: 7) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(game.title)
                                .font(.headline.weight(.bold))
                                .foregroundStyle(AppTheme.textPrimary)

                            Text(game.shortDescription)
                                .font(.subheadline)
                                .foregroundStyle(AppTheme.textSecondary)
                                .lineLimit(2)
                        }

                        Spacer(minLength: 8)

                        Text("\(game.rating, specifier: "%.1f")")
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(AppTheme.accent)
                    }

                    HStack(spacing: 8) {
                        AppTag(title: game.platform, systemImage: "desktopcomputer", tint: AppTheme.textPrimary)
                        if let genre = game.genres.first {
                            AppTag(title: genre, tint: AppTheme.success)
                        }
                    }
                }
            }
        }
    }
}

struct SearchBar: View {
    @Binding var text: String
    @FocusState private var isFocused: Bool

    var body: some View {
        AppInputContainer {
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(AppTheme.textSecondary)

                TextField("Search games, genres, or platforms", text: $text)
                    .textInputAutocapitalization(.words)
                    .disableAutocorrection(true)
                    .foregroundStyle(AppTheme.textPrimary)
                    .focused($isFocused)

                if !text.isEmpty {
                    Button {
                        text = ""
                        isFocused = false
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(AppTheme.textSecondary)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

#Preview {
    SearchView()
        .environmentObject(AuthViewModel())
}
