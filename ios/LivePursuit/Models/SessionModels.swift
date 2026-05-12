import Foundation

enum SessionState: String, Codable {
    case active
    case paused
    case ended
}

enum ConsentState: String, Codable {
    case active
    case revoked
}

struct LocationPoint: Codable, Hashable {
    let latitude: Double
    let longitude: Double
    let timestamp: Double
}

struct NavigationSession: Codable, Identifiable {
    let id: String
    let navigatorUserId: String
    let destinationUserId: String
    let navigatorDisplayName: String
    let destinationDisplayName: String
    let state: SessionState
    let consentState: ConsentState
    let endReason: String?
    let createdAt: Double
    let expiresAt: Double
    let lastRerouteAt: Double
    let latestLocation: LocationPoint?
}

struct TargetLocationResponse: Codable {
    let sessionState: SessionState
    let consentState: ConsentState
    let navigatorDisplayName: String
    let destinationDisplayName: String
    let endReason: String?
    let latestLocation: LocationPoint?
    let stale: Bool
    let simulation: SimulationStatus?
    let cooldownRemainingSeconds: Double?
    let lastRerouteDecision: RerouteDecision?
}

struct RerouteDecision: Codable {
    let shouldReroute: Bool
    let reason: String
    let etaDeltaSeconds: Double
    let movementDeltaMeters: Double?
    let cooldownActive: Bool?
    let capActive: Bool?
    let thresholdValuesUsed: ThresholdValues?
    let cooldownRemainingSeconds: Double?
}

struct ThresholdValues: Codable {
    let movementMeters: Double
    let etaDeltaSeconds: Double
    let jitterRadiusMeters: Double
}
