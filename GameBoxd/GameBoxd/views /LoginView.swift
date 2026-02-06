import SwiftUI

struct LoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var goToHome = false

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            NavigationLink(destination: TabsView(), isActive: $goToHome) { EmptyView() }
                            
                            Text("Login")
                                .foregroundStyle(.white)
                                .font(.largeTitle.weight(.bold))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 16)
                                .padding(.top, 8)

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
                                goToHome = true
                            } label: {
                                Text("Login")
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
                                Text("Don't have an account?")
                                    .foregroundStyle(.white.opacity(0.8))
                                NavigationLink("Register") {
                                    RegisterPageView()
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
    var placeholderColor: Color = .white // white placeholder
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
    var placeholderColor: Color = .white // white placeholder
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
    LoginView()
}
