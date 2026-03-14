import SwiftUI
import Combine

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var isAuthenticated: Bool
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var currentUser: User?

    private let service: AuthServicing

    init(service: AuthServicing? = nil) {
        let resolvedService = service ?? AuthService.shared
        self.service = resolvedService
        let user = resolvedService.currentUser()
        self.currentUser = user
        self.isAuthenticated = user != nil
    }

    func login(email: String, password: String) {
        Task {
            await performAuthAction {
                try await self.service.login(email: email, password: password)
            }
        }
    }

    func register(username: String, email: String, password: String, completion: (() -> Void)? = nil) {
        Task {
            await performRegister(username: username, email: email, password: password, completion: completion)
        }
    }
    func updateUsername(_ newUsername: String){
        try? service.updateUsername(newUsername)
        currentUser = service.currentUser()
    }
    func logout() {
        service.logout()
        currentUser = nil
        isAuthenticated = false
    }

    // MARK: - Private

    private func performAuthAction(_ action: @escaping () async throws -> User, completion: (() -> Void)? = nil) async {
        isLoading = true
        errorMessage = nil
        do {
            let user = try await action()
            currentUser = user
            isAuthenticated = true
            completion?()
        } catch {
            if let authError = error as? AuthError {
                errorMessage = authError.localizedDescription
            } else {
                errorMessage = AuthError.unknown.localizedDescription
            }
            isAuthenticated = false
        }
        isLoading = false
    }

    private func performRegister(username: String, email: String, password: String, completion: (() -> Void)? = nil) async {
        isLoading = true
        errorMessage = nil
        do {
            _ = try await service.register(username: username, email: email, password: password)
            // Do NOT mark as authenticated here – user should go back to Login
            completion?()
        } catch {
            if let authError = error as? AuthError {
                errorMessage = authError.localizedDescription
            } else {
                errorMessage = AuthError.unknown.localizedDescription
            }
        }
        isLoading = false
    }
}
