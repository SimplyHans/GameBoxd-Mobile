import Foundation

struct User: Codable, Equatable {
    let id: UUID
    let username: String
    let email: String
}

private struct StoredAccount: Codable {
    let user: User
    let password: String
}

enum AuthError: LocalizedError {
    case invalidCredentials
    case userAlreadyExists
    case invalidEmail
    case weakPassword
    case missingFields
    case unknown

    // Validation error description
    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "The email or password you entered is incorrect."
        case .userAlreadyExists:
            return "An account with this email already exists."
        case .invalidEmail:
            return "Please enter a valid email address."
        case .weakPassword:
            return "Password must be at least 6 characters."
        case .missingFields:
            return "Please fill in all fields."
        case .unknown:
            return "Something went wrong. Please try again."
        }
    }
}

protocol AuthServicing {
    func login(email: String, password: String) async throws -> User
    func register(username: String, email: String, password: String) async throws -> User
    func currentUser() -> User?
    func logout()
    func updateUsername(_ newUsername: String) throws
}

final class AuthService: AuthServicing {
    static let shared = AuthService()

    private let accountsStorageKey = "auth.accounts"
    private let currentUserIDKey = "auth.currentUserID"

    private init() {}

    func login(email: String, password: String) async throws -> User {
        try validate(email: email, password: password)

        try await Task.sleep(nanoseconds: 500_000_000)

        guard let account = storedAccounts().first(where: {
            $0.user.email.caseInsensitiveCompare(email) == .orderedSame &&
            $0.password == password
        }) else {
            throw AuthError.invalidCredentials
        }

        UserDefaults.standard.set(account.user.id.uuidString, forKey: currentUserIDKey)
        return account.user
    }

    func register(username: String, email: String, password: String) async throws -> User {
        let trimmedUsername = username.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        guard !trimmedUsername.isEmpty, !trimmedEmail.isEmpty, !password.isEmpty else {
            throw AuthError.missingFields
        }

        guard isValidEmail(trimmedEmail) else {
            throw AuthError.invalidEmail
        }

        guard password.count >= 6 else {
            throw AuthError.weakPassword
        }

        try await Task.sleep(nanoseconds: 700_000_000)

        var accounts = storedAccounts()
        guard !accounts.contains(where: { $0.user.email.caseInsensitiveCompare(trimmedEmail) == .orderedSame }) else {
            throw AuthError.userAlreadyExists
        }

        let user = User(id: UUID(), username: trimmedUsername, email: trimmedEmail)
        accounts.append(StoredAccount(user: user, password: password))

        if let encoded = try? JSONEncoder().encode(accounts) {
            UserDefaults.standard.set(encoded, forKey: accountsStorageKey)
        } else {
            throw AuthError.unknown
        }

        return user
    }

    func currentUser() -> User? {
        guard
            let currentUserID = UserDefaults.standard.string(forKey: currentUserIDKey),
            let userID = UUID(uuidString: currentUserID)
        else {
            return nil
        }

        return storedAccounts().first(where: { $0.user.id == userID })?.user
    }

    func updateUsername(_ newUsername: String) throws {
        let trimmedUsername = newUsername.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedUsername.isEmpty else { throw AuthError.missingFields }
        guard let user = currentUser() else { throw AuthError.unknown }

        var accounts = storedAccounts()
        guard let index = accounts.firstIndex(where: { $0.user.id == user.id }) else {
            throw AuthError.unknown
        }

        let updatedUser = User(id: user.id, username: trimmedUsername, email: user.email)
        accounts[index] = StoredAccount(user: updatedUser, password: accounts[index].password)

        guard let encoded = try? JSONEncoder().encode(accounts) else {
            throw AuthError.unknown
        }

        UserDefaults.standard.set(encoded, forKey: accountsStorageKey)
    }

    func logout() {
        UserDefaults.standard.removeObject(forKey: currentUserIDKey)
    }

    // MARK: - Validation

    private func validate(email: String, password: String) throws {
        guard !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !password.isEmpty else {
            throw AuthError.missingFields
        }

        guard isValidEmail(email) else {
            throw AuthError.invalidEmail
        }

        guard password.count >= 6 else {
            throw AuthError.weakPassword
        }
    }

    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegEx).evaluate(with: email)
    }

    private func storedAccounts() -> [StoredAccount] {
        guard
            let data = UserDefaults.standard.data(forKey: accountsStorageKey),
            let accounts = try? JSONDecoder().decode([StoredAccount].self, from: data)
        else {
            return []
        }

        return accounts
    }
}
