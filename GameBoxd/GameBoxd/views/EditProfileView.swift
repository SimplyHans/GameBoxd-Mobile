import SwiftUI

struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var username: String
    @State private var bio: String
    @State private var about: String

    var onSave: (String, String, String) -> Void

    init(currentUsername: String, currentBio: String, currentAbout: String, onSave: @escaping (String, String, String) -> Void) {
        _username = State(initialValue: currentUsername)
        _bio = State(initialValue: currentBio)
        _about = State(initialValue: currentAbout)
        self.onSave = onSave
    }

    var body: some View {
        AppBackground {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 22) {
                    AppScreenHeader(
                        eyebrow: "Profile",
                        title: "Edit Profile",
                        subtitle: "Update the identity and description attached to your account."
                    )
                    .padding(.horizontal, 20)
                    .padding(.top, 24)

                    AppSurface(fill: AppTheme.surfaceRaised) {
                        profileField(label: "Username") {
                            TextField("Enter username", text: $username)
                                .foregroundStyle(AppTheme.textPrimary)
                                .textInputAutocapitalization(.words)
                        }

                        profileField(label: "Bio") {
                            TextEditor(text: $bio)
                                .foregroundStyle(AppTheme.textPrimary)
                                .frame(minHeight: 90)
                                .scrollContentBackground(.hidden)
                                .background(Color.clear)
                        }

                        profileField(label: "About") {
                            TextEditor(text: $about)
                                .foregroundStyle(AppTheme.textPrimary)
                                .frame(minHeight: 140)
                                .scrollContentBackground(.hidden)
                                .background(Color.clear)
                        }

                        Button {
                            onSave(username, bio, about)
                            dismiss()
                        } label: {
                            Text("Save Changes")
                                .font(.headline.weight(.semibold))
                                .foregroundStyle(AppTheme.backgroundBase)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 15)
                                .background(
                                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                                        .fill(AppTheme.textPrimary)
                                )
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 24)
                }
            }
        }
    }

    private func profileField<Content: View>(label: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(label)
                .font(.headline.weight(.semibold))
                .foregroundStyle(AppTheme.textPrimary)

            AppInputContainer {
                content()
            }
        }
    }
}

#Preview {
    NavigationStack {
        EditProfileView(currentUsername: "Hanson", currentBio: "Gamer. Competitive.", currentAbout: "Loves shooters and team games.") { _, _, _ in }
    }
}
