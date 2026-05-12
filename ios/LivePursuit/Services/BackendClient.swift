import Foundation
import CoreLocation

final class BackendClient {
    static let shared = BackendClient()

    private let baseURL: URL
    private let session: URLSession

    init(baseURL: URL = AppConfig.backendBaseURL, session: URLSession = .shared) {
        self.baseURL = baseURL
        self.session = session
    }

    func createSession(navigatorId: String, destinationId: String, navigatorName: String, destinationName: String) async throws -> NavigationSession {
        let body: [String: Any] = [
            "navigatorUserId": navigatorId,
            "destinationUserId": destinationId,
            "navigatorDisplayName": navigatorName,
            "destinationDisplayName": destinationName,
        ]
        return try await request(path: "/sessions", method: "POST", body: body)
    }

    func listSessions(destinationUserId: String, state: String? = nil) async throws -> [NavigationSession] {
        var path = "/sessions?destinationUserId=\(destinationUserId)"
        if let state {
            path += "&state=\(state)"
        }
        return try await request(path: path, method: "GET")
    }

    func updateLocation(sessionId: String, userId: String, location: CLLocation) async throws -> LocationUpdateResult {
        var body: [String: Any] = [
            "userId": userId,
            "latitude": location.coordinate.latitude,
            "longitude": location.coordinate.longitude,
            "timestamp": location.timestamp.timeIntervalSince1970 * 1000,
        ]
        if location.horizontalAccuracy >= 0 {
            body["accuracy"] = location.horizontalAccuracy
        }
        if location.speed >= 0 {
            body["speed"] = location.speed
        }
        return try await request(path: "/sessions/\(sessionId)/location", method: "POST", body: body)
    }

    func fetchTargetLocation(sessionId: String, navigatorId: String) async throws -> TargetLocationResponse {
        let path = "/sessions/\(sessionId)/target-location?userId=\(navigatorId)"
        return try await request(path: path, method: "GET")
    }

    func rerouteCheck(sessionId: String, navigatorId: String, currentEtaSeconds: Double, candidateEtaSeconds: Double) async throws -> RerouteDecision {
        let body: [String: Any] = [
            "userId": navigatorId,
            "currentEtaSeconds": currentEtaSeconds,
            "candidateEtaSeconds": candidateEtaSeconds,
        ]
        return try await request(path: "/sessions/\(sessionId)/reroute-check", method: "POST", body: body)
    }

    func pauseSession(sessionId: String, destinationId: String) async throws -> NavigationSession {
        try await request(path: "/sessions/\(sessionId)/pause", method: "POST", body: ["userId": destinationId])
    }

    func resumeSession(sessionId: String, destinationId: String) async throws -> NavigationSession {
        try await request(path: "/sessions/\(sessionId)/resume", method: "POST", body: ["userId": destinationId])
    }

    func stopSession(sessionId: String, userId: String) async throws -> NavigationSession {
        try await request(path: "/sessions/\(sessionId)/stop", method: "POST", body: ["userId": userId])
    }

    func startSimulation(sessionId: String, scriptId: String, speedMultiplier: Double = 1) async throws -> SimulationStatus {
        let body: [String: Any] = ["scriptId": scriptId, "speedMultiplier": speedMultiplier]
        return try await request(path: "/sessions/\(sessionId)/simulation/start", method: "POST", body: body)
    }

    func stopSimulation(sessionId: String) async throws -> SimulationStatus {
        return try await request(path: "/sessions/\(sessionId)/simulation/stop", method: "POST", body: [:])
    }

    func replaySimulation(sessionId: String, scriptId: String, speedMultiplier: Double = 1) async throws -> SimulationStatus {
        let body: [String: Any] = ["scriptId": scriptId, "speedMultiplier": speedMultiplier]
        return try await request(path: "/sessions/\(sessionId)/simulation/replay", method: "POST", body: body)
    }

    func pauseSimulation(sessionId: String) async throws -> SimulationStatus {
        return try await request(path: "/sessions/\(sessionId)/simulation/pause", method: "POST", body: [:])
    }

    func resumeSimulation(sessionId: String) async throws -> SimulationStatus {
        return try await request(path: "/sessions/\(sessionId)/simulation/resume", method: "POST", body: [:])
    }

    func restartSimulation(sessionId: String) async throws -> SimulationStatus {
        return try await request(path: "/sessions/\(sessionId)/simulation/restart", method: "POST", body: [:])
    }

    func setSimulationSpeed(sessionId: String, speedMultiplier: Double) async throws -> SimulationStatus {
        let body: [String: Any] = ["speedMultiplier": speedMultiplier]
        return try await request(path: "/sessions/\(sessionId)/simulation/speed", method: "POST", body: body)
    }

    func fetchSessionLogs(sessionId: String) async throws -> [SessionLogEvent] {
        return try await request(path: "/sessions/\(sessionId)/logs", method: "GET")
    }

    func logSessionEvent(sessionId: String, type: String, details: [String: Any] = [:]) async throws -> SessionLogEvent {
        let body: [String: Any] = [
            "type": type,
            "details": details,
        ]
        return try await request(path: "/sessions/\(sessionId)/events", method: "POST", body: body)
    }

    private func request<T: Decodable>(path: String, method: String, body: [String: Any]? = nil) async throws -> T {
        guard let url = URL(string: path, relativeTo: baseURL) else {
            throw URLError(.badURL)
        }
        var request = URLRequest(url: url)
        request.httpMethod = method
        if let body {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }

        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        if httpResponse.statusCode >= 400 {
            let decoded = try? JSONDecoder().decode(APIResponse<EmptyResponse>.self, from: data)
            if let apiError = decoded?.error {
                throw apiError
            }
            throw URLError(.badServerResponse)
        }

        let decoded = try JSONDecoder().decode(APIResponse<T>.self, from: data)
        if let apiError = decoded.error {
            throw apiError
        }
        guard let value = decoded.data else {
            throw URLError(.cannotParseResponse)
        }
        return value
    }
}

private struct EmptyResponse: Decodable {}
