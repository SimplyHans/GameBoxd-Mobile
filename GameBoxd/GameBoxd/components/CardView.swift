import SwiftUI

enum AppTheme {
    static let backgroundBase = Color(red: 7 / 255, green: 10 / 255, blue: 18 / 255)
    static let backgroundTop = Color(red: 18 / 255, green: 28 / 255, blue: 54 / 255)
    static let backgroundBottom = Color(red: 11 / 255, green: 14 / 255, blue: 24 / 255)
    static let surface = Color(red: 18 / 255, green: 22 / 255, blue: 34 / 255).opacity(0.94)
    static let surfaceRaised = Color(red: 24 / 255, green: 29 / 255, blue: 43 / 255).opacity(0.96)
    static let surfaceMuted = Color(red: 13 / 255, green: 16 / 255, blue: 26 / 255).opacity(0.92)
    static let stroke = Color.white.opacity(0.08)
    static let strongStroke = Color.white.opacity(0.14)
    static let accent = Color(red: 105 / 255, green: 212 / 255, blue: 255 / 255)
    static let accentSecondary = Color(red: 100 / 255, green: 130 / 255, blue: 255 / 255)
    static let success = Color(red: 116 / 255, green: 222 / 255, blue: 167 / 255)
    static let danger = Color(red: 255 / 255, green: 104 / 255, blue: 120 / 255)
    static let textPrimary = Color.white
    static let textSecondary = Color.white.opacity(0.72)
    static let textTertiary = Color.white.opacity(0.52)

    static var accentGradient: LinearGradient {
        LinearGradient(
            colors: [accent, accentSecondary],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var heroGradient: LinearGradient {
        LinearGradient(
            colors: [Color.black.opacity(0.02), Color.black.opacity(0.72)],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

struct CardView<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            content
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(AppTheme.surface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(AppTheme.stroke, lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.22), radius: 18, y: 10)
    }
}

struct AppSurface<Content: View>: View {
    let cornerRadius: CGFloat
    let padding: CGFloat
    let fill: Color
    let shadowOpacity: Double
    let content: Content

    init(
        cornerRadius: CGFloat = 24,
        padding: CGFloat = 18,
        fill: Color = AppTheme.surface,
        shadowOpacity: Double = 0.18,
        @ViewBuilder content: () -> Content
    ) {
        self.cornerRadius = cornerRadius
        self.padding = padding
        self.fill = fill
        self.shadowOpacity = shadowOpacity
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            content
        }
        .padding(padding)
        .background(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(fill)
        )
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .stroke(AppTheme.stroke, lineWidth: 1)
        )
        .shadow(color: .black.opacity(shadowOpacity), radius: 18, y: 10)
    }
}

struct AppScreenHeader<Trailing: View>: View {
    private let eyebrow: String?
    private let title: String
    private let subtitle: String?
    private let trailing: Trailing

    init(
        eyebrow: String? = nil,
        title: String,
        subtitle: String? = nil,
        @ViewBuilder trailing: () -> Trailing
    ) {
        self.eyebrow = eyebrow
        self.title = title
        self.subtitle = subtitle
        self.trailing = trailing()
    }

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                if let eyebrow, !eyebrow.isEmpty {
                    Text(eyebrow.uppercased())
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(AppTheme.accent)
                        .tracking(1.0)
                }

                Text(title)
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.textPrimary)
                    .multilineTextAlignment(.leading)

                if let subtitle, !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            Spacer(minLength: 12)
            trailing
        }
    }
}

extension AppScreenHeader where Trailing == EmptyView {
    init(eyebrow: String? = nil, title: String, subtitle: String? = nil) {
        self.init(eyebrow: eyebrow, title: title, subtitle: subtitle) {
            EmptyView()
        }
    }
}

struct AppSectionHeader<Trailing: View>: View {
    private let title: String
    private let subtitle: String?
    private let trailing: Trailing

    init(
        title: String,
        subtitle: String? = nil,
        @ViewBuilder trailing: () -> Trailing
    ) {
        self.title = title
        self.subtitle = subtitle
        self.trailing = trailing()
    }

    var body: some View {
        HStack(alignment: .bottom, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(AppTheme.textPrimary)

                if let subtitle, !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.footnote)
                        .foregroundStyle(AppTheme.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            Spacer(minLength: 8)
            trailing
        }
    }
}

extension AppSectionHeader where Trailing == EmptyView {
    init(title: String, subtitle: String? = nil) {
        self.init(title: title, subtitle: subtitle) {
            EmptyView()
        }
    }
}

struct AppMetricBadge: View {
    let title: String
    let value: String
    var emphasize: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(value)
                .font(.headline.weight(.bold))
                .foregroundStyle(emphasize ? AppTheme.accent : AppTheme.textPrimary)

            Text(title)
                .font(.caption)
                .foregroundStyle(AppTheme.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(AppTheme.surfaceMuted)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(emphasize ? AppTheme.accent.opacity(0.28) : AppTheme.stroke, lineWidth: 1)
        )
    }
}

struct AppTag: View {
    let title: String
    var systemImage: String?
    var tint: Color = AppTheme.accent

    var body: some View {
        HStack(spacing: 6) {
            if let systemImage {
                Image(systemName: systemImage)
                    .font(.caption.weight(.semibold))
            }

            Text(title)
                .font(.caption.weight(.semibold))
                .lineLimit(1)
        }
        .foregroundStyle(tint)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(tint.opacity(0.14))
        )
        .overlay(
            Capsule()
                .stroke(tint.opacity(0.18), lineWidth: 1)
        )
    }
}

struct AppIconBadge: View {
    let systemName: String
    var tint: Color = AppTheme.accent
    var fill: Color = AppTheme.surfaceRaised
    var badgeCount: Int = 0

    var body: some View {
        RoundedRectangle(cornerRadius: 18, style: .continuous)
            .fill(fill)
            .frame(width: 48, height: 48)
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(AppTheme.stroke, lineWidth: 1)
            )
            .overlay(
                Image(systemName: systemName)
                    .foregroundStyle(tint)
                    .font(.headline.weight(.bold))
            )
            .overlay(alignment: .topTrailing) {
                if badgeCount > 0 {
                    Text("\(badgeCount)")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 3)
                        .background(Capsule().fill(AppTheme.danger))
                        .offset(x: 5, y: -5)
                }
            }
    }
}

struct AppEmptyState: View {
    let title: String
    let message: String
    var systemImage: String = "sparkles"

    var body: some View {
        AppSurface(fill: AppTheme.surfaceMuted, shadowOpacity: 0.1) {
            VStack(spacing: 12) {
                Image(systemName: systemImage)
                    .font(.system(size: 26, weight: .semibold))
                    .foregroundStyle(AppTheme.accent)

                Text(title)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(AppTheme.textPrimary)

                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

struct AppInputContainer<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(AppTheme.surfaceMuted)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(AppTheme.stroke, lineWidth: 1)
            )
    }
}
