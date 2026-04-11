import Foundation
import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel
    @StateObject private var homeViewModel = HomeViewModel()
    @State private var selectedSection: HomeSection?
    @State private var isShowingNotifications = false
    @State private var isShowingSettings = false

    private let service: HomeServicing = HomeService.shared

    private var username: String {
        authViewModel.currentUser?.username ?? NSLocalizedString("player.one", comment: "Default username")
    }

    private var recentGames: [HomeGame] {
        homeViewModel.sections.first(where: { $0.id == "recent" })?.items ?? []
    }

    private var favoriteCount: Int {
        service.allGames().filter { homeViewModel.isFavorite($0, for: authViewModel.currentUser) }.count
    }

    private var trackedHours: Int {
        service.allGames().reduce(0) { $0 + $1.hoursPlayed }
    }

    var body: some View {
        NavigationStack {
            AppBackground {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {
                        header

                        overviewPanel

                        if let featuredGame = homeViewModel.featuredGame {
                            featuredSection(game: featuredGame)
                        }

                        if let recentGame = recentGames.first {
                            continuePlayingCard(game: recentGame)
                        }

                        ForEach(homeViewModel.sections) { section in
                            VStack(alignment: .leading, spacing: 14) {
                                AppSectionHeader(title: section.title, subtitle: section.subtitle) {
                                    Button {
                                        selectedSection = section
                                    } label: {
                                        Text(NSLocalizedString("see.all", comment: "See all button title"))
                                            .font(.caption.weight(.semibold))
                                            .foregroundStyle(AppTheme.accent)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 8)
                                            .background(
                                                Capsule()
                                                    .fill(AppTheme.accent.opacity(0.12))
                                            )
                                    }
                                    .buttonStyle(.plain)
                                }
                                .padding(.horizontal, 20)

                                HorizontalGamesRow(items: section.items) { game in
                                    homeViewModel.selectedGame = game
                                }
                            }
                        }
                    }
                    .padding(.top, 12)
                    .padding(.bottom, 32)
                }
            }
            .task(id: authViewModel.currentUser?.id) {
                await homeViewModel.load(for: authViewModel.currentUser)
            }
            .refreshable {
                await homeViewModel.refresh(for: authViewModel.currentUser)
            }
            .onReceive(NotificationCenter.default.publisher(for: .appStateDidChange)) { _ in
                Task {
                    await homeViewModel.refresh(for: authViewModel.currentUser, forceRemoteSync: false)
                }
            }
            .sheet(item: $homeViewModel.selectedGame) { game in
                GameDetailsSheet(
                    game: game,
                    isFavorite: homeViewModel.isFavorite(game, for: authViewModel.currentUser),
                    onFavoriteToggle: {
                        homeViewModel.toggleFavorite(game, for: authViewModel.currentUser)
                    },
                    onMarkPlayed: {
                        homeViewModel.markPlayed(game, for: authViewModel.currentUser)
                    }
                )
                .presentationDetents([.medium, .large])
            }
            .sheet(item: $selectedSection) { section in
                HomeSectionListView(section: section) { game in
                    selectedSection = nil
                    Task { @MainActor in
                        homeViewModel.selectedGame = game
                    }
                }
            }
            .sheet(isPresented: $isShowingNotifications) {
                NotificationsView()
            }
            .sheet(isPresented: $isShowingSettings) {
                SettingsView()
            }
        }
    }

    private var header: some View {
        AppScreenHeader(
            eyebrow: NSLocalizedString("welcome.back", comment: "Welcome back greeting"),
            title: username,
            subtitle: homeViewModel.isLoading
                ? NSLocalizedString("refreshing.dashboard", comment: "Refreshing dashboard message")
                : NSLocalizedString("track.games", comment: "Track your games subtitle")
        ) {
            HStack(spacing: 10) {
                Button {
                    isShowingNotifications = true
                } label: {
                    AppIconBadge(systemName: "bell", badgeCount: homeViewModel.notificationCount)
                }
                .buttonStyle(.plain)

                Button {
                    isShowingSettings = true
                } label: {
                    AppIconBadge(systemName: "slider.horizontal.3", tint: AppTheme.textPrimary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 20)
    }

    private var overviewPanel: some View {
        AppSurface(fill: AppTheme.surfaceRaised) {
            AppSectionHeader(
                title: "Your dashboard",
                subtitle: "Everything important in one place."
            )

            HStack(spacing: 12) {
                AppMetricBadge(title: "Library", value: "\(service.allGames().count)")
                AppMetricBadge(title: "Favorites", value: "\(favoriteCount)", emphasize: true)
                AppMetricBadge(title: "Hours", value: compactHours(trackedHours))
            }
        }
        .padding(.horizontal, 20)
    }

    private func featuredSection(game: HomeGame) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            AppSectionHeader(
                title: "Editor spotlight",
                subtitle: "A lead pick for today."
            )

            FeaturedHero(game: game) {
                homeViewModel.selectedGame = game
            }
        }
        .padding(.horizontal, 20)
    }

    private func continuePlayingCard(game: HomeGame) -> some View {
        Button {
            homeViewModel.selectedGame = game
        } label: {
            AppSurface(fill: AppTheme.surfaceRaised) {
                AppSectionHeader(
                    title: "Continue playing",
                    subtitle: "Jump back into your latest session."
                )

                HStack(spacing: 14) {
                    GameArtworkView(game: game)
                        .frame(width: 110, height: 110)
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))

                    VStack(alignment: .leading, spacing: 8) {
                        AppTag(title: game.genres.first ?? game.platform, systemImage: "gamecontroller.fill")

                        Text(game.title)
                            .font(.title3.weight(.bold))
                            .foregroundStyle(AppTheme.textPrimary)
                            .multilineTextAlignment(.leading)

                        Text(game.shortDescription)
                            .font(.subheadline)
                            .foregroundStyle(AppTheme.textSecondary)
                            .lineLimit(2)

                        HStack(spacing: 8) {
                            AppTag(title: "\(game.hoursPlayed)h tracked", tint: AppTheme.success)
                            AppTag(title: "\(formatRating(game.rating)) rating", tint: AppTheme.accent)
                        }
                    }

                    Spacer(minLength: 0)
                }
            }
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 20)
    }

    private func compactHours(_ hours: Int) -> String {
        if hours >= 1000 {
            return String(format: "%.1fk", Double(hours) / 1000.0)
        }
        return "\(hours)"
    }
}

struct FeaturedHero: View {
    let game: HomeGame
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack(alignment: .bottomLeading) {
                GameArtworkView(game: game)
                    .frame(height: 320)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                    .overlay(
                        AppTheme.heroGradient
                            .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 30, style: .continuous)
                            .stroke(AppTheme.strongStroke, lineWidth: 1)
                    )

                VStack(alignment: .leading, spacing: 12) {
                    AppTag(title: "Featured today", systemImage: "sparkles")

                    Text(game.title)
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(AppTheme.textPrimary)
                        .multilineTextAlignment(.leading)

                    Text("\(game.platform) • \(game.releaseYear)")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(AppTheme.textSecondary)

                    Text(game.shortDescription)
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.textPrimary.opacity(0.88))
                        .lineLimit(3)

                    HStack(spacing: 10) {
                        AppTag(title: "\(formatRating(game.rating)) rating", tint: AppTheme.accent)
                        AppTag(title: game.genres.first ?? "Action", tint: AppTheme.success)
                    }

                    HStack(spacing: 8) {
                        Image(systemName: "arrow.up.right")
                        Text(NSLocalizedString("open.details", comment: "Open details button title"))
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppTheme.backgroundBase)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        Capsule()
                            .fill(AppTheme.textPrimary)
                    )
                }
                .padding(24)
            }
        }
        .buttonStyle(.plain)
    }
}

struct HorizontalGamesRow: View {
    let items: [HomeGame]
    let onSelect: (HomeGame) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(alignment: .top, spacing: 20) {
                ForEach(items) { item in
                    Button {
                        onSelect(item)
                    } label: {
                        GameCard(game: item)
                            .frame(width: 220, height: 336, alignment: .top)
                            .fixedSize(horizontal: true, vertical: false)
                    }
                    .buttonStyle(.plain)
                }
            }
            .scrollTargetLayout()
            .padding(.horizontal, 20)
        }
        .scrollTargetBehavior(.viewAligned)
        .frame(height: 346)
    }
}

struct GameCard: View {
    let game: HomeGame

    var body: some View {
        AppSurface(cornerRadius: 24, padding: 12, fill: AppTheme.surface) {
            ZStack(alignment: .topLeading) {
                GameArtworkView(game: game)
                    .frame(maxWidth: .infinity)
                    .frame(height: 226)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))

                AppTag(title: game.genres.first ?? game.platform, tint: AppTheme.textPrimary)
                    .padding(10)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(game.title)
                    .font(.headline.weight(.bold))
                    .foregroundStyle(AppTheme.textPrimary)
                    .lineLimit(1)

                Text(game.shortDescription)
                    .font(.caption)
                    .foregroundStyle(AppTheme.textSecondary)
                    .lineLimit(2)

                HStack {
                    Text("\(game.rating, specifier: "%.1f")")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(AppTheme.accent)

                    Text("•")
                        .foregroundStyle(AppTheme.textTertiary)

                    Text(game.platform)
                        .font(.caption)
                        .foregroundStyle(AppTheme.textSecondary)
                        .lineLimit(1)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

private struct HomeSectionListView: View {
    let section: HomeSection
    let onSelect: (HomeGame) -> Void

    var body: some View {
        NavigationStack {
            AppBackground {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        AppScreenHeader(
                            eyebrow: "Collection",
                            title: section.title,
                            subtitle: section.subtitle
                        )
                        .padding(.horizontal, 20)
                        .padding(.top, 12)

                        VStack(spacing: 14) {
                            ForEach(section.items) { game in
                                Button {
                                    onSelect(game)
                                } label: {
                                    AppSurface(cornerRadius: 22, padding: 14, fill: AppTheme.surface) {
                                        HStack(spacing: 14) {
                                            GameArtworkView(game: game)
                                                .frame(width: 82, height: 82)
                                                .clipped()
                                                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

                                            VStack(alignment: .leading, spacing: 6) {
                                                Text(game.title)
                                                    .font(.headline.weight(.bold))
                                                    .foregroundStyle(AppTheme.textPrimary)

                                                Text(game.shortDescription)
                                                    .font(.subheadline)
                                                    .foregroundStyle(AppTheme.textSecondary)
                                                    .lineLimit(2)

                                                HStack(spacing: 8) {
                                                    AppTag(title: "\(formatRating(game.rating)) rating")
                                                    AppTag(title: game.genres.first ?? game.platform, tint: AppTheme.success)
                                                }
                                            }

                                            Spacer(minLength: 0)

                                            Image(systemName: "chevron.right")
                                                .foregroundStyle(AppTheme.textTertiary)
                                        }
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 32)
                    }
                }
            }
            .navigationTitle(section.title)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct GameDetailsSheet: View {
    let game: HomeGame
    let isFavorite: Bool
    let onFavoriteToggle: () -> Void
    let onMarkPlayed: () -> Void

    var body: some View {
        AppBackground {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    ZStack(alignment: .bottomLeading) {
                        GameArtworkView(game: game)
                            .frame(height: 260)
                            .clipped()
                            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                            .overlay(
                                AppTheme.heroGradient
                                    .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 28, style: .continuous)
                                    .stroke(AppTheme.strongStroke, lineWidth: 1)
                            )

                        VStack(alignment: .leading, spacing: 8) {
                            AppTag(title: game.genres.first ?? "Featured", systemImage: "gamecontroller.fill")

                            Text(game.title)
                                .font(.system(size: 30, weight: .bold, design: .rounded))
                                .foregroundStyle(AppTheme.textPrimary)

                            Text("\(game.platform) • \(game.releaseYear)")
                                .font(.subheadline)
                                .foregroundStyle(AppTheme.textSecondary)
                        }
                        .padding(22)
                    }

                    AppSurface(fill: AppTheme.surfaceRaised) {
                        Text(game.shortDescription)
                            .font(.body)
                            .foregroundStyle(AppTheme.textPrimary.opacity(0.92))

                        HStack(spacing: 12) {
                            DetailPill(title: "\(game.hoursPlayed)h", subtitle: "Tracked")
                            DetailPill(title: formatRating(game.rating), subtitle: "Rating", tint: AppTheme.accent)
                            DetailPill(title: "\(game.genres.count)", subtitle: "Genres", tint: AppTheme.success)
                        }

                        VStack(alignment: .leading, spacing: 10) {
                            Text("Genres")
                                .font(.headline.weight(.semibold))
                                .foregroundStyle(AppTheme.textPrimary)

                            FlexibleTagRow(tags: game.genres)
                        }
                    }

                    HStack(spacing: 12) {
                        Button(action: onMarkPlayed) {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                Text(NSLocalizedString("mark.as.played", comment: "Mark as Played button title"))
                            }
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(AppTheme.backgroundBase)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .fill(AppTheme.textPrimary)
                            )
                        }
                        .buttonStyle(.plain)

                        Button(action: onFavoriteToggle) {
                            Image(systemName: isFavorite ? "heart.fill" : "heart")
                                .font(.title3.weight(.bold))
                                .foregroundStyle(isFavorite ? AppTheme.danger : AppTheme.textPrimary)
                                .frame(width: 58, height: 54)
                                .background(
                                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                                        .fill(AppTheme.surfaceRaised)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                                        .stroke(AppTheme.stroke, lineWidth: 1)
                                )
                        }
                        .buttonStyle(.plain)
                    }

                    Spacer(minLength: 12)
                }
                .padding(20)
                .padding(.bottom, 24)
            }
        }
    }
}

private struct DetailPill: View {
    let title: String
    let subtitle: String
    var tint: Color = AppTheme.textPrimary

    var body: some View {
        VStack(spacing: 5) {
            Text(title)
                .font(.headline.weight(.bold))
                .foregroundStyle(tint)

            Text(subtitle)
                .font(.caption)
                .foregroundStyle(AppTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(AppTheme.surfaceMuted)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(AppTheme.stroke, lineWidth: 1)
        )
    }
}

struct FlexibleTagRow: View {
    let tags: [String]

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 92), spacing: 8)], alignment: .leading, spacing: 8) {
            ForEach(tags, id: \.self) { tag in
                AppTag(title: tag, tint: AppTheme.textPrimary)
            }
        }
    }
}

private func formatRating(_ rating: Double) -> String {
    String(format: "%.1f", rating)
}

#Preview {
    HomeView()
        .environmentObject(AuthViewModel())
}
