import SwiftUI

struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var username: String
    @State private var bio: String

    var onSave: (String, String) -> Void

    init(currentUsername: String, currentBio: String, onSave: @escaping (String, String) -> Void) {
        _username = State(initialValue: currentUsername)
        _bio = State(initialValue: currentBio)
        self.onSave = onSave
    }

    var body: some View {
        ZStack {
            AppBackground {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        // Header
                        Text("Edit Profile")
                            .foregroundStyle(.white)
                            .font(.largeTitle.weight(.bold))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 16)
                            .padding(.top, 8)

                        // Form fields
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Username")
                                .foregroundStyle(.white.opacity(0.9))
                                .font(.headline)
                            ProfileFieldBackground {
                                TextField("Enter username", text: $username)
                                    .foregroundStyle(.white)
                                    .textInputAutocapitalization(.words)
                            }
                        }
                        .padding(.horizontal, 16)

                        VStack(alignment: .leading, spacing: 12) {
                            Text("Bio")
                                .foregroundStyle(.white.opacity(0.9))
                                .font(.headline)
                            ProfileFieldBackground {
                                TextEditor(text: $bio)
                                    .foregroundStyle(.white)
                                    .frame(minHeight: 120)
                            }
                        }
                        .padding(.horizontal, 16)

                        // Save button
                        Button {
                            onSave(username, bio)
                            dismiss()
                        } label: {
                            Text("Save")
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
                        .padding(.top, 8)

                        Spacer(minLength: 24)
                    }
                }
            }
        }
    }
}

private struct ProfileFieldBackground<Content: View>: View {
    @ViewBuilder var content: Content
    var body: some View {
        content
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.black.opacity(0.25))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(
                        LinearGradient(colors: [Color.purple, Color.blue], startPoint: .topLeading, endPoint: .bottomTrailing),
                        lineWidth: 1
                    )
            )
    }
}

#Preview {
    NavigationStack {
        EditProfileView(currentUsername: "Hanson", currentBio: "Gamer. Competitive.") { _, _ in }
    }
}
