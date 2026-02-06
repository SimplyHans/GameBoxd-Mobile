//
//  LogView.swift
//  GameBoxd
//
//  Created by Hussein on 2026-02-05.
//

import Foundation
import SwiftUI

struct GameLog: Identifiable {
    let id = UUID()
    let title: String
    let imageName: String
    let hours: Int
    let lastPlayed: String
}

private let sampleRecently: [GameLog] = [
    GameLog(title: "Fortnit", imageName: "Image", hours: 124, lastPlayed: "Yesterday"),
    GameLog(title: "Apex Legends", imageName: "Image", hours: 87, lastPlayed: "2 days ago"),
    GameLog(title: "Valorant", imageName: "Image", hours: 45, lastPlayed: "Last week")
]

private let sampleAllGames: [GameLog] = [
    GameLog(title: "Fortnit", imageName: "Image", hours: 124, lastPlayed: "Yesterday"),
    GameLog(title: "Apex Legends", imageName: "Image", hours: 87, lastPlayed: "2 days ago"),
    GameLog(title: "Valorant", imageName: "Image", hours: 45, lastPlayed: "Last week"),
    GameLog(title: "Overwatch 2", imageName: "Image", hours: 33, lastPlayed: "3 weeks ago"),
    GameLog(title: "Rocket League", imageName: "Image", hours: 72, lastPlayed: "1 month ago")
]

struct LogView: View {
    var body: some View {
        ZStack {
            AppBackground {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        // Header
                        Text("Your Game Log")
                            .foregroundStyle(.white)
                            .font(.largeTitle.weight(.bold))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 16)
                            .padding(.top, 8)

                        // Featured game summary card
                        VStack(alignment: .leading, spacing: 12) {
                            ZStack(alignment: .bottomLeading) {
                                Image("Image")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(height: 160)
                                    .clipped()
                                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                                            .stroke(
                                                LinearGradient(colors: [Color.purple, Color.blue], startPoint: .topLeading, endPoint: .bottomTrailing),
                                                lineWidth: 2
                                            )
                                    )
                            }

                            Text("Fortnit")
                                .font(.title2.weight(.semibold))
                                .foregroundStyle(.white)
                        }
                        .padding(.horizontal, 16)

                        // Stats grid
                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: 12),
                            GridItem(.flexible(), spacing: 12)
                        ], spacing: 12) {
                            StatCard(title: "Hours Played", value: "124 h")
                            StatCard(title: "Sessions", value: "58")
                            StatCard(title: "Last Played", value: "Yesterday")
                            StatCard(title: "Completion", value: "76%")
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 24)
                        
                        // Recently Played
                        Text("Recently Played")
                            .foregroundStyle(.white)
                            .font(.title2.weight(.bold))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 16)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(sampleRecently) { game in
                                    VStack(alignment: .center, spacing: 8) {
                                        Image(game.imageName)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 120, height: 160)
                                            .clipped()
                                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                                    .stroke(
                                                        LinearGradient(colors: [Color.purple, Color.blue], startPoint: .topLeading, endPoint: .bottomTrailing),
                                                        lineWidth: 2
                                                    )
                                            )
                                        Text(game.title)
                                            .font(.subheadline.weight(.semibold))
                                            .foregroundStyle(.white)
                                            .lineLimit(1)
                                    }
                                    .frame(width: 120)
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                        
                        // All Games
                        Text("All Games")
                            .foregroundStyle(.white)
                            .font(.title2.weight(.bold))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 16)

                        VStack(spacing: 12) {
                            ForEach(sampleAllGames) { game in
                                GameRow(game: game)
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
struct StatCard: View {
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.title2.weight(.bold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, alignment: .center)
            Text(title)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.white.opacity(0.8))
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.black.opacity(0.25))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(
                    LinearGradient(colors: [Color.purple, Color.blue], startPoint: .topLeading, endPoint: .bottomTrailing),
                    lineWidth: 2
                )
        )
    }
}

struct GameRow: View {
    let game: GameLog

    var body: some View {
        HStack(spacing: 12) {
            SmallGameCard(imageName: game.imageName)
                .frame(width: 64, height: 64)

            VStack(alignment: .leading, spacing: 4) {
                Text(game.title)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                Text("Hours played: \(game.hours) • Last: \(game.lastPlayed)")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.8))
                    .lineLimit(1)
            }
            Spacer()
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.black.opacity(0.25))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(
                    LinearGradient(colors: [Color.purple, Color.blue], startPoint: .topLeading, endPoint: .bottomTrailing),
                    lineWidth: 1.5
                )
        )
        .frame(minHeight: 88)
    }
}

struct SmallGameCard: View {
    let imageName: String
    var body: some View {
        Image(imageName)
            .resizable()
            .aspectRatio(1, contentMode: .fill)
            .clipped()
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(
                        LinearGradient(colors: [Color.purple, Color.blue], startPoint: .topLeading, endPoint: .bottomTrailing),
                        lineWidth: 1
                    )
            )
    }
}

#Preview {
    LogView()
}
