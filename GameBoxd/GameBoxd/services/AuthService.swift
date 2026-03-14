import Foundation

struct User: Codable, Equatable {
    let id: UUID
    let username: String
    let email: String
}

enum AuthError: LocalizedError {
    case invalidCredentials
    case userAlreadyExists
    case invalidEmail
    case weakPassword
    case missingFields
    case unknown

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

    private let storedUserKey = "auth.storedUser"
    private let storedPasswordKey = "auth.storedPassword"

    private init() {}

    func login(email: String, password: String) async throws -> User {
        try validate(email: email, password: password)

        try await Task.sleep(nanoseconds: 500_000_000)

        guard
            let data = UserDefaults.standard.data(forKey: storedUserKey),
            let storedUser = try? JSONDecoder().decode(User.self, from: data),
            let storedPassword = UserDefaults.standard.string(forKey: storedPasswordKey),
            storedUser.email.caseInsensitiveCompare(email) == .orderedSame,
            storedPassword == password
        else {
            throw AuthError.invalidCredentials
        }

        return storedUser
    }

    func register(username: String, email: String, password: String) async throws -> User {
        guard !username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !password.isEmpty else {
            throw AuthError.missingFields
        }

        guard isValidEmail(email) else {
            throw AuthError.invalidEmail
        }

        guard password.count >= 6 else {
            throw AuthError.weakPassword
        }

        try await Task.sleep(nanoseconds: 700_000_000)

        if UserDefaults.standard.data(forKey: storedUserKey) != nil {
            throw AuthError.userAlreadyExists
        }

        let user = User(id: UUID(), username: username, email: email.lowercased())

        if let encoded = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(encoded, forKey: storedUserKey)
            UserDefaults.standard.set(password, forKey: storedPasswordKey)
        } else {
            throw AuthError.unknown
        }

        return user
    }

    func currentUser() -> User? {
        guard let data = UserDefaults.standard.data(forKey: storedUserKey) else {
            return nil
        }
        return try? JSONDecoder().decode(User.self, from: data)
    }

    func updateUsername(_ newUsername: String) throws {
        guard let user = currentUser() else { throw AuthError.unknown }
        let updated = User(id: user.id, username: newUsername, email: user.email)
        if let encoded = try? JSONEncoder().encode(updated) {
            UserDefaults.standard.set(encoded, forKey: storedUserKey)
        } else {
            throw AuthError.unknown
        }
    }

    func logout() {
        UserDefaults.standard.removeObject(forKey: storedUserKey)
        UserDefaults.standard.removeObject(forKey: storedPasswordKey)
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
}
