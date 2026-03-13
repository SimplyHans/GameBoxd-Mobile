//
//  BadgesView.swift
//  GameBoxd
//
//  Badges Stats / Achievements screen.
//

import SwiftUI

private struct EarnedBadgeData: Identifiable {
    let id = UUID()
    let title: String
    let systemImage: String
    let gradientColors: [Color]
}

private let earnedBadges: [EarnedBadgeData] = [
    EarnedBadgeData(
        title: "Reviewer",
        systemImage: "star.fill",
        gradientColors: [
            Color(red: 255/255, green: 105/255, blue: 180/255),
            Color.purple
        ]
    ),
    EarnedBadgeData(
        title: "Streak",
        systemImage: "flame.fill",
        gradientColors: [
            Color.orange,
            Color(red: 255/255, green: 69/255, blue: 0)
        ]
    ),
    EarnedBadgeData(
        title: "Speedrunner",
        systemImage: "bolt.fill",
        gradientColors: [
            Color(red: 0, green: 219/255, blue: 255/255),
            Color.blue
        ]
    ),
    EarnedBadgeData(
        title: "Collector",
        systemImage: "square.stack.3d.up.fill",
        gradientColors: [
            Color.purple,
            Color(red: 138/255, green: 43/255, blue: 226/255)
        ]
    ),
    EarnedBadgeData(
        title: "Completionist",
        systemImage: "checkmark.circle.fill",
        gradientColors: [
            Color.green,
            Color(red: 0, green: 180/255, blue: 120/255)
        ]
    ),
    EarnedBadgeData(
        title: "Gamer",
        systemImage: "gamecontroller.fill",
        gradientColors: [
            Color(red: 0, green: 219/255, blue: 255/255),
            Color.purple
        ]
    )
]

struct BadgesView: View {
    var body: some View {
        ZStack {
            AppBackground {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Header
                        headerSection

                        // Stats row
                        statsSection

                        // Earned badges
                        earnedBadgesSection

                        // Locked badges
                        lockedBadgesSection
                    }
                    .padding(.bottom, 24)
                }
            }
        }
        .navigationTitle("Badges Stats")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(
            Color(red: 14/255, green: 18/255, blue: 30/255),
            for: .navigationBar
        )
        .toolbarColorScheme(.dark, for: .navigationBar)
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Your Stats")
                .foregroundStyle(.white.opacity(0.8))
                .font(.subheadline)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .padding(.top, 4)
    }

    private var statsSection: some View {
        HStack(spacing: 12) {
            ActivityLogStatCard(value: "243h", label: "Played")
            ActivityLogStatCard(value: "34", label: "Completed")
            ActivityLogStatCard(value: "12", label: "Reviews")
        }
        .padding(.horizontal, 16)
    }

    private var earnedBadgesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Earned Badges")
                .font(.headline.weight(.bold))
                .foregroundStyle(.white)
                .padding(.horizontal, 16)

            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 20),
                GridItem(.flexible(), spacing: 20),
                GridItem(.flexible(), spacing: 20)
            ], spacing: 24) {
                ForEach(earnedBadges) { badge in
                    BadgeItem(
                        title: badge.title,
                        gradientColors: badge.gradientColors,
                        systemImage: badge.systemImage
                    )
                }
            }
            .padding(.horizontal, 16)
        }
    }

    private var lockedBadgesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Locked Badges")
                .font(.headline.weight(.bold))
                .foregroundStyle(.white)
                .padding(.horizontal, 16)

            HStack(spacing: 24) {
                ForEach(0..<3, id: \.self) { _ in
                    LockedBadgeItem()
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 16)
        }
    }
}

#Preview {
    NavigationStack {
        BadgesView()
    }
}
