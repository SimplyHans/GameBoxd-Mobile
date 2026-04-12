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

private struct ActivityTimelineSection: Identifiable {
    let id: String
    let title: String
    let items: [PlayerActivityEntry]
}

struct LogView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel
    @State private var selectedFilter: ActivityFilter = .all
    @State private var activities: [PlayerActivityEntry] = []
    @State private var searchText = ""

    private let appStateService: AppStateServicing = AppStateService.shared
    private let homeService: HomeServicing = HomeService.shared

    private var filteredActivities: [PlayerActivityEntry] {
        guard let category = selectedFilter.category else {
            return activities
        }
        return activities.filter { $0.category == category }
    }

    private var searchScopedActivities: [PlayerActivityEntry] {
        let base = filteredActivities
        let q = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !q.isEmpty else { return base }
        return base.filter {
            $0.title.lowercased().contains(q) || $0.detail.lowercased().contains(q)
        }
    }

    private var timelineSections: [ActivityTimelineSection] {
        buildTimelineSections(from: searchScopedActivities)
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
                            ActivityLogStatCard(value: "\(sessionCount)", label: "Sessions", systemImage: "gamecontroller.fill")
                            ActivityLogStatCard(value: "\(favoriteCount)", label: "Favorites", systemImage: "heart.fill")
                            ActivityLogStatCard(value: "\(updateCount)", label: "Updates", systemImage: "sparkles")
                        }
                        .padding(.horizontal, 20)

                        AppInputContainer {
                            HStack(spacing: 10) {
                                Image(systemName: "magnifyingglass")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(AppTheme.textTertiary)

                                TextField("Search activity", text: $searchText)
                                    .textInputAutocapitalization(.never)
                                    .autocorrectionDisabled()
                                    .foregroundStyle(AppTheme.textPrimary)

                                if !searchText.isEmpty {
                                    Button {
                                        searchText = ""
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .font(.body.weight(.semibold))
                                            .foregroundStyle(AppTheme.textTertiary)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                        .padding(.horizontal, 20)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(ActivityFilter.allCases, id: \.self) { filter in
                                    FilterPill(
                                        title: filter.rawValue,
                                        count: pillCount(for: filter),
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

                        logContent
                    }
                    .padding(.bottom, 32)
                }
            }
            .navigationBarHidden(true)
            .task {
                reloadActivities()
            }
            .refreshable {
                reloadActivities()
            }
            .onReceive(NotificationCenter.default.publisher(for: .appStateDidChange)) { _ in
                reloadActivities()
            }
            .onReceive(NotificationCenter.default.publisher(for: .homeServiceCatalogDidChange)) { _ in
                reloadActivities()
            }
        }
    }

    @ViewBuilder
    private var logContent: some View {
        if activities.isEmpty {
            AppEmptyState(
                title: "No activity yet",
                message: "Use the app a bit more and your timeline will start filling in.",
                systemImage: "clock.arrow.circlepath"
            )
            .padding(.horizontal, 20)
        } else if filteredActivities.isEmpty {
            AppEmptyState(
                title: "Nothing in this filter",
                message: "Try All or another category — your history is still there.",
                systemImage: "line.3.horizontal.decrease.circle"
            )
            .padding(.horizontal, 20)
        } else if searchScopedActivities.isEmpty {
            AppEmptyState(
                title: "No matches",
                message: "Nothing in this filter matches your search. Clear the search or try different words.",
                systemImage: "magnifyingglass"
            )
            .padding(.horizontal, 20)
        } else {
            VStack(alignment: .leading, spacing: 20) {
                ForEach(Array(timelineSections.enumerated()), id: \.element.id) { index, section in
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(alignment: .firstTextBaseline) {
                            Text(section.title)
                                .font(.subheadline.weight(.bold))
                                .foregroundStyle(AppTheme.textSecondary)

                            Spacer(minLength: 8)

                            Text(section.items.count == 1 ? "1 event" : "\(section.items.count) events")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(AppTheme.textTertiary)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, index == 0 ? 0 : 4)

                        VStack(spacing: 14) {
                            ForEach(section.items) { item in
                                ActivityCard(entry: item, resolvedGame: resolvedGame(for: item))
                                    .padding(.horizontal, 20)
                            }
                        }
                    }
                }
            }
        }
    }

    private func count(for filter: ActivityFilter) -> Int {
        switch filter {
        case .all:
            return activities.count
        case .sessions:
            return sessionCount
        case .favorites:
            return favoriteCount
        case .updates:
            return updateCount
        }
    }

    private func pillCount(for filter: ActivityFilter) -> Int? {
        let value = count(for: filter)
        return value > 0 ? value : nil
    }

    private func resolvedGame(for entry: PlayerActivityEntry) -> HomeGame? {
        guard let id = entry.gameID else { return nil }
        return homeService.allGames().first { $0.id == id }
    }

    private func reloadActivities() {
        activities = appStateService.activities(for: authViewModel.currentUser)
    }

    private func buildTimelineSections(from entries: [PlayerActivityEntry]) -> [ActivityTimelineSection] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: entries) { entry in
            calendar.startOfDay(for: entry.timestamp)
        }
        let sortedDays = grouped.keys.sorted(by: >)

        let dayFormatter = DateFormatter()
        dayFormatter.dateStyle = .medium
        dayFormatter.timeStyle = .none

        return sortedDays.map { day in
            let title: String
            if calendar.isDateInToday(day) {
                title = "Today"
            } else if calendar.isDateInYesterday(day) {
                title = "Yesterday"
            } else {
                title = dayFormatter.string(from: day)
            }

            let id = ISO8601DateFormatter().string(from: day)
            let items = (grouped[day] ?? []).sorted { $0.timestamp > $1.timestamp }
            return ActivityTimelineSection(id: id, title: title, items: items)
        }
    }
}

#Preview {
    LogView()
        .environmentObject(AuthViewModel())
}
