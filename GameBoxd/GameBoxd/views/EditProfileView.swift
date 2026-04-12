import SwiftUI
import PhotosUI

struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var username: String
    @State private var bio: String
    @State private var about: String

    // Photo picker state
    @State private var selectedItem: PhotosPickerItem?
    @State private var avatarImage: UIImage?

    private let appStateService: AppStateServicing = AppStateService.shared

    var currentUser: User?
    var onSave: (String, String, String) -> Void

    init(
        currentUsername: String,
        currentBio: String,
        currentAbout: String,
        currentUser: User? = nil,
        onSave: @escaping (String, String, String) -> Void
    ) {
        _username = State(initialValue: currentUsername)
        _bio = State(initialValue: currentBio)
        _about = State(initialValue: currentAbout)
        self.currentUser = currentUser
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

                    // MARK: - Avatar Picker
                    HStack {
                        Spacer()
                        PhotosPicker(selection: $selectedItem, matching: .images) {
                            ZStack(alignment: .bottomTrailing) {
                                // Avatar image or placeholder
                                Group {
                                    if let avatarImage {
                                        Image(uiImage: avatarImage)
                                            .resizable()
                                            .scaledToFill()
                                    } else {
                                        Image(systemName: "person.fill")
                                            .font(.system(size: 40, weight: .semibold))
                                            .foregroundStyle(AppTheme.accent)
                                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    }
                                }
                                .frame(width: 100, height: 100)
                                .background(AppTheme.surfaceMuted)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(AppTheme.stroke, lineWidth: 1))

                                // Camera badge
                                Circle()
                                    .fill(AppTheme.accent)
                                    .frame(width: 30, height: 30)
                                    .overlay(
                                        Image(systemName: "camera.fill")
                                            .font(.system(size: 13))
                                            .foregroundStyle(.white)
                                    )
                                    .offset(x: 2, y: 2)
                            }
                        }
                        Spacer()
                    }
                    .padding(.top, 4)

                    // MARK: - Fields
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
        .onAppear {
            avatarImage = appStateService.loadAvatar(for: currentUser)
        }
        .onChange(of: selectedItem) { _, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    avatarImage = image
                    appStateService.saveAvatar(image, for: currentUser)
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
        EditProfileView(
            currentUsername: "Hanson",
            currentBio: "Gamer. Competitive.",
            currentAbout: "Loves shooters and team games."
        ) { _, _, _ in }
    }
}
