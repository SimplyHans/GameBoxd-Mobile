import Foundation
import UIKit

enum PlayerActivityCategory: String, CaseIterable, Codable {
    case sessions = "Sessions"
    case favorites = "Favorites"
    case updates = "Updates"
}

struct PlayerProfileDetails: Codable, Equatable {
    var bio: String
    var about: String
    var joinedAt: Date

    static func `default`(for user: User?) -> PlayerProfileDetails {
        let name = user?.username ?? "Player"
        return PlayerProfileDetails(
            bio: "\(name) is building a game library one session at a time.",
            about: "Tracks favorites, recent sessions, and standout games in one place.",
            joinedAt: Date()
        )
    }
}

struct PlayerNotificationItem: Identifiable, Codable, Hashable {
    let id: UUID
    let title: String
    let message: String
    let timestamp: Date
    let systemImage: String
    var isRead: Bool

    var relativeTimestamp: String {
        RelativeDateFormatter.shared.localizedString(for: timestamp, relativeTo: Date())
    }
}

struct PlayerActivityEntry: Identifiable, Codable, Hashable {
    let id: UUID
    let title: String
    let detail: String
    let timestamp: Date
    let category: PlayerActivityCategory
    let gameID: UUID?
    let gameTitle: String?
    let imageName: String?

    var relativeTimestamp: String {
        RelativeDateFormatter.shared.localizedString(for: timestamp, relativeTo: Date())
    }
}

struct PlayerFeedPost: Identifiable, Hashable {
    let id: UUID
    let username: String
    let avatarSystemName: String
    let gameTitle: String
    let imageName: String
    let timestamp: Date
    let caption: String
    let isLiked: Bool
    let likeCount: Int
    let commentCount: Int

    var relativeTimestamp: String {
        RelativeDateFormatter.shared.localizedString(for: timestamp, relativeTo: Date())
    }
}

struct PlayerBadgeProgress: Identifiable, Hashable {
    let id: String
    let title: String
    let systemImage: String
    let subtitle: String
    let current: Int
    let goal: Int
    let isUnlocked: Bool

    var progressText: String {
        "\(min(current, goal))/\(goal)"
    }
}

private struct StoredAppState: Codable {
    var profile: PlayerProfileDetails
    var notifications: [PlayerNotificationItem]
    var activities: [PlayerActivityEntry]
    var likedFeedPostIDs: [UUID]
}

protocol AppStateServicing {
    func profile(for user: User?) -> PlayerProfileDetails
    func updateProfile(bio: String, about: String, for user: User?)
    func recordProfileUpdated(for user: User?)
    func ensureStateExists(for user: User?)
    func recordLogin(for user: User?)
    func recordLogout(for user: User?)
    func recordPlayed(game: HomeGame, for user: User?)
    func recordFavoriteChange(game: HomeGame, isFavorite: Bool, for user: User?)
    func notifications(for user: User?) -> [PlayerNotificationItem]
    func unreadNotificationCount(for user: User?) -> Int
    func markAllNotificationsRead(for user: User?)
    func activities(for user: User?) -> [PlayerActivityEntry]
    func feedPosts(for user: User?, catalog: [HomeGame]) -> [PlayerFeedPost]
    func toggleLike(postID: UUID, for user: User?, catalog: [HomeGame]) -> [PlayerFeedPost]
    func badges(for user: User?, catalog: [HomeGame], favoriteIDs: Set<UUID>, recentIDs: [UUID]) -> [PlayerBadgeProgress]
    // MARK: - Avatar
    func saveAvatar(_ image: UIImage, for user: User?)
    func loadAvatar(for user: User?) -> UIImage?
}

extension Notification.Name {
    static let appStateDidChange = Notification.Name("AppStateDidChange")
}

final class AppStateService: AppStateServicing {
    static let shared = AppStateService()

    private let defaults = UserDefaults.standard
    private let stateLock = NSLock()
    private let maxNotifications = 25
    private let maxActivities = 50

    private init() {}

    func profile(for user: User?) -> PlayerProfileDetails {
        loadState(for: user, createIfNeeded: true).profile
    }

    func updateProfile(bio: String, about: String, for user: User?) {
        var state = loadState(for: user, createIfNeeded: true)
        let trimmedBio = bio.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedAbout = about.trimmingCharacters(in: .whitespacesAndNewlines)

        state.profile.bio = trimmedBio.isEmpty ? PlayerProfileDetails.default(for: user).bio : trimmedBio
        state.profile.about = trimmedAbout.isEmpty ? PlayerProfileDetails.default(for: user).about : trimmedAbout
        saveState(state, for: user)
    }

    func recordProfileUpdated(for user: User?) {
        guard let user else { return }

        appendActivity(
            PlayerActivityEntry(
                id: UUID(),
                title: "Profile updated",
                detail: "Refreshed \(user.username)'s bio and profile details.",
                timestamp: Date(),
                category: .updates,
                gameID: nil,
                gameTitle: nil,
                imageName: nil
            ),
            notification: PlayerNotificationItem(
                id: UUID(),
                title: "Profile saved",
                message: "Your profile changes are now live across the app.",
                timestamp: Date(),
                systemImage: "person.crop.circle.badge.checkmark",
                isRead: false
            ),
            for: user
        )
    }

    func ensureStateExists(for user: User?) {
        _ = loadState(for: user, createIfNeeded: true)
    }

    func recordLogin(for user: User?) {
        guard let user else { return }

        appendActivity(
            PlayerActivityEntry(
                id: UUID(),
                title: "Welcome back",
                detail: "\(user.username) signed in and reopened the dashboard.",
                timestamp: Date(),
                category: .updates,
                gameID: nil,
                gameTitle: nil,
                imageName: nil
            ),
            notification: PlayerNotificationItem(
                id: UUID(),
                title: "Welcome back",
                message: "Your library, feed, and activity are ready.",
                timestamp: Date(),
                systemImage: "sparkles",
                isRead: false
            ),
            for: user
        )
    }

    func recordLogout(for user: User?) {
        guard let user else { return }

        appendActivity(
            PlayerActivityEntry(
                id: UUID(),
                title: "Session ended",
                detail: "\(user.username) signed out of the app.",
                timestamp: Date(),
                category: .updates,
                gameID: nil,
                gameTitle: nil,
                imageName: nil
            ),
            notification: nil,
            for: user
        )
    }

    func recordPlayed(game: HomeGame, for user: User?) {
        guard let user else { return }

        appendActivity(
            PlayerActivityEntry(
                id: UUID(),
                title: game.title,
                detail: "Logged a fresh session in \(game.title).",
                timestamp: Date(),
                category: .sessions,
                gameID: game.id,
                gameTitle: game.title,
                imageName: game.imageName
            ),
            notification: PlayerNotificationItem(
                id: UUID(),
                title: "Session saved",
                message: "\(game.title) was added to your recent activity.",
                timestamp: Date(),
                systemImage: "gamecontroller.fill",
                isRead: false
            ),
            for: user
        )
    }

    func recordFavoriteChange(game: HomeGame, isFavorite: Bool, for user: User?) {
        guard let user else { return }

        let detail = isFavorite
            ? "Added \(game.title) to favorites."
            : "Removed \(game.title) from favorites."
        let title = isFavorite ? "Favorite added" : "Favorite updated"
        let notificationMessage = isFavorite
            ? "\(game.title) will now shape your recommendations."
            : "\(game.title) was removed from your favorites."

        appendActivity(
            PlayerActivityEntry(
                id: UUID(),
                title: game.title,
                detail: detail,
                timestamp: Date(),
                category: .favorites,
                gameID: game.id,
                gameTitle: game.title,
                imageName: game.imageName
            ),
            notification: PlayerNotificationItem(
                id: UUID(),
                title: title,
                message: notificationMessage,
                timestamp: Date(),
                systemImage: isFavorite ? "heart.fill" : "heart.slash.fill",
                isRead: false
            ),
            for: user
        )
    }

    func notifications(for user: User?) -> [PlayerNotificationItem] {
        loadState(for: user, createIfNeeded: true)
            .notifications
            .sorted { $0.timestamp > $1.timestamp }
    }

    func unreadNotificationCount(for user: User?) -> Int {
        notifications(for: user).filter { !$0.isRead }.count
    }

    func markAllNotificationsRead(for user: User?) {
        var state = loadState(for: user, createIfNeeded: true)
        guard state.notifications.contains(where: { !$0.isRead }) else { return }
        state.notifications = state.notifications.map { item in
            var updated = item
            updated.isRead = true
            return updated
        }
        saveState(state, for: user)
    }

    func activities(for user: User?) -> [PlayerActivityEntry] {
        loadState(for: user, createIfNeeded: true)
            .activities
            .sorted { $0.timestamp > $1.timestamp }
    }

    func feedPosts(for user: User?, catalog: [HomeGame]) -> [PlayerFeedPost] {
        let state = loadState(for: user, createIfNeeded: true)
        let likedIDs = Set(state.likedFeedPostIDs)
        let userPosts = buildUserFeedPosts(from: state.activities, user: user, likedIDs: likedIDs)
        let communityPosts = buildCommunityFeedPosts(from: catalog, likedIDs: likedIDs)

        return (userPosts + communityPosts)
            .sorted { $0.timestamp > $1.timestamp }
    }

    func toggleLike(postID: UUID, for user: User?, catalog: [HomeGame]) -> [PlayerFeedPost] {
        var state = loadState(for: user, createIfNeeded: true)

        if let index = state.likedFeedPostIDs.firstIndex(of: postID) {
            state.likedFeedPostIDs.remove(at: index)
        } else {
            state.likedFeedPostIDs.insert(postID, at: 0)
        }

        saveState(state, for: user)
        return feedPosts(for: user, catalog: catalog)
    }

    func badges(for user: User?, catalog: [HomeGame], favoriteIDs: Set<UUID>, recentIDs: [UUID]) -> [PlayerBadgeProgress] {
        let state = loadState(for: user, createIfNeeded: true)
        let sessionCount = state.activities.filter { $0.category == .sessions }.count
        let favoriteCount = favoriteIDs.count
        let updateCount = state.activities.filter { $0.category == .updates }.count
        let trendingEngagement = catalog.filter { $0.isTrending && (favoriteIDs.contains($0.id) || recentIDs.contains($0.id)) }.count
        return [
            PlayerBadgeProgress(id: "sessions", title: "Session Starter", systemImage: "gamecontroller.fill", subtitle: "Log 3 play sessions.", current: sessionCount, goal: 3, isUnlocked: sessionCount >= 3),
            PlayerBadgeProgress(id: "favorites", title: "Collector", systemImage: "heart.fill", subtitle: "Save 3 favorite games.", current: favoriteCount, goal: 3, isUnlocked: favoriteCount >= 3),
            PlayerBadgeProgress(id: "profile", title: "Identity", systemImage: "person.crop.circle.fill", subtitle: "Update your profile twice.", current: updateCount, goal: 2, isUnlocked: updateCount >= 2),
            PlayerBadgeProgress(id: "recent", title: "Momentum", systemImage: "bolt.fill", subtitle: "Build a recent list of 4 games.", current: recentIDs.count, goal: 4, isUnlocked: recentIDs.count >= 4),
            PlayerBadgeProgress(id: "activity", title: "Consistency", systemImage: "flame.fill", subtitle: "Create 8 total activity entries.", current: state.activities.count, goal: 8, isUnlocked: state.activities.count >= 8),
            PlayerBadgeProgress(id: "trending", title: "Trendsetter", systemImage: "sparkles", subtitle: "Interact with 2 trending games.", current: trendingEngagement, goal: 2, isUnlocked: trendingEngagement >= 2)
        ]
        .sorted { lhs, rhs in
            if lhs.isUnlocked == rhs.isUnlocked {
                return lhs.title < rhs.title
            }
            return lhs.isUnlocked && !rhs.isUnlocked
        }
    }

    // MARK: - Avatar

    func saveAvatar(_ image: UIImage, for user: User?) {
        guard let data = image.jpegData(compressionQuality: 0.8) else { return }
        try? data.write(to: avatarURL(for: user))
    }

    func loadAvatar(for user: User?) -> UIImage? {
        guard let data = try? Data(contentsOf: avatarURL(for: user)) else { return nil }
        return UIImage(data: data)
    }

    private func avatarURL(for user: User?) -> URL {
        let uid = user?.id.uuidString ?? "guest"
        return FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("avatar_\(uid).jpg")
    }

    // MARK: - Private helpers

    private func appendActivity(_ activity: PlayerActivityEntry, notification: PlayerNotificationItem?, for user: User?) {
        var state = loadState(for: user, createIfNeeded: true)
        state.activities.insert(activity, at: 0)
        state.activities = Array(state.activities.prefix(maxActivities))

        if let notification {
            state.notifications.insert(notification, at: 0)
            state.notifications = Array(state.notifications.prefix(maxNotifications))
        }

        saveState(state, for: user)
    }

    private func buildUserFeedPosts(from activities: [PlayerActivityEntry], user: User?, likedIDs: Set<UUID>) -> [PlayerFeedPost] {
        let username = user?.username ?? "Player"

        return activities.prefix(6).map { entry in
            let baseLikeCount = max(8, 20 - activities.firstIndex(of: entry, default: 0))
            let postID = entry.id
            return PlayerFeedPost(
                id: postID,
                username: username,
                avatarSystemName: "person.fill",
                gameTitle: entry.gameTitle ?? "GameBoxd",
                imageName: entry.imageName ?? "Image",
                timestamp: entry.timestamp,
                caption: feedCaption(for: entry, username: username),
                isLiked: likedIDs.contains(postID),
                likeCount: baseLikeCount + (likedIDs.contains(postID) ? 1 : 0),
                commentCount: max(2, baseLikeCount / 4)
            )
        }
    }

    private func buildCommunityFeedPosts(from catalog: [HomeGame], likedIDs: Set<UUID>) -> [PlayerFeedPost] {
        let seeds = communityPostSeeds(using: catalog)
        return seeds.map { seed in
            PlayerFeedPost(
                id: seed.id,
                username: seed.username,
                avatarSystemName: seed.avatarSystemName,
                gameTitle: seed.game.title,
                imageName: seed.game.imageName,
                timestamp: seed.timestamp,
                caption: seed.caption,
                isLiked: likedIDs.contains(seed.id),
                likeCount: seed.baseLikeCount + (likedIDs.contains(seed.id) ? 1 : 0),
                commentCount: seed.commentCount
            )
        }
    }

    private func communityPostSeeds(using catalog: [HomeGame]) -> [CommunitySeedPost] {
        let safeCatalog = catalog.isEmpty ? HomeService.seedCatalog : catalog
        let ranked = safeCatalog.sorted { lhs, rhs in
            if lhs.isTrending == rhs.isTrending {
                return lhs.rating > rhs.rating
            }
            return lhs.isTrending && !rhs.isTrending
        }

        let first = ranked[safeCatalog.indices.contains(0) ? 0 : safeCatalog.startIndex]
        let second = ranked.count > 1 ? ranked[1] : first
        let third = ranked.count > 2 ? ranked[2] : second

        return [
            CommunitySeedPost(
                id: UUID(uuidString: "0EADCA11-0000-4000-8000-000000000001")!,
                username: "Maya",
                avatarSystemName: "person.crop.circle.fill",
                game: first,
                timestamp: Date().addingTimeInterval(-900),
                caption: "Queueing back into \(first.title) tonight. The pace still feels incredible.",
                baseLikeCount: 126,
                commentCount: 14
            ),
            CommunitySeedPost(
                id: UUID(uuidString: "0EADCA11-0000-4000-8000-000000000002")!,
                username: "Alex",
                avatarSystemName: "person.circle.fill",
                game: second,
                timestamp: Date().addingTimeInterval(-3600),
                caption: "Still one of the easiest games to recommend this week: \(second.title).",
                baseLikeCount: 89,
                commentCount: 8
            ),
            CommunitySeedPost(
                id: UUID(uuidString: "0EADCA11-0000-4000-8000-000000000003")!,
                username: "Jordan",
                avatarSystemName: "person.fill",
                game: third,
                timestamp: Date().addingTimeInterval(-7200),
                caption: "New session notes are up for \(third.title). Curious who else is still grinding it.",
                baseLikeCount: 64,
                commentCount: 5
            )
        ]
    }

    private func feedCaption(for entry: PlayerActivityEntry, username: String) -> String {
        switch entry.category {
        case .sessions:
            return "\(username) just logged time in \(entry.gameTitle ?? "a game")."
        case .favorites:
            return entry.detail
        case .updates:
            return entry.detail
        }
    }

    private func loadState(for user: User?, createIfNeeded: Bool) -> StoredAppState {
        let key = storageKey(for: user)

        if let data = defaults.data(forKey: key),
           let state = try? JSONDecoder().decode(StoredAppState.self, from: data) {
            return state
        }

        let freshState = StoredAppState(
            profile: PlayerProfileDetails.default(for: user),
            notifications: [
                PlayerNotificationItem(
                    id: UUID(),
                    title: "Welcome to GameBoxd",
                    message: "Start marking favorites and played games to build your dashboard.",
                    timestamp: Date(),
                    systemImage: "sparkles",
                    isRead: false
                )
            ],
            activities: [],
            likedFeedPostIDs: []
        )

        if createIfNeeded {
            saveState(freshState, for: user)
        }

        return freshState
    }

    private func saveState(_ state: StoredAppState, for user: User?) {
        guard let encoded = try? JSONEncoder().encode(state) else { return }

        stateLock.lock()
        defaults.set(encoded, forKey: storageKey(for: user))
        stateLock.unlock()

        NotificationCenter.default.post(name: .appStateDidChange, object: user)
    }

    private func storageKey(for user: User?) -> String {
        "app.state.\(user?.id.uuidString ?? "guest")"
    }
}

private struct CommunitySeedPost {
    let id: UUID
    let username: String
    let avatarSystemName: String
    let game: HomeGame
    let timestamp: Date
    let caption: String
    let baseLikeCount: Int
    let commentCount: Int
}

private enum RelativeDateFormatter {
    static let shared: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter
    }()
}

private extension Array where Element: Equatable {
    func firstIndex(of element: Element, default defaultValue: Int) -> Int {
        firstIndex(of: element) ?? defaultValue
    }
}
