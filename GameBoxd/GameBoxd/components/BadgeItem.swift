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
                            .stroke(AppTheme.stroke, lineWidth: 1)
                    )
                    .shadow(color: gradientColors.first?.opacity(0.45) ?? .clear, radius: 10, x: 0, y: 4)

                Image(systemName: systemImage)
                    .font(.system(size: 24))
                    .foregroundStyle(.white)
            }

            Text(title)
                .font(.caption.weight(.medium))
                .foregroundStyle(AppTheme.textPrimary.opacity(0.9))
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
                    .fill(AppTheme.surfaceMuted)
                    .frame(width: 64, height: 64)
                    .overlay(
                        Circle()
                            .stroke(AppTheme.stroke, lineWidth: 1)
                    )

                Image(systemName: "lock.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(AppTheme.textTertiary)
            }
            .opacity(0.7)

            Text("???")
                .font(.caption.weight(.medium))
                .foregroundStyle(AppTheme.textTertiary)
        }
        .frame(width: 80)
    }
}
