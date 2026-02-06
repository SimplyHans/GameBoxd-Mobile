import SwiftUI

struct NotificationsView: View {
    @State private var items: [NotificationItem] = NotificationItem.sample

    var body: some View {
        ZStack {
            AppBackground {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Notifications")
                            .foregroundStyle(.white)
                            .font(.largeTitle.weight(.bold))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 16)
                            .padding(.top, 8)

                        VStack(spacing: 12) {
                            ForEach(items) { item in
                                NotificationRow(item: item)
                                    .padding(.horizontal, 16)
                            }
                        }
                        .padding(.bottom, 24)
                    }
                }
            }
        }
    }
}

struct NotificationItem: Identifiable {
    let id = UUID()
    let title: String
    let message: String
    let timeAgo: String

    static let sample: [NotificationItem] = [
        NotificationItem(title: "Friend Request", message: "Maya sent you a friend request.", timeAgo: "2m"),
        NotificationItem(title: "Match Invite", message: "Alex invited you to a Valorant match.", timeAgo: "15m"),
        NotificationItem(title: "Daily Reward", message: "Your daily reward is ready!", timeAgo: "1h")
    ]
}

struct NotificationRow: View {
    let item: NotificationItem

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Circle()
                .fill(Color.black.opacity(0.25))
                .frame(width: 36, height: 36)
                .overlay(
                    Circle().stroke(
                        LinearGradient(colors: [Color.purple, Color.blue], startPoint: .topLeading, endPoint: .bottomTrailing),
                        lineWidth: 1
                    )
                )
                .overlay(
                    Image(systemName: "bell")
                        .foregroundStyle(.white)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .foregroundStyle(.white)
                    .font(.headline)
                Text(item.message)
                    .foregroundStyle(.white.opacity(0.85))
                    .font(.subheadline)
                Text(item.timeAgo)
                    .foregroundStyle(.white.opacity(0.6))
                    .font(.footnote)
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
}

#Preview {
    NotificationsView()
}
