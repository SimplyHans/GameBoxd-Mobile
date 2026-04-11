import SwiftUI

struct FeedView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel
    @State private var posts: [PlayerFeedPost] = []

    private let appStateService: AppStateServicing = AppStateService.shared
    private let homeService: HomeServicing = HomeService.shared

    var body: some View {
        NavigationStack {
            AppBackground {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 22) {
                        AppScreenHeader(
                            eyebrow: "Community",
                            title: "Feed",
                            subtitle: "Your actions show up here alongside the current community pulse."
                        ) {
                            AppTag(title: "\(posts.count) posts", systemImage: "flame.fill")
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 12)

                        if posts.isEmpty {
                            AppEmptyState(
                                title: "No feed activity yet",
                                message: "Mark a game as played or add favorites to start generating your feed.",
                                systemImage: "bubble.left.and.bubble.right.fill"
                            )
                            .padding(.horizontal, 20)
                        } else {
                            VStack(spacing: 16) {
                                ForEach(posts) { post in
                                    PostCard(post: post) {
                                        posts = appStateService.toggleLike(
                                            postID: post.id,
                                            for: authViewModel.currentUser,
                                            catalog: homeService.allGames()
                                        )
                                    }
                                    .padding(.horizontal, 20)
                                }
                            }
                        }
                    }
                    .padding(.bottom, 32)
                }
            }
            .task {
                reloadPosts()
            }
            .onReceive(NotificationCenter.default.publisher(for: .appStateDidChange)) { _ in
                reloadPosts()
            }
            .onReceive(NotificationCenter.default.publisher(for: .homeServiceCatalogDidChange)) { _ in
                reloadPosts()
            }
        }
    }

    private func reloadPosts() {
        posts = appStateService.feedPosts(for: authViewModel.currentUser, catalog: homeService.allGames())
    }
}

struct PostCard: View {
    let post: PlayerFeedPost
    let onLikeToggle: () -> Void

    var body: some View {
        AppSurface(cornerRadius: 26, padding: 16, fill: AppTheme.surface) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(AppTheme.surfaceMuted)
                        .frame(width: 44, height: 44)
                    Image(systemName: post.avatarSystemName)
                        .foregroundStyle(AppTheme.accent)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(post.username)
                        .font(.headline.weight(.bold))
                        .foregroundStyle(AppTheme.textPrimary)
                    Text(post.relativeTimestamp)
                        .font(.caption)
                        .foregroundStyle(AppTheme.textTertiary)
                }

                Spacer(minLength: 0)

                AppTag(title: post.gameTitle, systemImage: "gamecontroller.fill")
            }

            ZStack(alignment: .bottomLeading) {
                Image(post.imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 220)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                    .overlay(
                        AppTheme.heroGradient
                            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                    )

                Text(post.caption)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(AppTheme.textPrimary)
                    .padding(16)
            }

            HStack(spacing: 12) {
                FeedStatButton(
                    systemImage: post.isLiked ? "heart.fill" : "heart",
                    title: "\(post.likeCount)",
                    tint: post.isLiked ? AppTheme.danger : AppTheme.textPrimary,
                    action: onLikeToggle
                )

                FeedStatButton(
                    systemImage: "bubble.right.fill",
                    title: "\(post.commentCount)",
                    tint: AppTheme.accent,
                    action: { }
                )

                Spacer(minLength: 0)

                Text("Active")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(AppTheme.textSecondary)
            }
        }
    }
}

private struct FeedStatButton: View {
    let systemImage: String
    let title: String
    let tint: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: systemImage)
                Text(title)
            }
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(tint)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(AppTheme.surfaceMuted)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    FeedView()
        .environmentObject(AuthViewModel())
}
