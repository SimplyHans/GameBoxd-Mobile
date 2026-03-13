//
//  BadgeItem.swift
//  GameBoxd
//
//  Earned badge display for Badges Stats screen.
//

import SwiftUI

struct BadgeItem: View {
    let title: String
    let gradientColors: [Color]
    let systemImage: String

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: gradientColors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 64, height: 64)
                    .overlay(
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0, green: 219/255, blue: 255/255),
                                        Color.purple
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                    )
                    .shadow(color: gradientColors.first?.opacity(0.5) ?? .clear, radius: 8, x: 0, y: 2)

                Image(systemName: systemImage)
                    .font(.system(size: 24))
                    .foregroundStyle(.white)
            }

            Text(title)
                .font(.caption.weight(.medium))
                .foregroundStyle(.white.opacity(0.9))
                .lineLimit(1)
        }
        .frame(width: 80)
    }
}

struct LockedBadgeItem: View {
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(Color.black.opacity(0.3))
                    .frame(width: 64, height: 64)
                    .overlay(
                        Circle()
                            .stroke(
                                Color.white.opacity(0.15),
                                lineWidth: 1.5
                            )
                    )

                Image(systemName: "lock.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(.white.opacity(0.4))
            }
            .opacity(0.7)

            Text("???")
                .font(.caption.weight(.medium))
                .foregroundStyle(.white.opacity(0.5))
        }
        .frame(width: 80)
    }
}
