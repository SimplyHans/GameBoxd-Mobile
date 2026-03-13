//
//  LogView.swift
//  GameBoxd
//
//  Activity Log screen – timeline of recent gaming activity.
//

import SwiftUI

enum ActivityFilter: String, CaseIterable {
    case all = "All"
    case progress = "Progress"
    case reviews = "Reviews"
    case done = "Done"
}

struct ActivityItem: Identifiable {
    let id = UUID()
    let gameTitle: String
    let activityText: String
    let timestamp: String
    let category: ActivityFilter
    let imageName: String
}

private let sampleActivities: [ActivityItem] = [
    ActivityItem(
        gameTitle: "Hollow Knight",
        activityText: "Updated progress to 45%",
        timestamp: "2 hours ago",
        category: .progress,
        imageName: "Image"
    ),
    ActivityItem(
        gameTitle: "Wolfenstein 2",
        activityText: "Left a ★★★★ review",
        timestamp: "1 day ago",
        category: .reviews,
        imageName: "Image"
    ),
    ActivityItem(
        gameTitle: "Skyrim",
        activityText: "Completed the game!",
        timestamp: "3 days ago",
        category: .done,
        imageName: "Image"
    )
]

struct LogView: View {
    @State private var selectedFilter: ActivityFilter = .all

    private var filteredActivities: [ActivityItem] {
        if selectedFilter == .all {
            return sampleActivities
        }
        return sampleActivities.filter { $0.category == selectedFilter }
    }

    private var borderAccent: Color {
        Color(red: 0, green: 219/255, blue: 255/255)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            // Header
                            headerSection

                            // Stats row
                            statsSection

                            // Filter tabs
                            filterSection

                            // Activity list
                            activityListSection
                        }
                        .padding(.bottom, 24)
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }

    private var headerSection: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Activity Log")
                    .foregroundStyle(.white)
                    .font(.largeTitle.weight(.bold))
                Text("Your recent activity")
                    .foregroundStyle(.white.opacity(0.8))
                    .font(.subheadline)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            NavigationLink {
                BadgesView()
            } label: {
                HStack(spacing: 6) {
                    Text("Badges")
                    Image(systemName: "star.fill")
                        .font(.caption)
                }
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(Color.purple.opacity(0.35))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [Color(red: 0, green: 219/255, blue: 255/255), Color.purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            lineWidth: 1.5
                        )
                )
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }

    private var statsSection: some View {
        HStack(spacing: 12) {
            ActivityLogStatCard(value: "243h", label: "Played")
            ActivityLogStatCard(value: "34", label: "Completed")
            ActivityLogStatCard(value: "12", label: "Reviews")
        }
        .padding(.horizontal, 16)
    }

    private var filterSection: some View {
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
            .padding(.horizontal, 16)
        }
    }

    private var activityListSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(filteredActivities) { item in
                ActivityCard(
                    gameTitle: item.gameTitle,
                    activityText: item.activityText,
                    timestamp: item.timestamp,
                    imageName: item.imageName,
                    borderAccent: borderAccent
                )
            }
        }
        .padding(.horizontal, 16)
    }
}

#Preview {
    LogView()
}
