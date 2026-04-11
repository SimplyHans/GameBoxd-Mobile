import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var showAlert = false

    var body: some View {
        NavigationStack {
            AppBackground {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 22) {
                        AppScreenHeader(
                            eyebrow: "Welcome",
                            title: "Log In",
                            subtitle: "Jump back into your library, stats, and gaming activity."
                        )
                        .padding(.horizontal, 20)
                        .padding(.top, 24)

                        AppSurface(fill: AppTheme.surfaceRaised) {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Email")
                                    .font(.headline.weight(.semibold))
                                    .foregroundStyle(AppTheme.textPrimary)

                                AppInputContainer {
                                    TextField("name@example.com", text: $email)
                                        .keyboardType(.emailAddress)
                                        .textInputAutocapitalization(.never)
                                        .autocorrectionDisabled(true)
                                        .foregroundStyle(AppTheme.textPrimary)
                                }
                            }

                            VStack(alignment: .leading, spacing: 10) {
                                Text("Password")
                                    .font(.headline.weight(.semibold))
                                    .foregroundStyle(AppTheme.textPrimary)

                                AppInputContainer {
                                    SecureField("Enter password", text: $password)
                                        .foregroundStyle(AppTheme.textPrimary)
                                }
                            }

                            Button {
                                authViewModel.login(email: email, password: password)
                            } label: {
                                Text(authViewModel.isLoading ? "Signing In..." : "Login")
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

                        AppSurface(fill: AppTheme.surface) {
                            AppSectionHeader(
                                title: "Why GameBoxd",
                                subtitle: "A focused place to track what you play."
                            )

                            VStack(alignment: .leading, spacing: 10) {
                                AppTag(title: "Track favorites", systemImage: "heart.fill")
                                AppTag(title: "Keep activity history", systemImage: "list.bullet.rectangle")
                                AppTag(title: "Discover trending picks", systemImage: "sparkles")
                            }
                        }
                        .padding(.horizontal, 20)

                        HStack(spacing: 6) {
                            Text("Don't have an account?")
                                .foregroundStyle(AppTheme.textSecondary)

                            NavigationLink("Register") {
                                RegisterPageView()
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
                    title: Text("Login Failed"),
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
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthViewModel())
}
