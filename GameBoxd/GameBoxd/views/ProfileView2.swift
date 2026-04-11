import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var authVM: AuthViewModel
    @State private var bio = ""
    @State private var about = ""
    @State private var recentGames: [HomeGame] = []
    @State private var favoriteGames: [HomeGame] = []
    @State private var libraryCount = 0
    @State private var totalHours = 0
    @State private var favoriteCount = 0
    @State private var selectedGame: HomeGame?

    private let service: HomeServicing = HomeService.shared
    private let appStateService: AppStateServicing = AppStateService.shared

    private var username: String {
        authVM.currentUser?.username ?? "Player"
    }

    private var topGenres: [String] {
        let allGenres = service.allGames().flatMap(\.genres)
        let counts = Dictionary(allGenres.map { ($0, 1) }, uniquingKeysWith: +)
        return counts
            .sorted { lhs, rhs in
                if lhs.value == rhs.value {
                    return lhs.key < rhs.key
                }
                return lhs.value > rhs.value
            }
            .prefix(4)
            .map(\.key)
    }

    var body: some View {
        NavigationStack {
            AppBackground {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 22) {
                        AppScreenHeader(
                            eyebrow: "Profile",
                            title: username,
                            subtitle: "Your gaming identity, stats, and latest sessions."
                        )
                        .padding(.horizontal, 20)
                        .padding(.top, 12)

                        heroProfileCard
                            .padding(.horizontal, 20)

                        statsGrid
                            .padding(.horizontal, 20)

                        aboutSection
                            .padding(.horizontal, 20)

                        if !recentGames.isEmpty {
                            recentSection
                        }

                        if !favoriteGames.isEmpty {
                            favoriteSection
                        }

                        stylesSection
                            .padding(.horizontal, 20)
                    }
                    .padding(.bottom, 32)
                }
            }
            .task {
                await refreshProfileData(forceRemoteSync: false)
            }
            .onReceive(NotificationCenter.default.publisher(for: .homeServiceCatalogDidChange)) { _ in
                Task {
                    await refreshProfileData(forceRemoteSync: false)
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .homeServiceUserStateDidChange)) { _ in
                Task {
                    await refreshProfileData(forceRemoteSync: false)
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .appStateDidChange)) { _ in
                Task {
                    await refreshProfileData(forceRemoteSync: false)
                }
            }
            .sheet(item: $selectedGame) { game in
                GameDetailsSheet(
                    game: game,
                    isFavorite: service.isFavorite(gameID: game.id, for: authVM.currentUser),
                    onFavoriteToggle: {
                        _ = service.toggleFavorite(gameID: game.id, for: authVM.currentUser)
                        Task { await refreshProfileData(forceRemoteSync: false) }
                    },
                    onMarkPlayed: {
                        _ = service.markPlayed(gameID: game.id, for: authVM.currentUser)
                        Task { await refreshProfileData(forceRemoteSync: false) }
                    }
                )
                .presentationDetents([.medium, .large])
            }
        }
    }

    private var heroProfileCard: some View {
        AppSurface(fill: AppTheme.surfaceRaised) {
            HStack(alignment: .center, spacing: 16) {
                ZStack {
                    Circle()
                        .fill(AppTheme.surfaceMuted)
                        .frame(width: 92, height: 92)
                    Circle()
                        .stroke(AppTheme.stroke, lineWidth: 1)
                        .frame(width: 92, height: 92)
                    Image(systemName: "person.fill")
                        .font(.system(size: 34, weight: .semibold))
                        .foregroundStyle(AppTheme.accent)
                }

                VStack(alignment: .leading, spacing: 8) {
                    AppTag(title: "Active player", systemImage: "bolt.fill")

                    Text(username)
                        .font(.title2.weight(.bold))
                        .foregroundStyle(AppTheme.textPrimary)

                    Text(bio)
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.textSecondary)
                        .lineLimit(2)
                }

                Spacer(minLength: 0)
            }

            NavigationLink {
                EditProfileView(
                    currentUsername: username,
                    currentBio: bio,
                    currentAbout: about
                ) { newName, newBio, newAbout in
                    authVM.updateProfile(username: newName, bio: newBio, about: newAbout)
                    bio = appStateService.profile(for: authVM.currentUser).bio
                    about = appStateService.profile(for: authVM.currentUser).about
                }
            } label: {
                HStack {
                    Text("Edit profile")
                    Spacer()
                    Image(systemName: "arrow.right")
                }
                .font(.headline.weight(.semibold))
                .foregroundStyle(AppTheme.backgroundBase)
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(AppTheme.textPrimary)
                )
            }
            .buttonStyle(.plain)
        }
    }

    private var statsGrid: some View {
        HStack(spacing: 12) {
            ProfileStat(title: "Library", value: "\(libraryCount)")
            ProfileStat(title: "Hours", value: compactHoursText(totalHours), emphasize: true)
            ProfileStat(title: "Favorites", value: "\(favoriteCount)")
        }
    }

    private var aboutSection: some View {
        AppSurface {
            AppSectionHeader(title: "About", subtitle: "How this player likes to game.")
            Text(about)
                .foregroundStyle(AppTheme.textSecondary)
                .font(.subheadline)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var recentSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            AppSectionHeader(
                title: "Recently played",
                subtitle: "Quick access to your latest sessions."
            )
            .padding(.horizontal, 20)

            HorizontalGamesRow(items: recentGames) { game in
                selectedGame = game
            }
        }
    }

    private var favoriteSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            AppSectionHeader(
                title: "Favorite picks",
                subtitle: "The titles you keep returning to."
            )
            .padding(.horizontal, 20)

            VStack(spacing: 14) {
                ForEach(favoriteGames.prefix(3)) { game in
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

    private var stylesSection: some View {
        AppSurface(fill: AppTheme.surfaceRaised) {
            AppSectionHeader(
                title: "Gaming style",
                subtitle: "Genres that define this profile."
            )

            FlexibleTagRow(tags: topGenres)
        }
    }

    private func refreshProfileData(forceRemoteSync: Bool) async {
        await HomeService.shared.refreshCatalogIfPossible(force: forceRemoteSync)

        let games = service.allGames()
        let content = service.loadHomeContent(for: authVM.currentUser)
        let profile = appStateService.profile(for: authVM.currentUser)

        recentGames = content.sections.first(where: { $0.id == "recent" })?.items ?? []
        favoriteGames = games.filter { service.isFavorite(gameID: $0.id, for: authVM.currentUser) }
        libraryCount = games.count
        totalHours = games.reduce(0) { $0 + $1.hoursPlayed }
        favoriteCount = favoriteGames.count
        bio = profile.bio
        about = profile.about
    }

    private func compactHoursText(_ hours: Int) -> String {
        if hours >= 1000 {
            return String(format: "%.1fk", Double(hours) / 1000.0)
        }
        return "\(hours)"
    }
}

struct ProfileStat: View {
    let title: String
    let value: String
    var emphasize: Bool = false

    var body: some View {
        AppMetricBadge(title: title, value: value, emphasize: emphasize)
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthViewModel())
}
