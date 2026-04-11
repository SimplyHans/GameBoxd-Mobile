import SwiftUI

enum ActivityFilter: String, CaseIterable {
    case all = "All"
    case sessions = "Sessions"
    case favorites = "Favorites"
    case updates = "Updates"

    var category: PlayerActivityCategory? {
        switch self {
        case .all:
            return nil
        case .sessions:
            return .sessions
        case .favorites:
            return .favorites
        case .updates:
            return .updates
        }
    }
}

struct LogView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel
    @State private var selectedFilter: ActivityFilter = .all
    @State private var activities: [PlayerActivityEntry] = []

    private let appStateService: AppStateServicing = AppStateService.shared

    private var filteredActivities: [PlayerActivityEntry] {
        guard let category = selectedFilter.category else {
            return activities
        }
        return activities.filter { $0.category == category }
    }

    private var sessionCount: Int {
        activities.filter { $0.category == .sessions }.count
    }

    private var favoriteCount: Int {
        activities.filter { $0.category == .favorites }.count
    }

    private var updateCount: Int {
        activities.filter { $0.category == .updates }.count
    }

    var body: some View {
        NavigationStack {
            AppBackground {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 22) {
                        AppScreenHeader(
                            eyebrow: "History",
                            title: "Activity",
                            subtitle: "A real timeline built from your sessions, favorites, and profile changes."
                        ) {
                            NavigationLink {
                                BadgesView()
                            } label: {
                                AppTag(title: "Badges", systemImage: "star.fill")
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 12)

                        HStack(spacing: 12) {
                            ActivityLogStatCard(value: "\(sessionCount)", label: "Sessions")
                            ActivityLogStatCard(value: "\(favoriteCount)", label: "Favorites")
                            ActivityLogStatCard(value: "\(updateCount)", label: "Updates")
                        }
                        .padding(.horizontal, 20)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(ActivityFilter.allCases, id: \.self) { filter in
                                    FilterPill(
                                        title: filter.rawValue,
                                        isSelected: selectedFilter == filter
                                    ) {
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            selectedFilter = filter
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                        }

                        if filteredActivities.isEmpty {
                            AppEmptyState(
                                title: "No activity yet",
                                message: "Use the app a bit more and your timeline will start filling in.",
                                systemImage: "clock.arrow.circlepath"
                            )
                            .padding(.horizontal, 20)
                        } else {
                            VStack(spacing: 14) {
                                ForEach(filteredActivities) { item in
                                    ActivityCard(
                                        gameTitle: item.title,
                                        activityText: item.detail,
                                        timestamp: item.relativeTimestamp,
                                        imageName: item.imageName ?? "Image"
                                    )
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                    .padding(.bottom, 32)
                }
            }
            .navigationBarHidden(true)
            .task {
                reloadActivities()
            }
            .onReceive(NotificationCenter.default.publisher(for: .appStateDidChange)) { _ in
                reloadActivities()
            }
        }
    }

    private func reloadActivities() {
        activities = appStateService.activities(for: authViewModel.currentUser)
    }
}

#Preview {
    LogView()
        .environmentObject(AuthViewModel())
}
