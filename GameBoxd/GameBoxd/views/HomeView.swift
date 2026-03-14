import Foundation
import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel
    @StateObject private var homeViewModel = HomeViewModel()
    @State private var selectedSection: HomeSection?
    @State private var isShowingNotifications = false
    @State private var isShowingSettings = false

    var body: some View {
        NavigationStack {
            AppBackground {
                VStack(spacing: 0) {
                    header
                        .zIndex(1)

                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            if let featuredGame = homeViewModel.featuredGame {
                                FeaturedHero(game: featuredGame) {
                                    homeViewModel.selectedGame = featuredGame
                                }
                                .padding(.horizontal, 16)
                            }

                            ForEach(homeViewModel.sections) { section in
                                VStack(alignment: .leading, spacing: 12) {
                                    SectionHeader(
                                        title: section.title,
                                        subtitle: section.subtitle,
                                        action: { selectedSection = section }
                                    )
                                    .padding(.horizontal, 16)

                                    HorizontalGamesRow(items: section.items) { game in
                                        homeViewModel.selectedGame = game
                                    }
                                }
                            }

                            Spacer(minLength: 24)
                        }
                    }
                }
            }
            .task(id: authViewModel.currentUser?.id) {
                homeViewModel.load(for: authViewModel.currentUser)
            }
            .refreshable {
                await homeViewModel.refresh(for: authViewModel.currentUser)
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
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Welcome back,")
                    .foregroundStyle(.white.opacity(0.8))
                    .font(.subheadline)

                Text(authViewModel.currentUser?.username ?? "Player One")
                    .foregroundStyle(.white)
                    .font(.largeTitle.weight(.bold))

                Text(homeViewModel.isLoading ? "Refreshing your dashboard..." : "Track your games and jump back in.")
                    .foregroundStyle(.white.opacity(0.72))
                    .font(.footnote)
            }

            Spacer()

            HStack(spacing: 12) {
                Button {
                    isShowingNotifications = true
                } label: {
                    HeaderIcon(systemName: "bell", badgeCount: homeViewModel.notificationCount)
                }
                .buttonStyle(.plain)

                Button {
                    isShowingSettings = true
                } label: {
                    HeaderIcon(systemName: "gearshape", badgeCount: 0)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }
}

private struct HeaderIcon: View {
    let systemName: String
    let badgeCount: Int

    var body: some View {
        Circle()
            .fill(Color.black.opacity(0.25))
            .frame(width: 40, height: 40)
            .overlay(
                Image(systemName: systemName)
                    .foregroundStyle(.white)
            )
            .overlay(
                Circle().stroke(
                    LinearGradient(colors: [Color.purple, Color.blue], startPoint: .topLeading, endPoint: .bottomTrailing),
                    lineWidth: 1
                )
            )
            .overlay(alignment: .topTrailing) {
                if badgeCount > 0 {
                    Text("\(badgeCount)")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 2)
                        .background(Capsule().fill(Color.red))
                        .offset(x: 4, y: -4)
                }
            }
    }
}

struct SectionHeader: View {
    let title: String
    let subtitle: String
    let action: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(title)
                    .foregroundStyle(.white)
                    .font(.title2.weight(.bold))

                Spacer()

                Button(action: action) {
                    Text("See all")
                        .foregroundStyle(.white.opacity(0.8))
                        .font(.subheadline.weight(.medium))
                }
                .buttonStyle(.plain)
            }

            Text(subtitle)
                .foregroundStyle(.white.opacity(0.72))
                .font(.footnote)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

struct FeaturedHero: View {
    let game: HomeGame
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack(alignment: .bottomLeading) {
                Image(game.imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 220)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .overlay(
                        LinearGradient(
                            colors: [Color.clear, Color.black.opacity(0.7)],
                            startPoint: .center,
                            endPoint: .bottom
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(
                                LinearGradient(colors: [Color.purple, Color.blue], startPoint: .topLeading, endPoint: .bottomTrailing),
                                lineWidth: 2
                            )
                    )

                VStack(alignment: .leading, spacing: 8) {
                    Text("Featured today")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.75))

                    Text(game.title)
                        .font(.title.weight(.bold))
                        .foregroundStyle(.white)

                    Text("\(game.platform) ΓÇó \(game.releaseYear)")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.85))

                    Text(game.shortDescription)
                        .font(.footnote)
                        .foregroundStyle(.white.opacity(0.85))
                        .lineLimit(2)

                    Text("Open details")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.white.opacity(0.14))
                        .clipShape(Capsule())
                }
                .padding(18)
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
            HStack(spacing: 16) {
                ForEach(items) { item in
                    Button {
                        onSelect(item)
                    } label: {
                        GameCard(game: item)
                            .frame(width: 148)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
        }
    }
}

struct GameCard: View {
    let game: HomeGame

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(game.imageName)
                .resizable()
                .aspectRatio(3 / 4, contentMode: .fill)
                .frame(height: 160)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(
                            LinearGradient(colors: [Color.purple, Color.blue], startPoint: .topLeading, endPoint: .bottomTrailing),
                            lineWidth: 2
                        )
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(game.title)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.white)
                    .lineLimit(1)

                Text("\(game.rating, specifier: "%.1f") Γÿà ΓÇó \(game.platform)")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.75))
                    .lineLimit(1)
            }
        }
    }
}

private struct HomeSectionListView: View {
    let section: HomeSection
    let onSelect: (HomeGame) -> Void

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 12) {
                            Text(section.subtitle)
                                .foregroundStyle(.white.opacity(0.8))
                                .font(.subheadline)
                                .padding(.horizontal, 16)
                                .padding(.top, 8)

                            ForEach(section.items) { game in
                                Button {
                                    onSelect(game)
                                } label: {
                                    HStack(spacing: 12) {
                                        Image(game.imageName)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 68, height: 68)
                                            .clipped()
                                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(game.title)
                                                .font(.headline.weight(.semibold))
                                                .foregroundStyle(.white)

                                            Text(game.shortDescription)
                                                .font(.subheadline)
                                                .foregroundStyle(.white.opacity(0.78))
                                                .lineLimit(2)
                                        }

                                        Spacer()
                                    }
                                    .padding(12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                                            .fill(Color.black.opacity(0.25))
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                                            .stroke(
                                                LinearGradient(colors: [Color.purple, Color.blue], startPoint: .topLeading, endPoint: .bottomTrailing),
                                                lineWidth: 1.5
                                            )
                                    )
                                }
                                .buttonStyle(.plain)
                                .padding(.horizontal, 16)
                            }
                        }
                        .padding(.bottom, 24)
                    }
                }
            }
            .navigationTitle(section.title)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

private struct GameDetailsSheet: View {
    let game: HomeGame
    let isFavorite: Bool
    let onFavoriteToggle: () -> Void
    let onMarkPlayed: () -> Void

    var body: some View {
        ZStack {
            AppBackground {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Image(game.imageName)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 220)
                            .clipped()
                            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .stroke(
                                        LinearGradient(colors: [Color.purple, Color.blue], startPoint: .topLeading, endPoint: .bottomTrailing),
                                        lineWidth: 2
                                    )
                            )

                        VStack(alignment: .leading, spacing: 8) {
                            Text(game.title)
                                .font(.largeTitle.weight(.bold))
                                .foregroundStyle(.white)

                            Text("\(game.platform) ΓÇó \(game.releaseYear) ΓÇó \(game.rating, specifier: "%.1f") Γÿà")
                                .font(.subheadline)
                                .foregroundStyle(.white.opacity(0.75))

                            Text(game.shortDescription)
                                .font(.body)
                                .foregroundStyle(.white.opacity(0.9))
                        }

                        HStack(spacing: 12) {
                            DetailPill(title: "\(game.hoursPlayed) h", subtitle: "Tracked")
                            DetailPill(title: "\(game.genres.count)", subtitle: "Genres")
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Genres")
                                .font(.headline.weight(.semibold))
                                .foregroundStyle(.white)

                            FlexibleTagRow(tags: game.genres)
                        }

                        HStack(spacing: 12) {
                            Button(action: onMarkPlayed) {
                                Text("Mark as Played")
                                    .font(.headline)
                                    .foregroundStyle(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                                            .fill(Color.black.opacity(0.25))
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                                            .stroke(
                                                LinearGradient(colors: [Color.purple, Color.blue], startPoint: .topLeading, endPoint: .bottomTrailing),
                                                lineWidth: 1.5
                                            )
                                    )
                            }
                            .buttonStyle(.plain)

                            Button(action: onFavoriteToggle) {
                                Image(systemName: isFavorite ? "heart.fill" : "heart")
                                    .font(.title3.weight(.bold))
                                    .foregroundStyle(isFavorite ? .red : .white)
                                    .frame(width: 52, height: 52)
                                    .background(
                                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                                            .fill(Color.black.opacity(0.25))
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                                            .stroke(
                                                LinearGradient(colors: [Color.purple, Color.blue], startPoint: .topLeading, endPoint: .bottomTrailing),
                                                lineWidth: 1.5
                                            )
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(16)
                    .padding(.bottom, 24)
                }
            }
        }
    }
}

private struct DetailPill: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(spacing: 6) {
            Text(title)
                .font(.title3.weight(.bold))
                .foregroundStyle(.white)

            Text(subtitle)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.72))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.black.opacity(0.25))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(
                    LinearGradient(colors: [Color.purple, Color.blue], startPoint: .topLeading, endPoint: .bottomTrailing),
                    lineWidth: 1.5
                )
        )
    }
}

private struct FlexibleTagRow: View {
    let tags: [String]

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 90), spacing: 8)], alignment: .leading, spacing: 8) {
            ForEach(tags, id: \.self) { tag in
                Text(tag)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity)
                    .background(
                        Capsule()
                            .fill(Color.black.opacity(0.25))
                    )
                    .overlay(
                        Capsule()
                            .stroke(
                                LinearGradient(colors: [Color.purple, Color.blue], startPoint: .topLeading, endPoint: .bottomTrailing),
                                lineWidth: 1
                            )
                    )
            }
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(AuthViewModel())
}
