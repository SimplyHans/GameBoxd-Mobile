import SwiftUI

struct SettingsView: View {
    @State private var notificationsEnabled: Bool = true
    @State private var darkModeEnabled: Bool = true
    @State private var autoPlayVideos: Bool = false

    var body: some View {
        ZStack {
            AppBackground {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Settings")
                            .foregroundStyle(.white)
                            .font(.largeTitle.weight(.bold))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 16)
                            .padding(.top, 8)

                        SettingsSection(title: "Preferences") {
                            SettingsToggleRow(title: "Enable Notifications", isOn: $notificationsEnabled)
                            SettingsToggleRow(title: "Dark Mode", isOn: $darkModeEnabled)
                            SettingsToggleRow(title: "Autoplay Videos", isOn: $autoPlayVideos)
                        }
                        .padding(.horizontal, 16)

                        SettingsSection(title: "Account") {
                            SettingsNavRow(title: "Edit Profile", systemImage: "person.circle")
                            SettingsNavRow(title: "Privacy", systemImage: "lock.shield")
                            SettingsNavRow(title: "About", systemImage: "info.circle")
                        }
                        .padding(.horizontal, 16)

                        Spacer(minLength: 24)
                    }
                }
            }
        }
    }
}

private struct SettingsSection<Content: View>: View {
    let title: String
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .foregroundStyle(.white)
                .font(.headline.weight(.bold))
            VStack(spacing: 10) {
                content
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.black.opacity(0.25))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(
                        LinearGradient(colors: [Color.purple, Color.blue], startPoint: .topLeading, endPoint: .bottomTrailing),
                        lineWidth: 1.5
                    )
            )
        }
    }
}

private struct SettingsToggleRow: View {
    let title: String
    @Binding var isOn: Bool

    var body: some View {
        HStack {
            Text(title)
                .foregroundStyle(.white)
                .font(.body)
            Spacer()
            Toggle("", isOn: $isOn)
                .labelsHidden()
        }
    }
}

private struct SettingsNavRow: View {
    let title: String
    let systemImage: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: systemImage)
                .foregroundStyle(.white)
            Text(title)
                .foregroundStyle(.white)
                .font(.body)
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundStyle(.white.opacity(0.7))
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.black.opacity(0.2))
        )
    }
}

#Preview {
    SettingsView()
}
