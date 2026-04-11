import SwiftUI

struct ActivityLogStatCard: View {
    let value: String
    let label: String

    var body: some View {
        AppMetricBadge(title: label, value: value, emphasize: true)
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
                .foregroundStyle(isSelected ? AppTheme.backgroundBase : AppTheme.textSecondary)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    Capsule()
                        .fill(isSelected ? AppTheme.textPrimary : AppTheme.surfaceMuted)
                )
                .overlay(
                    Capsule()
                        .stroke(isSelected ? AppTheme.textPrimary.opacity(0.2) : AppTheme.stroke, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}

struct ActivityCard: View {
    let gameTitle: String
    let activityText: String
    let timestamp: String
    let imageName: String

    var body: some View {
        AppSurface(cornerRadius: 22, padding: 14, fill: AppTheme.surface) {
            HStack(alignment: .top, spacing: 14) {
                ZStack(alignment: .bottomTrailing) {
                    Image(imageName)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 70, height: 82)
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

                    Circle()
                        .fill(AppTheme.textPrimary)
                        .frame(width: 18, height: 18)
                        .overlay(
                            Circle()
                                .fill(AppTheme.accent)
                                .frame(width: 8, height: 8)
                        )
                        .offset(x: 4, y: 4)
                }

                VStack(alignment: .leading, spacing: 5) {
                    Text(gameTitle)
                        .font(.headline.weight(.bold))
                        .foregroundStyle(AppTheme.textPrimary)
                        .lineLimit(1)

                    Text(activityText)
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.textSecondary)
                        .lineLimit(2)

                    Text(timestamp)
                        .font(.caption)
                        .foregroundStyle(AppTheme.textTertiary)
                }

                Spacer(minLength: 0)
            }
        }
    }
}
