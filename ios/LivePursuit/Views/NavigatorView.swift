import SwiftUI

struct NavigatorView: View {
    @ObservedObject var viewModel: NavigatorViewModel
    let contact: Contact

    @State private var hasStarted = false
    @State private var selectedScenario: SimulationScenario = .normalDriving
    @State private var selectedSpeed: SimulationSpeed = .one
    @State private var reroutePulse = false
    @State private var isSimulationMenuMinimized = false
    @State private var followModeEnabled = true
    @AppStorage("simModeEnabled") private var simModeEnabled = false

    var body: some View {
        RouteMapView(
            route: viewModel.route,
            destinationCoordinate: viewModel.destinationCoordinate,
            navigatorCoordinate: viewModel.navigatorCoordinate,
            destinationStyle: destinationMarkerStyle,
            showsUserLocation: viewModel.navigatorCoordinate == nil,
            highlightReroute: reroutePulse
        )
        .ignoresSafeArea()
        .safeAreaInset(edge: .top) {
            if contact.isSimulated, simModeEnabled {
                HStack {
                    Text("SIMULATION MODE")
                        .font(.caption2.weight(.semibold))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(.ultraThinMaterial, in: Capsule())
                        .foregroundStyle(.primary)
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
            }
        }
        .safeAreaInset(edge: .bottom) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 12) {
                    if let sessionState = viewModel.sessionState, let consentState = viewModel.consentState {
                        SessionStatusChip(sessionState: sessionState, consentState: consentState)
                    }
                    Spacer()
                    if viewModel.isDestinationStale {
                        Text("Location delayed")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                RouteSummaryCard(
                    etaText: viewModel.etaText,
                    distanceText: viewModel.distanceText,
                    arrivalText: arrivalTimeText
                )

                if !viewModel.nextInstruction.isEmpty {
                    Text("Next: \(viewModel.nextInstruction)")
                        .font(.headline)
                        .foregroundStyle(.primary)
                }

                if !viewModel.statusText.isEmpty {
                    Text(viewModel.statusText)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                if let error = viewModel.errorMessage {
                    Text(error)
                        .font(.footnote)
                        .foregroundStyle(.red)
                }

                ConsentStatusRow(
                    title: "Consent",
                    statusText: consentStatusText,
                    primaryActionTitle: "End Navigation",
                    primaryActionRole: .destructive,
                    primaryAction: { viewModel.stopNavigation() }
                )

                if contact.isSimulated, simModeEnabled {
                    Divider()

                    VStack(alignment: .leading, spacing: 8) {
                        let isSimulationInProgress = viewModel.simulationStatus?.status == .running
                            || viewModel.simulationStatus?.status == .paused
                        let hasSimulation = viewModel.simulationStatus != nil

                        HStack {
                            Text("Simulation")
                                .font(.headline)
                            Spacer()
                            Button {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    isSimulationMenuMinimized.toggle()
                                }
                                if isSimulationMenuMinimized {
                                    viewModel.logTelemetryEvent(type: "menu_minimized")
                                } else {
                                    viewModel.logTelemetryEvent(type: "menu_restored")
                                }
                            } label: {
                                Image(systemName: isSimulationMenuMinimized ? "chevron.up.circle.fill" : "chevron.down.circle.fill")
                                    .font(.title3)
                                    .foregroundStyle(.secondary)
                            }
                            .accessibilityLabel(isSimulationMenuMinimized ? "Show simulation controls" : "Hide simulation controls")
                            .buttonStyle(.plain)
                        }

                        if isSimulationMenuMinimized {
                            Text("Controls hidden")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .transition(.opacity)
                        } else {
                            Picker("Scenario", selection: $selectedScenario) {
                                ForEach(SimulationScenario.allCases) { scenario in
                                    Text(scenario.title).tag(scenario)
                                }
                            }
                            .pickerStyle(.segmented)
                            .disabled(isSimulationInProgress)

                            Text(selectedScenario.description)
                                .font(.footnote)
                                .foregroundStyle(.secondary)

                            if selectedScenario.supportsFollowMode {
                                Toggle(isOn: $followModeEnabled) {
                                    Label("Follow Mode", systemImage: "car.2.fill")
                                }
                                .tint(.accentColor)
                                .disabled(isSimulationInProgress)

                                Text("Simulate a navigator following the pursuit unit.")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Picker("Speed", selection: $selectedSpeed) {
                                ForEach(SimulationSpeed.allCases) { speed in
                                    Text(speed.label).tag(speed)
                                }
                            }
                            .pickerStyle(.segmented)
                            .onChange(of: selectedSpeed) { newValue in
                                guard hasSimulation else { return }
                                Task { await viewModel.setSimulationSpeed(newValue.rawValue) }
                            }

                            HStack(spacing: 12) {
                                Button(simulationPrimaryTitle) {
                                    Task {
                                        switch viewModel.simulationStatus?.status {
                                        case .running:
                                            await viewModel.pauseSimulation()
                                        case .paused:
                                            await viewModel.resumeSimulation()
                                        default:
                                            await viewModel.startSimulation(
                                                scriptId: simulationScriptId,
                                                speedMultiplier: selectedSpeed.rawValue
                                            )
                                        }
                                    }
                                }
                                .buttonStyle(.borderedProminent)

                                Button("Restart") {
                                    Task {
                                        guard hasSimulation else { return }
                                        await viewModel.replaySimulation(
                                            scriptId: simulationScriptId,
                                            speedMultiplier: selectedSpeed.rawValue
                                        )
                                    }
                                }
                                .buttonStyle(.bordered)
                                .disabled(!hasSimulation)

                                Button("Stop") {
                                    Task {
                                        guard hasSimulation else { return }
                                        await viewModel.stopSimulation()
                                    }
                                }
                                .buttonStyle(.bordered)
                                .disabled(!hasSimulation)
                            }

                            DebugPanel(
                                simulationStatus: viewModel.simulationStatus,
                                cooldownRemainingSeconds: viewModel.cooldownRemainingSeconds,
                                lastDecision: viewModel.lastRerouteDecision,
                                events: viewModel.sessionLogs,
                                refreshAction: { Task { await viewModel.refreshLogs() } }
                            )
                        }
                    }
                    .animation(.easeInOut(duration: 0.2), value: isSimulationMenuMinimized)
                }
            }
            .padding(16)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            .padding(.horizontal, 16)
            .padding(.bottom, 8)
        }
        .navigationTitle("Navigate to \(contact.name)")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            guard !hasStarted else { return }
            hasStarted = true
            viewModel.startNavigation(
                to: contact,
                simulationScenario: contact.isSimulated ? selectedScenario : nil,
                autoStartSimulation: !contact.isSimulated,
                speedMultiplier: selectedSpeed.rawValue
            )
        }
        .onDisappear {
            if !viewModel.isNavigating {
                viewModel.stopNavigation(notifyBackend: false)
            }
        }
        .onChange(of: viewModel.lastRerouteAt) { _ in
            reroutePulse = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                reroutePulse = false
            }
        }
    }

    private var simulationPrimaryTitle: String {
        switch viewModel.simulationStatus?.status {
        case .running:
            return "Pause"
        case .paused:
            return "Resume"
        case .completed, .stopped:
            return "Start"
        case .none:
            return "Start"
        }
    }

    private var simulationScriptId: String {
        if selectedScenario.supportsFollowMode && followModeEnabled {
            return "\(selectedScenario.rawValue)-follow"
        }
        return selectedScenario.rawValue
    }

    private var arrivalTimeText: String {
        guard let route = viewModel.route else { return "--" }
        let arrivalDate = Date().addingTimeInterval(route.expectedTravelTime)
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: arrivalDate)
    }

    private var consentStatusText: String {
        guard let consentState = viewModel.consentState else { return "Consent status unknown" }
        return consentState == .active ? "Destination sharing active" : "Consent revoked"
    }

    private var destinationMarkerStyle: DestinationMarkerStyle {
        guard contact.isSimulated else { return .standard }
        if activeScenario.isPursuit {
            return .pursuit
        }
        return .standard
    }

    private var activeScenario: SimulationScenario {
        if let scriptId = viewModel.simulationStatus?.scriptId {
            let normalized = scriptId.replacingOccurrences(of: "-follow", with: "")
            if let scenario = SimulationScenario(rawValue: normalized) {
                return scenario
            }
        }
        return selectedScenario
    }
}

private struct DebugPanel: View {
    let simulationStatus: SimulationStatus?
    let cooldownRemainingSeconds: Double
    let lastDecision: RerouteDecision?
    let events: [SessionLogEvent]
    let refreshAction: () -> Void

    @State private var isExpanded = false

    var body: some View {
        DisclosureGroup("Debug", isExpanded: $isExpanded) {
            VStack(alignment: .leading, spacing: 6) {
                if let simulationStatus {
                    Text("Sim Time: \(formattedTime(simulationStatus.elapsedSeconds))")
                    Text("Speed: \(String(format: "%.0fx", simulationStatus.speedMultiplier))")
                }
                Text("Cooldown: \(formattedCooldown)")
                if let lastDecision {
                    Text("Last Reason: \(lastDecision.reason)")
                    if let movement = lastDecision.movementDeltaMeters {
                        Text("Move delta: \(String(format: "%.1f m", movement))")
                    }
                    Text("ETA delta: \(String(format: "%.0f s", lastDecision.etaDeltaSeconds))")
                    if let thresholds = lastDecision.thresholdValuesUsed {
                        Text("Thresholds: \(String(format: "%.0f m / %.0f s", thresholds.movementMeters, thresholds.etaDeltaSeconds))")
                    }
                }

                Button("Refresh Events") {
                    refreshAction()
                }
                .buttonStyle(.bordered)

                ForEach(events.prefix(6)) { event in
                    Text("\(event.type) • \(formattedEventTime(event.timestamp))")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.top, 8)
        }
        .font(.footnote)
        .foregroundStyle(.secondary)
    }

    private var formattedCooldown: String {
        if cooldownRemainingSeconds <= 0 {
            return "Ready"
        }
        return String(format: "%.0f s", cooldownRemainingSeconds)
    }

    private func formattedTime(_ seconds: Double) -> String {
        let minutes = Int(seconds) / 60
        let remaining = Int(seconds) % 60
        return String(format: "%02d:%02d", minutes, remaining)
    }

    private func formattedEventTime(_ timestamp: Double) -> String {
        let date = Date(timeIntervalSince1970: timestamp / 1000)
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: date)
    }
}
