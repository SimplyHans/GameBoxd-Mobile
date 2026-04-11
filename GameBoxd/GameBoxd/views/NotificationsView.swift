import SwiftUI

struct NotificationsView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel
    @State private var items: [PlayerNotificationItem] = []

    private let appStateService: AppStateServicing = AppStateService.shared

    private var unreadCount: Int {
        items.filter { !$0.isRead }.count
    }

    var body: some View {
        NavigationStack {
            AppBackground {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 22) {
                        AppScreenHeader(
                            eyebrow: "Inbox",
                            title: "Notifications",
                            subtitle: "Alerts now come from your real activity across the app."
                        ) {
                            AppTag(
                                title: unreadCount == 0 ? "All caught up" : "\(unreadCount) unread",
                                systemImage: "bell.fill"
                            )
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 12)

                        if items.isEmpty {
                            AppEmptyState(
                                title: "No notifications yet",
                                message: "As you favorite games, log sessions, and update your profile, alerts will appear here.",
                                systemImage: "bell.slash.fill"
                            )
                            .padding(.horizontal, 20)
                        } else {
                            VStack(spacing: 14) {
                                ForEach(items) { item in
                                    NotificationRow(item: item)
                                        .padding(.horizontal, 20)
                                }
                            }
                        }
                    }
                    .padding(.bottom, 32)
                }
            }
            .task {
                appStateService.markAllNotificationsRead(for: authViewModel.currentUser)
                reloadItems()
            }
            .onReceive(NotificationCenter.default.publisher(for: .appStateDidChange)) { _ in
                reloadItems()
            }
        }
    }

    private func reloadItems() {
        items = appStateService.notifications(for: authViewModel.currentUser)
    }
}

struct NotificationRow: View {
    let item: PlayerNotificationItem

    var body: some View {
        AppSurface(cornerRadius: 22, padding: 14, fill: AppTheme.surface) {
            HStack(alignment: .top, spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(AppTheme.surfaceMuted)
                        .frame(width: 44, height: 44)
                    Image(systemName: item.systemImage)
                        .foregroundStyle(item.isRead ? AppTheme.textSecondary : AppTheme.accent)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(item.title)
                        .foregroundStyle(AppTheme.textPrimary)
                        .font(.headline.weight(.bold))

                    Text(item.message)
                        .foregroundStyle(AppTheme.textSecondary)
                        .font(.subheadline)

                    Text(item.relativeTimestamp)
                        .foregroundStyle(AppTheme.textTertiary)
                        .font(.caption)
                }

                Spacer(minLength: 0)
            }
        }
    }
}

#Preview {
    NotificationsView()
        .environmentObject(AuthViewModel())
}
