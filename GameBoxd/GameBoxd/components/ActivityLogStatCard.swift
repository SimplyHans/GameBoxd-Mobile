//
//  ActivityLogStatCard.swift
//  GameBoxd
//
//  Compact stat card for Activity Log and Badges screens.
//

import SwiftUI

struct ActivityLogStatCard: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 6) {
            Text(value)
                .font(.title3.weight(.bold))
                .foregroundStyle(.white)
            Text(label)
                .font(.caption.weight(.medium))
                .foregroundStyle(.white.opacity(0.8))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .padding(.horizontal, 8)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color(red: 24/255, green: 28/255, blue: 44/255))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color(red: 0, green: 219/255, blue: 255/255),
                            Color.purple
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
        )
    }
}

struct FilterPill: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(isSelected ? .white : .white.opacity(0.7))
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
        }
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(isSelected ? Color.purple.opacity(0.4) : Color.clear)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(
                    isSelected
                        ? LinearGradient(
                            colors: [Color(red: 0, green: 219/255, blue: 255/255), Color.purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        : LinearGradient(
                            colors: [Color.white.opacity(0.25), Color.white.opacity(0.15)],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                    lineWidth: isSelected ? 2 : 1
                )
        )
        .buttonStyle(.plain)
    }
}

struct ActivityCard: View {
    let gameTitle: String
    let activityText: String
    let timestamp: String
    let imageName: String
    let borderAccent: Color

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(imageName)
                .resizable()
                .scaledToFill()
                .frame(width: 64, height: 64)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(borderAccent.opacity(0.8), lineWidth: 1.5)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(gameTitle)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                Text(activityText)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.9))
                    .lineLimit(2)
                Text(timestamp)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.6))
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Spacer(minLength: 0)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(red: 24/255, green: 28/255, blue: 44/255))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [borderAccent.opacity(0.6), Color.purple.opacity(0.4)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
        )
    }
}
