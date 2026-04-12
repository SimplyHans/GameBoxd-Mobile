import SwiftUI

extension PlayerActivityCategory {
    var logAccentColor: Color {
        switch self {
        case .sessions:
            return AppTheme.accent
        case .favorites:
            return Color(red: 255 / 255, green: 132 / 255, blue: 168 / 255)
        case .updates:
            return AppTheme.accentSecondary
        }
    }

    var logSystemImage: String {
        switch self {
        case .sessions:
            return "gamecontroller.fill"
        case .favorites:
            return "heart.fill"
        case .updates:
            return "sparkles"
        }
    }
}

struct ActivityLogStatCard: View {
    let value: String
    let label: String
    var systemImage: String? = nil

    var body: some View {
        AppMetricBadge(title: label, value: value, emphasize: true, systemImage: systemImage)
    }
}

struct FilterPill: View {
    let title: String
    var count: Int? = nil
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Text(title)
                    .font(.subheadline.weight(.semibold))

                if let count {
                    Text("\(count)")
                        .font(.caption.weight(.bold))
                        .monospacedDigit()
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .background(
                            Capsule()
                                .fill(
                                    isSelected
                                        ? AppTheme.backgroundBase.opacity(0.22)
                                        : AppTheme.surfaceRaised.opacity(0.9)
                                )
                        )
                }
            }
            .foregroundStyle(isSelected ? AppTheme.backgroundBase : AppTheme.textSecondary)
            .padding(.horizontal, 14)
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
    let entry: PlayerActivityEntry
    var resolvedGame: HomeGame?

    var body: some View {
        AppSurface(cornerRadius: 22, padding: 14, fill: AppTheme.surface) {
            HStack(alignment: .top, spacing: 14) {
                thumbnail

                VStack(alignment: .leading, spacing: 6) {
                    HStack(alignment: .center, spacing: 8) {
                        Text(entry.title)
                            .font(.headline.weight(.bold))
                            .foregroundStyle(AppTheme.textPrimary)
                            .lineLimit(2)

                        Spacer(minLength: 4)

                        categoryChip
                    }

                    Text(entry.detail)
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.textSecondary)
                        .lineLimit(3)
                        .fixedSize(horizontal: false, vertical: true)

                    HStack(spacing: 6) {
                        Image(systemName: "clock")
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(AppTheme.textTertiary)

                        Text(entry.relativeTimestamp)
                            .font(.caption)
                            .foregroundStyle(AppTheme.textTertiary)
                    }
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(entry.title). \(entry.detail). \(entry.relativeTimestamp)")
    }

    @ViewBuilder
    private var thumbnail: some View {
        ZStack(alignment: .bottomTrailing) {
            Group {
                if let game = resolvedGame {
                    GameArtworkView(game: game)
                } else if let name = entry.imageName, !name.isEmpty {
                    Image(name)
                        .resizable()
                        .scaledToFill()
                } else {
                    categoryArtworkPlaceholder
                }
            }
            .frame(width: 72, height: 86)
            .clipped()
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(AppTheme.stroke, lineWidth: 1)
            )

            ZStack {
                Circle()
                    .fill(AppTheme.textPrimary)
                    .frame(width: 22, height: 22)

                Image(systemName: entry.category.logSystemImage)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(entry.category.logAccentColor)
            }
            .overlay(
                Circle()
                    .stroke(AppTheme.surface, lineWidth: 2)
            )
            .offset(x: 5, y: 5)
        }
    }

    private var categoryArtworkPlaceholder: some View {
        ZStack {
            LinearGradient(
                colors: [
                    entry.category.logAccentColor.opacity(0.38),
                    AppTheme.surfaceRaised
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Image(systemName: entry.category.logSystemImage)
                .font(.system(size: 28, weight: .semibold))
                .foregroundStyle(entry.category.logAccentColor.opacity(0.95))
                .shadow(color: .black.opacity(0.25), radius: 6, y: 3)
        }
    }

    private var categoryChip: some View {
        HStack(spacing: 4) {
            Image(systemName: entry.category.logSystemImage)
                .font(.caption2.weight(.bold))

            Text(entry.category.rawValue)
                .font(.caption2.weight(.semibold))
        }
        .foregroundStyle(entry.category.logAccentColor)
        .padding(.horizontal, 9)
        .padding(.vertical, 5)
        .background(
            Capsule()
                .fill(entry.category.logAccentColor.opacity(0.16))
        )
        .overlay(
            Capsule()
                .stroke(entry.category.logAccentColor.opacity(0.22), lineWidth: 1)
        )
        .accessibilityHidden(true)
    }
}
