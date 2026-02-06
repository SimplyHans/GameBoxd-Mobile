import SwiftUI

struct ProfileView: View {
    @State private var username: String = "Hanson"
    @State private var bio: String = "Gamer. Competitive. Always grinding."

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            // Header
                            Text("Profile")
                                .foregroundStyle(.white)
                                .font(.largeTitle.weight(.bold))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 16)
                                .padding(.top, 8)

                            // Avatar + username
                            HStack(alignment: .center, spacing: 16) {
                                ZStack {
                                    Circle()
                                        .fill(Color.black.opacity(0.25))
                                        .frame(width: 84, height: 84)
                                        .overlay(
                                            Circle().stroke(
                                                LinearGradient(colors: [Color.purple, Color.blue], startPoint: .topLeading, endPoint: .bottomTrailing),
                                                lineWidth: 2
                                            )
                                        )
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 36))
                                        .foregroundStyle(.white.opacity(0.9))
                                }

                                VStack(alignment: .leading, spacing: 6) {
                                    Text(username)
                                        .font(.title2.weight(.bold))
                                        .foregroundStyle(.white)
                                    Text(bio)
                                        .font(.subheadline)
                                        .foregroundStyle(.white.opacity(0.8))
                                        .lineLimit(2)
                                }
                                Spacer()
                            }
                            .padding(.horizontal, 16)

                            // Stats
                            HStack(spacing: 12) {
                                ProfileStat(title: "Games", value: "42")
                                ProfileStat(title: "Hours", value: "1.2k")
                                ProfileStat(title: "Followers", value: "389")
                            }
                            .padding(.horizontal, 16)

                            // Edit Button
                            NavigationLink {
                                EditProfileView(currentUsername: username, currentBio: bio) { newName, newBio in
                                    self.username = newName
                                    self.bio = newBio
                                }
                            } label: {
                                Text("Edit Profile")
                                    .font(.headline)
                                    .foregroundStyle(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
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
                            }
                            .padding(.horizontal, 16)

                            // About Section
                            ProfileSectionCard(title: "About", alignment: .center) {
                                Text("Loves shooters and team games. Looking for ranked squads on weekends.")
                                    .foregroundStyle(.white.opacity(0.9))
                                    .font(.subheadline)
                                    .multilineTextAlignment(.center)
                            }
                            .padding(.horizontal, 16)

                            // Recently Played Section
                            ProfileSectionCard(title: "Recently Played") {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 16) {
                                        ForEach(0..<5) { _ in
                                            VStack(spacing: 8) {
                                                Image("Image")
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
                                                Text("Fortnit")
                                                    .font(.subheadline.weight(.semibold))
                                                    .foregroundStyle(.white)
                                                    .lineLimit(1)
                                            }
                                            .frame(width: 120)
                                        }
                                    }
                                    .padding(.horizontal, 4)
                                }
                            }
                            .padding(.horizontal, 16)

                            // Achievements / Badges placeholder
                            ProfileSectionCard(title: "Badges", alignment: .center) {
                                HStack(spacing: 12) {
                                    ForEach(0..<4) { i in
                                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                                            .fill(Color.black.opacity(0.25))
                                            .frame(width: 64, height: 64)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                                    .stroke(
                                                        LinearGradient(colors: [Color.purple, Color.blue], startPoint: .topLeading, endPoint: .bottomTrailing),
                                                        lineWidth: 1
                                                    )
                                            )
                                            .overlay(
                                                Text("#\(i+1)")
                                                    .foregroundStyle(.white.opacity(0.9))
                                            )
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .center)
                            }
                            .padding(.horizontal, 16)

                            Spacer(minLength: 24)
                        }
                    }
                }
            }
        }
    }
}

struct ProfileStat: View {
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 6) {
            Text(value)
                .font(.title2.weight(.bold))
                .foregroundStyle(.white)
            Text(title)
                .font(.footnote.weight(.medium))
                .foregroundStyle(.white.opacity(0.8))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
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
    }
}

struct ProfileSectionCard<Content: View>: View {
    let title: String
    let alignment: HorizontalAlignment
    @ViewBuilder var content: Content

    init(title: String, alignment: HorizontalAlignment = .leading, @ViewBuilder content: () -> Content) {
        self.title = title
        self.alignment = alignment
        self.content = content()
    }

    var body: some View {
        VStack(alignment: alignment, spacing: 12) {
            Text(title)
                .font(.headline.weight(.bold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, alignment: alignment == .center ? .center : .leading)
            content
        }
        .padding(16)
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

#Preview {
    ProfileView()
}
