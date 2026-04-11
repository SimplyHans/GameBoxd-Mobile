import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel
    @State private var notificationsEnabled = true
    @State private var darkModeEnabled = true
    @State private var autoPlayVideos = false
    @State private var showAbout = false

    var body: some View {
        NavigationStack {
            AppBackground {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 22) {
                        AppScreenHeader(
                            eyebrow: "Preferences",
                            title: "Settings",
                            subtitle: "Tune notifications, playback, and account controls."
                        )
                        .padding(.horizontal, 20)
                        .padding(.top, 12)

                        SettingsSection(title: "Experience") {
                            SettingsToggleRow(title: "Enable Notifications", subtitle: "Stay updated on invites and social activity.", isOn: $notificationsEnabled)
                            SettingsToggleRow(title: "Dark Mode", subtitle: "Keep the app in the dark product theme.", isOn: $darkModeEnabled)
                            SettingsToggleRow(title: "Autoplay Videos", subtitle: "Start video highlights automatically in feed.", isOn: $autoPlayVideos)
                        }
                        .padding(.horizontal, 20)

                        SettingsSection(title: "Account") {
                            Button {
                                showAbout = true
                            } label: {
                                SettingsNavRow(title: "About GameBoxd", subtitle: "What the app is built for.", systemImage: "info.circle")
                            }
                            .buttonStyle(.plain)

                            Button {
                                authViewModel.logout()
                            } label: {
                                SettingsNavRow(
                                    title: "Log Out",
                                    subtitle: "Sign out of the current profile.",
                                    systemImage: "rectangle.portrait.and.arrow.right",
                                    tint: AppTheme.danger
                                )
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.bottom, 32)
                }
            }
            .sheet(isPresented: $showAbout) {
                AppBackground {
                    VStack(alignment: .leading, spacing: 16) {
                        AppScreenHeader(
                            eyebrow: "About",
                            title: "GameBoxd",
                            subtitle: "Track games, save favorites, and keep your personal gaming history organized."
                        )

                        AppSurface(fill: AppTheme.surfaceRaised) {
                            Text("This version focuses on a cleaner product experience with a strong home dashboard, connected detail flows, and a consistent visual system across the app.")
                                .font(.body)
                                .foregroundStyle(AppTheme.textSecondary)
                        }

                        Spacer()
                    }
                    .padding(20)
                }
                .presentationDetents([.medium, .large])
            }
        }
    }
}

private struct SettingsSection<Content: View>: View {
    let title: String
    let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        AppSurface(fill: AppTheme.surface) {
            Text(title)
                .font(.headline.weight(.bold))
                .foregroundStyle(AppTheme.textPrimary)

            VStack(spacing: 12) {
                content
            }
        }
    }
}

private struct SettingsToggleRow: View {
    let title: String
    let subtitle: String
    @Binding var isOn: Bool

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .foregroundStyle(AppTheme.textPrimary)
                    .font(.body.weight(.semibold))

                Text(subtitle)
                    .foregroundStyle(AppTheme.textSecondary)
                    .font(.caption)
            }

            Spacer()

            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(AppTheme.accent)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(AppTheme.surfaceMuted)
        )
    }
}

private struct SettingsNavRow: View {
    let title: String
    let subtitle: String
    let systemImage: String
    var tint: Color = AppTheme.textPrimary

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(AppTheme.surfaceMuted)
                    .frame(width: 42, height: 42)
                Image(systemName: systemImage)
                    .foregroundStyle(tint)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .foregroundStyle(tint)
                    .font(.body.weight(.semibold))

                Text(subtitle)
                    .foregroundStyle(AppTheme.textSecondary)
                    .font(.caption)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundStyle(AppTheme.textTertiary)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(AppTheme.surfaceMuted)
        )
    }
}

#Preview {
    SettingsView()
        .environmentObject(AuthViewModel())
}
