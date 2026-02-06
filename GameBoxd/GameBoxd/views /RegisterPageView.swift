import SwiftUI

struct RegisterPageView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var username: String = ""
    @State private var email: String = ""
    @State private var password: String = ""

    var body: some View {
        ZStack {
            AppBackground {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Register")
                            .foregroundStyle(.white)
                            .font(.largeTitle.weight(.bold))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 16)
                            .padding(.top, 8)

                        VStack(alignment: .leading, spacing: 12) {
                            Text("Username")
                                .foregroundStyle(.white.opacity(0.9))
                                .font(.headline)
                            AuthFieldBackground {
                                PlaceholderTextField(
                                    placeholder: "Your gamer tag",
                                    text: $username,
                                    placeholderColor: .white,
                                    autocapitalization: .words,
                                    disableAutocorrection: true
                                )
                            }
                        }
                        .padding(.horizontal, 16)

                        VStack(alignment: .leading, spacing: 12) {
                            Text("Email")
                                .foregroundStyle(.white.opacity(0.9))
                                .font(.headline)
                            AuthFieldBackground {
                                PlaceholderTextField(
                                    placeholder: "name@example.com",
                                    text: $email,
                                    placeholderColor: .white,
                                    keyboardType: .emailAddress,
                                    autocapitalization: .never,
                                    disableAutocorrection: true
                                )
                            }
                        }
                        .padding(.horizontal, 16)

                        VStack(alignment: .leading, spacing: 12) {
                            Text("Password")
                                .foregroundStyle(.white.opacity(0.9))
                                .font(.headline)
                            AuthFieldBackground {
                                PlaceholderSecureField(
                                    placeholder: "••••••••",
                                    text: $password,
                                    placeholderColor: .white
                                )
                            }
                        }
                        .padding(.horizontal, 16)

                        Button {
                            // After successful registration, go back to Login
                            dismiss()
                        } label: {
                            Text("Register")
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

                        HStack {
                            Text("Already have an account?")
                                .foregroundStyle(.white.opacity(0.8))
                            Button("Log in") {
                                dismiss()
                            }
                            .foregroundStyle(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 16)
                        .padding(.top, 4)

                        Spacer(minLength: 24)
                    }
                }
            }
        }
    }
}

private struct AuthFieldBackground<Content: View>: View {
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

private struct PlaceholderTextField: View {
    let placeholder: String
    @Binding var text: String
    var placeholderColor: Color = .white
    var keyboardType: UIKeyboardType = .default
    var autocapitalization: TextInputAutocapitalization = .never
    var disableAutocorrection: Bool = true

    var body: some View {
        ZStack(alignment: .leading) {
            if text.isEmpty {
                Text(placeholder)
                    .foregroundStyle(placeholderColor)
            }
            TextField("", text: $text)
                .keyboardType(keyboardType)
                .textInputAutocapitalization(autocapitalization)
                .autocorrectionDisabled(disableAutocorrection)
                .foregroundStyle(.white)
                .tint(.white)
                .accentColor(.white)
        }
    }
}

private struct PlaceholderSecureField: View {
    let placeholder: String
    @Binding var text: String
    var placeholderColor: Color = .white
    @State private var isEditing: Bool = false

    var body: some View {
        ZStack(alignment: .leading) {
            if text.isEmpty && !isEditing {
                Text(placeholder)
                    .foregroundStyle(placeholderColor)
            }
            SecureField("", text: $text)
                .foregroundStyle(.white)
                .tint(.white)
                .accentColor(.white)
                .onTapGesture { isEditing = true }
                .onChange(of: text) { _, _ in isEditing = true }
        }
        .onTapGesture { isEditing = true }
    }
}

#Preview {
    NavigationStack {
        RegisterPageView()
    }
}
