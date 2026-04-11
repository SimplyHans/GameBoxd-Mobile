import Foundation

extension Notification.Name {
    static let gameAPIKeyDidChange = Notification.Name("GameAPIKeyDidChange")
}

enum GameAPIKeyStore {
    private static let defaultsKey = "settings.rawg.api.key"

    static var apiKey: String? {
        sanitized(UserDefaults.standard.string(forKey: defaultsKey)) ??
        sanitized(Bundle.main.object(forInfoDictionaryKey: "RAWGAPIKey") as? String) ??
        sanitized(ProcessInfo.processInfo.environment["RAWG_API_KEY"])
    }

    static var hasAPIKey: Bool {
        apiKey != nil
    }

    static func save(apiKey: String) {
        guard let trimmedKey = sanitized(apiKey) else {
            clear()
            return
        }

        UserDefaults.standard.set(trimmedKey, forKey: defaultsKey)
        NotificationCenter.default.post(name: .gameAPIKeyDidChange, object: nil)
    }

    static func clear() {
        UserDefaults.standard.removeObject(forKey: defaultsKey)
        NotificationCenter.default.post(name: .gameAPIKeyDidChange, object: nil)
    }

    private static func sanitized(_ value: String?) -> String? {
        guard let value else { return nil }
        let trimmedValue = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedValue.isEmpty ? nil : trimmedValue
    }
}
