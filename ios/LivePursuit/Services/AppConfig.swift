import Foundation

enum AppConfig {
    static let backendBaseURL = URL(string: bundleString(for: "LivePursuitBackendURL", fallback: "http://localhost:3000"))!
    static let currentUserId = bundleString(for: "LivePursuitCurrentUserID", fallback: "user-1")
    static let currentUserName = bundleString(for: "LivePursuitCurrentUserName", fallback: "You")
    static let destinationPollInterval: TimeInterval = 5
    static let locationUpdateInterval: TimeInterval = 10
    static let staleThreshold: TimeInterval = 30
    static let simulatedContactId = "simulated-destination"

    private static func bundleString(for key: String, fallback: String) -> String {
        guard let value = Bundle.main.object(forInfoDictionaryKey: key) as? String else {
            return fallback
        }
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty || trimmed.hasPrefix("$(") {
            return fallback
        }
        return trimmed
    }
}
