import SwiftUI

struct RegisterPageView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var authViewModel: AuthViewModel

    @State private var username = ""
    @State private var email = ""
    @State private var password = ""
    @State private var showAlert = false

    var body: some View {
        AppBackground {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 22) {
                    AppScreenHeader(
                        eyebrow: "Create account",
                        title: "Register",
                        subtitle: "Set up your profile and start tracking games cleanly."
                    )
                    .padding(.horizontal, 20)
                    .padding(.top, 24)

                    AppSurface(fill: AppTheme.surfaceRaised) {
                        registerField(label: "Username") {
                            TextField("Your gamer tag", text: $username)
                                .textInputAutocapitalization(.words)
                                .autocorrectionDisabled(true)
                                .foregroundStyle(AppTheme.textPrimary)
                        }

                        registerField(label: "Email") {
                            TextField("name@example.com", text: $email)
                                .keyboardType(.emailAddress)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled(true)
                                .foregroundStyle(AppTheme.textPrimary)
                        }

                        registerField(label: "Password") {
                            SecureField("Create a password", text: $password)
                                .foregroundStyle(AppTheme.textPrimary)
                        }

                        Button {
                            authViewModel.register(username: username, email: email, password: password) {
                                dismiss()
                            }
                        } label: {
                            Text(authViewModel.isLoading ? "Creating Account..." : "Register")
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
                        .disabled(authViewModel.isLoading)
                        .opacity(authViewModel.isLoading ? 0.65 : 1)
                    }
                    .padding(.horizontal, 20)

                    HStack(spacing: 6) {
                        Text("Already have an account?")
                            .foregroundStyle(AppTheme.textSecondary)

                        Button("Log in") {
                            dismiss()
                        }
                        .foregroundStyle(AppTheme.accent)
                    }
                    .font(.subheadline.weight(.medium))
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 24)
                }
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Registration Failed"),
                message: Text(authViewModel.errorMessage ?? "Please try again."),
                dismissButton: .default(Text("OK")) {
                    showAlert = false
                }
            )
        }
        .onChange(of: authViewModel.errorMessage) { _, newValue in
            showAlert = newValue != nil
        }
    }

    private func registerField<Content: View>(label: String, @ViewBuilder content: () -> Content) -> some View {
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
        RegisterPageView()
    }
    .environmentObject(AuthViewModel())
}
