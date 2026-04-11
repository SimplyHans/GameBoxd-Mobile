import SwiftUI
import Combine

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var isAuthenticated: Bool
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var currentUser: User?

    private let service: AuthServicing
    private let appStateService: AppStateServicing

    init(service: AuthServicing? = nil, appStateService: AppStateServicing? = nil) {
        let resolvedService = service ?? AuthService.shared
        let resolvedAppStateService = appStateService ?? AppStateService.shared
        self.service = resolvedService
        self.appStateService = resolvedAppStateService
        let user = resolvedService.currentUser()
        self.currentUser = user
        self.isAuthenticated = user != nil
        if let user {
            resolvedAppStateService.ensureStateExists(for: user)
        }
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

    func updateProfile(username: String, bio: String, about: String) {
        try? service.updateUsername(username)
        currentUser = service.currentUser()
        appStateService.updateProfile(bio: bio, about: about, for: currentUser)
        appStateService.recordProfileUpdated(for: currentUser)
    }

    func logout() {
        appStateService.recordLogout(for: currentUser)
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
            appStateService.ensureStateExists(for: user)
            appStateService.recordLogin(for: user)
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
            let user = try await service.register(username: username, email: email, password: password)
            appStateService.ensureStateExists(for: user)
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
