import Foundation
import CoreLocation
import UIKit

@MainActor
final class SharingStatusViewModel: ObservableObject {
    @Published var sharingState: SharingState = .notSharing
    @Published var lastUpdatedText: String = ""
    @Published var activeSession: NavigationSession?
    @Published var navigatorStatusText: String = ""
    @Published var errorMessage: String?

    private let locationService: LocationService
    private let backendClient: BackendClient
    private let user: UserProfile

    private var pollingTimer: Timer?
    private var lastLocationSentAt: Date?
    private var nextAllowedLocationUpdateAt: Date?
    private var isSharingEnabled = false

    init(locationService: LocationService, backendClient: BackendClient = .shared, user: UserProfile) {
        self.locationService = locationService
        self.backendClient = backendClient
        self.user = user
    }

    func start() {
        locationService.requestPermission()
        locationService.startUpdates()
        startPolling()
    }

    func stop() {
        pollingTimer?.invalidate()
        pollingTimer = nil
        locationService.stopUpdates()
    }

    func startSharing() {
        isSharingEnabled = true
        errorMessage = nil
        nextAllowedLocationUpdateAt = nil
        if let session = activeSession, session.state == .paused {
            Task { await updateSessionState(action: .resume) }
        }
        updateState()
    }

    func pauseSharing() {
        isSharingEnabled = false
        nextAllowedLocationUpdateAt = nil
        Task { await updateSessionState(action: .pause) }
        updateState()
    }

    func resumeSharing() {
        isSharingEnabled = true
        nextAllowedLocationUpdateAt = nil
        Task { await updateSessionState(action: .resume) }
        updateState()
    }

    func stopSharing() {
        isSharingEnabled = false
        nextAllowedLocationUpdateAt = nil
        Task { await updateSessionState(action: .stop) }
        updateState()
    }

    func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }

    private func startPolling() {
        pollingTimer?.invalidate()
        pollingTimer = Timer.scheduledTimer(withTimeInterval: AppConfig.destinationPollInterval, repeats: true) { [weak self] _ in
            Task { await self?.tick() }
        }
        Task { await tick() }
    }

    private func tick() async {
        await refreshSessions()
        await sendLocationIfNeeded()
        updateState()
    }

    private func refreshSessions() async {
        do {
            let sessions = try await backendClient.listSessions(destinationUserId: user.id)
            activeSession = sessions.sorted { $0.createdAt > $1.createdAt }.first
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func sendLocationIfNeeded() async {
        guard isSharingEnabled else { return }
        guard let session = activeSession else { return }
        guard session.state == .active else { return }
        guard locationService.authorizationStatus == .authorizedWhenInUse || locationService.authorizationStatus == .authorizedAlways else {
            return
        }
        guard let location = locationService.lastLocation else { return }
        let now = Date()
        if let nextAllowed = nextAllowedLocationUpdateAt, now < nextAllowed {
            return
        }

        do {
            let result = try await backendClient.updateLocation(sessionId: session.id, userId: user.id, location: location)
            if result.accepted, let latest = result.latestLocation {
                lastLocationSentAt = Date(timeIntervalSince1970: latest.timestamp / 1000)
            }
            nextAllowedLocationUpdateAt = Date(timeIntervalSince1970: result.nextAllowedAt / 1000)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func updateSessionState(action: SessionAction) async {
        guard let session = activeSession else { return }
        do {
            let updated: NavigationSession
            switch action {
            case .pause:
                updated = try await backendClient.pauseSession(sessionId: session.id, destinationId: user.id)
            case .resume:
                updated = try await backendClient.resumeSession(sessionId: session.id, destinationId: user.id)
            case .stop:
                updated = try await backendClient.stopSession(sessionId: session.id, userId: user.id)
            }
            activeSession = updated
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func updateState() {
        switch locationService.authorizationStatus {
        case .denied, .restricted:
            sharingState = .permissionDenied
            navigatorStatusText = ""
            lastUpdatedText = ""
            return
        default:
            break
        }

        if let session = activeSession {
            if session.state == .paused {
                navigatorStatusText = "\(session.navigatorDisplayName) is navigating to you"
                sharingState = .paused
            } else if session.state == .ended || session.consentState == .revoked {
                navigatorStatusText = ""
                sharingState = .stopped
                lastUpdatedText = sessionEndMessage(from: session.endReason)
            } else if isSharingEnabled {
                navigatorStatusText = "\(session.navigatorDisplayName) is navigating to you"
                if let lastSent = lastLocationSentAt {
                    if Date().timeIntervalSince(lastSent) > AppConfig.staleThreshold {
                        sharingState = .sharingStale
                    } else {
                        sharingState = .sharingLive
                    }
                    lastUpdatedText = relativeTimeText(from: lastSent)
                } else {
                    sharingState = .sharingStale
                    lastUpdatedText = "Waiting for first update"
                }
            } else {
                navigatorStatusText = "\(session.navigatorDisplayName) is navigating to you"
                sharingState = .paused
            }
        } else {
            navigatorStatusText = ""
            if isSharingEnabled {
                sharingState = .sharingStale
                lastUpdatedText = "Waiting for navigator session"
            } else {
                sharingState = .notSharing
                lastUpdatedText = ""
            }
        }
    }

    private func sessionEndMessage(from reason: String?) -> String {
        switch reason {
        case "expired":
            return "Session expired"
        case "stopped_by_destination":
            return "You ended the session"
        case "stopped_by_navigator":
            return "Navigator ended the session"
        default:
            return "Session ended"
        }
    }

    private func relativeTimeText(from date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return "Last updated \(formatter.localizedString(for: date, relativeTo: Date()))"
    }
}

private enum SessionAction {
    case pause
    case resume
    case stop
}
