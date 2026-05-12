import Foundation
import MapKit

@MainActor
final class NavigatorViewModel: ObservableObject {
    @Published var route: MKRoute?
    @Published var destinationCoordinate: CLLocationCoordinate2D?
    @Published var destinationName: String = ""
    @Published var etaText: String = "--"
    @Published var distanceText: String = "--"
    @Published var nextInstruction: String = ""
    @Published var statusText: String = ""
    @Published var isNavigating = false
    @Published var sessionState: SessionState?
    @Published var consentState: ConsentState?
    @Published var isDestinationStale = false
    @Published var errorMessage: String?
    @Published var simulationStatus: SimulationStatus? {
        didSet { handleSimulationStatusChange() }
    }
    @Published var lastRerouteDecision: RerouteDecision?
    @Published var cooldownRemainingSeconds: Double = 0
    @Published var lastRerouteAt: Date?
    @Published var sessionLogs: [SessionLogEvent] = []
    @Published var navigatorCoordinate: CLLocationCoordinate2D?

    private let locationService: LocationService
    private let backendClient: BackendClient
    private let routeService: RouteService
    private let navigator: UserProfile

    private var session: NavigationSession?
    private var pollingTimer: Timer?
    private var currentStepIndex = 0
    private var simulatedNavigatorTimer: Timer?
    private var simulatedRoutePath: RoutePath?
    private var simulatedDistanceTraveled: CLLocationDistance = 0
    private var lastSimulatedUpdateAt: Date?
    private var simulatedBaseSpeed: CLLocationSpeed = 14
    private var lastTelemetryAt: Date?
    private var lastFollowDistanceAt: Date?

    init(locationService: LocationService, backendClient: BackendClient = .shared, routeService: RouteService = RouteService(), navigator: UserProfile) {
        self.locationService = locationService
        self.backendClient = backendClient
        self.routeService = routeService
        self.navigator = navigator
    }

    func startNavigation(to contact: Contact, simulationScenario: SimulationScenario? = nil, autoStartSimulation: Bool = true, speedMultiplier: Double = 1) {
        Task {
            do {
                statusText = "Starting navigation"
                locationService.requestPermission()
                locationService.startUpdates()
                let session = try await backendClient.createSession(
                    navigatorId: navigator.id,
                    destinationId: contact.id,
                    navigatorName: navigator.name,
                    destinationName: contact.name
                )
                self.session = session
                destinationName = contact.name
                sessionState = session.state
                consentState = session.consentState
                isNavigating = true
                if contact.isSimulated && !autoStartSimulation {
                    statusText = "Simulation ready"
                }
                if autoStartSimulation, contact.isSimulated, let simulationScenario {
                    await startSimulation(scriptId: simulationScenario.rawValue, speedMultiplier: speedMultiplier)
                }
                startPolling()
            } catch {
                errorMessage = error.localizedDescription
                statusText = "Unable to start navigation"
            }
        }
    }

    func stopNavigation(notifyBackend: Bool = true) {
        pollingTimer?.invalidate()
        pollingTimer = nil
        isNavigating = false
        stopSimulatedNavigator(resetLocation: true)
        if notifyBackend {
            statusText = "Navigation stopped"
        }
        sessionState = .ended
        if notifyBackend, let session = session {
            Task {
                do {
                    _ = try await backendClient.stopSession(sessionId: session.id, userId: navigator.id)
                    _ = try? await backendClient.stopSimulation(sessionId: session.id)
                } catch {
                    errorMessage = error.localizedDescription
                }
            }
        }
    }

    func startSimulation(scriptId: String, speedMultiplier: Double = 1) async {
        guard let session else { return }
        do {
            simulationStatus = try await backendClient.startSimulation(sessionId: session.id, scriptId: scriptId, speedMultiplier: speedMultiplier)
            statusText = "Simulation running"
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func replaySimulation(scriptId: String, speedMultiplier: Double = 1) async {
        guard let session else { return }
        do {
            simulationStatus = try await backendClient.replaySimulation(sessionId: session.id, scriptId: scriptId, speedMultiplier: speedMultiplier)
            statusText = "Simulation replayed"
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func stopSimulation() async {
        guard let session else { return }
        do {
            simulationStatus = try await backendClient.stopSimulation(sessionId: session.id)
            statusText = "Simulation stopped"
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func pauseSimulation() async {
        guard let session else { return }
        do {
            simulationStatus = try await backendClient.pauseSimulation(sessionId: session.id)
            statusText = "Simulation paused"
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func resumeSimulation() async {
        guard let session else { return }
        do {
            simulationStatus = try await backendClient.resumeSimulation(sessionId: session.id)
            statusText = "Simulation running"
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func restartSimulation() async {
        guard let session else { return }
        do {
            simulationStatus = try await backendClient.restartSimulation(sessionId: session.id)
            statusText = "Simulation restarted"
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func setSimulationSpeed(_ speedMultiplier: Double) async {
        guard let session else { return }
        do {
            simulationStatus = try await backendClient.setSimulationSpeed(sessionId: session.id, speedMultiplier: speedMultiplier)
            statusText = "Speed \(speedMultiplier)x"
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func logTelemetryEvent(type: String, details: [String: Any] = [:]) {
        guard let session else { return }
        Task {
            _ = try? await backendClient.logSessionEvent(sessionId: session.id, type: type, details: details)
        }
    }

    func refreshLogs() async {
        guard let session else { return }
        do {
            sessionLogs = try await backendClient.fetchSessionLogs(sessionId: session.id)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func startPolling() {
        pollingTimer?.invalidate()
        pollingTimer = Timer.scheduledTimer(withTimeInterval: AppConfig.destinationPollInterval, repeats: true) { [weak self] _ in
            Task { await self?.tick() }
        }
        Task { await tick() }
    }

    private func tick() async {
        await fetchTargetLocation()
        updateStepProgress()
    }

    private func fetchTargetLocation() async {
        guard let session else { return }
        do {
            let response = try await backendClient.fetchTargetLocation(sessionId: session.id, navigatorId: navigator.id)
            sessionState = response.sessionState
            consentState = response.consentState
            isDestinationStale = response.stale
            if response.sessionState != .active || response.consentState != .active {
                statusText = sessionEndMessage(from: response.endReason)
                stopNavigation(notifyBackend: false)
                return
            }
            destinationName = response.destinationDisplayName
            if let latest = response.latestLocation {
                destinationCoordinate = CLLocationCoordinate2D(latitude: latest.latitude, longitude: latest.longitude)
                ensureSimulatedNavigatorSeed(for: destinationCoordinate)
                await evaluateRouteUpdate(destination: latest)
            } else {
                statusText = "Waiting for destination location"
            }
            simulationStatus = response.simulation
            if let decision = response.lastRerouteDecision {
                lastRerouteDecision = decision
            }
            cooldownRemainingSeconds = response.cooldownRemainingSeconds ?? 0
            if response.stale {
                statusText = "Location delayed - using last route"
            }
        } catch let apiError as APIError {
            if apiError.code == "NOT_FOUND" {
                statusText = "Session ended"
                sessionState = .ended
                stopNavigation(notifyBackend: false)
                return
            }
            statusText = "Offline - using last route"
            errorMessage = apiError.localizedDescription
        } catch {
            statusText = "Offline - using last route"
            errorMessage = error.localizedDescription
        }
    }

    private func evaluateRouteUpdate(destination: LocationPoint) async {
        guard let currentLocation = locationService.lastLocation?.coordinate else { return }
        guard let session else { return }
        let destinationCoord = CLLocationCoordinate2D(latitude: destination.latitude, longitude: destination.longitude)
        do {
            let candidateRoute = try await routeService.calculateRoute(from: currentLocation, to: destinationCoord)
            if let currentRoute = route {
                let decision = try await backendClient.rerouteCheck(
                    sessionId: session.id,
                    navigatorId: navigator.id,
                    currentEtaSeconds: currentRoute.expectedTravelTime,
                    candidateEtaSeconds: candidateRoute.expectedTravelTime
                )
                lastRerouteDecision = decision
                cooldownRemainingSeconds = decision.cooldownRemainingSeconds ?? cooldownRemainingSeconds
                if decision.shouldReroute {
                    applyRoute(candidateRoute)
                    statusText = "Route updated"
                    lastRerouteAt = Date()
                } else {
                    statusText = "On course"
                }
            } else {
                applyRoute(candidateRoute)
                statusText = "Navigation active"
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func applyRoute(_ route: MKRoute) {
        self.route = route
        etaText = formattedETA(route.expectedTravelTime)
        distanceText = formattedDistance(route.distance)
        currentStepIndex = 0
        updateInstructionText()
        updateSimulatedRoute(route)
    }

    private func updateStepProgress() {
        guard let route else { return }
        guard currentStepIndex < route.steps.count else { return }
        guard let userCoordinate = locationService.lastLocation?.coordinate else { return }

        let step = route.steps[currentStepIndex]
        guard let stepEnd = step.polyline.lastCoordinate() else { return }
        let distanceToStepEnd = userCoordinate.distance(to: stepEnd)
        if distanceToStepEnd < 25, currentStepIndex + 1 < route.steps.count {
            currentStepIndex += 1
            updateInstructionText()
        }
    }

    private func updateInstructionText() {
        guard let route else { return }
        let instructions = route.steps.map { $0.instructions }.filter { !$0.isEmpty }
        if currentStepIndex < instructions.count {
            nextInstruction = instructions[currentStepIndex]
        } else {
            nextInstruction = "Continue to destination"
        }
    }

    private var isFollowSimulationActive: Bool {
        guard let scriptId = simulationStatus?.scriptId else { return false }
        return scriptId.hasSuffix("-follow")
    }

    private func handleSimulationStatusChange() {
        guard isFollowSimulationActive else {
            stopSimulatedNavigator(resetLocation: true)
            return
        }

        switch simulationStatus?.status {
        case .running:
            startSimulatedNavigatorIfNeeded()
        case .paused:
            stopSimulatedNavigatorTimer()
        case .stopped, .completed, .none:
            stopSimulatedNavigator(resetLocation: true)
        }
    }

    private func ensureSimulatedNavigatorSeed(for destinationCoordinate: CLLocationCoordinate2D?) {
        guard isFollowSimulationActive else { return }
        guard let destinationCoordinate else { return }
        guard navigatorCoordinate == nil else { return }

        let seedCoordinate = destinationCoordinate.offset(byMetersNorth: -320, metersEast: -180)
        updateSimulatedNavigatorLocation(seedCoordinate)
    }

    private func updateSimulatedRoute(_ route: MKRoute) {
        guard isFollowSimulationActive else { return }
        let path = RoutePath(polyline: route.polyline)
        guard path.coordinates.count > 1 else { return }
        simulatedRoutePath = path
        simulatedDistanceTraveled = 0
        simulatedBaseSpeed = route.expectedTravelTime > 0 ? route.distance / route.expectedTravelTime : 14
        if let start = path.coordinates.first {
            updateSimulatedNavigatorLocation(start)
        }
        startSimulatedNavigatorIfNeeded()
    }

    private func startSimulatedNavigatorIfNeeded() {
        guard isFollowSimulationActive else { return }
        guard simulationStatus?.status == .running else { return }
        guard simulatedRoutePath != nil else { return }
        guard simulatedNavigatorTimer == nil else { return }
        lastSimulatedUpdateAt = Date()
        simulatedNavigatorTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.advanceSimulatedNavigator()
        }
    }

    private func stopSimulatedNavigatorTimer() {
        simulatedNavigatorTimer?.invalidate()
        simulatedNavigatorTimer = nil
        lastSimulatedUpdateAt = nil
    }

    private func stopSimulatedNavigator(resetLocation: Bool) {
        stopSimulatedNavigatorTimer()
        simulatedRoutePath = nil
        simulatedDistanceTraveled = 0
        if resetLocation {
            navigatorCoordinate = nil
            locationService.stopSimulation()
        }
    }

    private func advanceSimulatedNavigator() {
        guard simulationStatus?.status == .running else { return }
        guard let path = simulatedRoutePath else { return }
        let now = Date()
        let delta = now.timeIntervalSince(lastSimulatedUpdateAt ?? now)
        lastSimulatedUpdateAt = now
        let multiplier = simulationStatus?.speedMultiplier ?? 1
        let speed = simulatedBaseSpeed * multiplier
        simulatedDistanceTraveled += speed * max(0, delta)
        let coordinate = path.coordinate(at: simulatedDistanceTraveled)
        updateSimulatedNavigatorLocation(coordinate)
    }

    private func updateSimulatedNavigatorLocation(_ coordinate: CLLocationCoordinate2D) {
        let location = CLLocation(
            coordinate: coordinate,
            altitude: 0,
            horizontalAccuracy: 6,
            verticalAccuracy: 6,
            timestamp: Date()
        )
        locationService.setSimulatedLocation(location)
        navigatorCoordinate = coordinate
        logNavigatorTelemetryIfNeeded(location: location)
    }

    private func logNavigatorTelemetryIfNeeded(location: CLLocation) {
        guard isFollowSimulationActive else { return }
        guard let session else { return }

        let now = Date()
        if let last = lastTelemetryAt, now.timeIntervalSince(last) < 2 {
            return
        }
        lastTelemetryAt = now

        Task {
            _ = try? await backendClient.logSessionEvent(
                sessionId: session.id,
                type: "navigator_simulation_position_update",
                details: [
                    "latitude": location.coordinate.latitude,
                    "longitude": location.coordinate.longitude,
                    "timestamp": location.timestamp.timeIntervalSince1970 * 1000,
                ]
            )
        }

        if let destinationCoordinate {
            if let last = lastFollowDistanceAt, now.timeIntervalSince(last) < 2 {
                return
            }
            lastFollowDistanceAt = now
            let distance = location.coordinate.distance(to: destinationCoordinate)
            Task {
                _ = try? await backendClient.logSessionEvent(
                    sessionId: session.id,
                    type: "follow_distance_delta",
                    details: [
                        "meters": distance,
                    ]
                )
            }
        }
    }

    private func formattedETA(_ seconds: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.unitsStyle = .short
        return formatter.string(from: seconds) ?? "--"
    }

    private func formattedDistance(_ meters: CLLocationDistance) -> String {
        let formatter = MeasurementFormatter()
        formatter.unitOptions = .naturalScale
        formatter.numberFormatter.maximumFractionDigits = 1
        let measurement = Measurement(value: meters, unit: UnitLength.meters)
        return formatter.string(from: measurement)
    }

    private func sessionEndMessage(from reason: String?) -> String {
        switch reason {
        case "expired":
            return "Session expired"
        case "stopped_by_destination":
            return "Destination ended the session"
        case "stopped_by_navigator":
            return "You ended the session"
        default:
            return "Session ended"
        }
    }
}

private struct RoutePath {
    let coordinates: [CLLocationCoordinate2D]
    let cumulativeDistances: [CLLocationDistance]
    let totalDistance: CLLocationDistance

    init(polyline: MKPolyline) {
        let coords = polyline.coordinates()
        coordinates = coords
        guard coords.count > 1 else {
            cumulativeDistances = [0]
            totalDistance = 0
            return
        }

        var distances = [CLLocationDistance](repeating: 0, count: coords.count)
        for index in 1..<coords.count {
            distances[index] = distances[index - 1] + coords[index - 1].distance(to: coords[index])
        }
        cumulativeDistances = distances
        totalDistance = distances.last ?? 0
    }

    func coordinate(at distance: CLLocationDistance) -> CLLocationCoordinate2D {
        guard let first = coordinates.first else {
            return CLLocationCoordinate2D(latitude: 0, longitude: 0)
        }
        guard distance > 0 else { return first }
        if distance >= totalDistance {
            return coordinates.last ?? first
        }

        for index in 1..<coordinates.count {
            if cumulativeDistances[index] >= distance {
                let segmentDistance = cumulativeDistances[index] - cumulativeDistances[index - 1]
                let segmentTravel = distance - cumulativeDistances[index - 1]
                let fraction = segmentDistance > 0 ? segmentTravel / segmentDistance : 0
                let start = coordinates[index - 1]
                let end = coordinates[index]
                let latitude = start.latitude + (end.latitude - start.latitude) * fraction
                let longitude = start.longitude + (end.longitude - start.longitude) * fraction
                return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            }
        }
        return coordinates.last ?? first
    }
}
