import SwiftUI

struct BadgesView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel
    @State private var badges: [PlayerBadgeProgress] = []

    private let appStateService: AppStateServicing = AppStateService.shared
    private let homeService: HomeServicing = HomeService.shared

    private var earnedBadges: [PlayerBadgeProgress] {
        badges.filter(\.isUnlocked)
    }

    private var lockedBadges: [PlayerBadgeProgress] {
        badges.filter { !$0.isUnlocked }
    }

    var body: some View {
        AppBackground {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 22) {
                    AppScreenHeader(
                        eyebrow: "Achievements",
                        title: "Badges",
                        subtitle: "Milestones now unlock from the real actions you take in the app."
                    )
                    .padding(.horizontal, 20)
                    .padding(.top, 12)

                    HStack(spacing: 12) {
                        ActivityLogStatCard(value: "\(earnedBadges.count)", label: "Unlocked")
                        ActivityLogStatCard(value: "\(lockedBadges.count)", label: "Locked")
                        ActivityLogStatCard(value: "\(badges.count)", label: "Total")
                    }
                    .padding(.horizontal, 20)

                    AppSurface(fill: AppTheme.surface) {
                        AppSectionHeader(
                            title: "Earned badges",
                            subtitle: earnedBadges.isEmpty ? "Start interacting with the app to unlock your first badge." : "Badges you have already earned."
                        )

                        if earnedBadges.isEmpty {
                            AppEmptyState(
                                title: "No unlocked badges yet",
                                message: "Favorite games, log sessions, and update your profile to start earning them.",
                                systemImage: "star"
                            )
                        } else {
                            LazyVGrid(
                                columns: [
                                    GridItem(.flexible(), spacing: 20),
                                    GridItem(.flexible(), spacing: 20),
                                    GridItem(.flexible(), spacing: 20)
                                ],
                                spacing: 22
                            ) {
                                ForEach(earnedBadges) { badge in
                                    BadgeItem(
                                        title: badge.title,
                                        gradientColors: badgeColors(for: badge.id),
                                        systemImage: badge.systemImage
                                    )
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)

                    AppSurface(fill: AppTheme.surfaceRaised) {
                        AppSectionHeader(
                            title: "In progress",
                            subtitle: "What you are closest to unlocking next."
                        )

                        VStack(spacing: 12) {
                            ForEach(lockedBadges) { badge in
                                BadgeProgressRow(badge: badge, colors: badgeColors(for: badge.id))
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.bottom, 32)
            }
        }
        .navigationTitle("Badges")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .task {
            reloadBadges()
        }
        .onReceive(NotificationCenter.default.publisher(for: .appStateDidChange)) { _ in
            reloadBadges()
        }
        .onReceive(NotificationCenter.default.publisher(for: .homeServiceUserStateDidChange)) { _ in
            reloadBadges()
        }
    }

    private func reloadBadges() {
        let catalog = homeService.allGames()
        let favorites = Set(catalog.filter { homeService.isFavorite(gameID: $0.id, for: authViewModel.currentUser) }.map(\.id))
        let recentIDs = homeService.loadHomeContent(for: authViewModel.currentUser)
            .sections
            .first(where: { $0.id == "recent" })?
            .items
            .map(\.id) ?? []

        badges = appStateService.badges(
            for: authViewModel.currentUser,
            catalog: catalog,
            favoriteIDs: favorites,
            recentIDs: recentIDs
        )
    }

    private func badgeColors(for badgeID: String) -> [Color] {
        switch badgeID {
        case "sessions":
            return [AppTheme.accent, AppTheme.accentSecondary]
        case "favorites":
            return [Color(red: 255 / 255, green: 104 / 255, blue: 120 / 255), Color(red: 255 / 255, green: 143 / 255, blue: 96 / 255)]
        case "profile":
            return [Color(red: 120 / 255, green: 132 / 255, blue: 255 / 255), Color(red: 76 / 255, green: 201 / 255, blue: 240 / 255)]
        case "recent":
            return [AppTheme.success, Color(red: 78 / 255, green: 193 / 255, blue: 131 / 255)]
        case "activity":
            return [Color.orange, Color(red: 255 / 255, green: 94 / 255, blue: 58 / 255)]
        case "trending":
            return [Color(red: 255 / 255, green: 196 / 255, blue: 87 / 255), AppTheme.accent]
        default:
            return [AppTheme.accent, AppTheme.accentSecondary]
        }
    }
}

private struct BadgeProgressRow: View {
    let badge: PlayerBadgeProgress
    let colors: [Color]

    private var progressRatio: CGFloat {
        guard badge.goal > 0 else { return 0 }
        return min(CGFloat(badge.current) / CGFloat(badge.goal), 1)
    }

    var body: some View {
        AppSurface(cornerRadius: 20, padding: 14, fill: AppTheme.surfaceMuted, shadowOpacity: 0.08) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .frame(width: 46, height: 46)

                    Image(systemName: badge.systemImage)
                        .foregroundStyle(.white)
                }

                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(badge.title)
                            .font(.headline.weight(.bold))
                            .foregroundStyle(AppTheme.textPrimary)

                        Spacer()

                        Text(badge.progressText)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(AppTheme.textSecondary)
                    }

                    Text(badge.subtitle)
                        .font(.caption)
                        .foregroundStyle(AppTheme.textSecondary)

                    GeometryReader { proxy in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(AppTheme.surface)
                            Capsule()
                                .fill(
                                    LinearGradient(colors: colors, startPoint: .leading, endPoint: .trailing)
                                )
                                .frame(width: proxy.size.width * progressRatio)
                        }
                    }
                    .frame(height: 8)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        BadgesView()
            .environmentObject(AuthViewModel())
    }
}
