import SwiftUI

struct SharingStatusView: View {
    @ObservedObject var viewModel: SharingStatusViewModel
    @AppStorage("didShowLocationEducation") private var didShowLocationEducation = false
    @State private var hasStarted = false

    var body: some View {
        Group {
            if !didShowLocationEducation {
                PermissionEducationView(
                    title: "Enable location sharing",
                    message: "Live Pursuit uses your location only during active sessions.",
                    detail: "You can pause or stop sharing at any time.",
                    primaryActionTitle: "Continue",
                    primaryAction: {
                        didShowLocationEducation = true
                        startIfNeeded()
                    }
                )
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Live Pursuit")
                                .font(.largeTitle.bold())
                            Text("Share your live location")
                                .font(.body)
                                .foregroundStyle(.secondary)
                        }

                        if let session = viewModel.activeSession {
                            SessionStatusChip(sessionState: session.state, consentState: session.consentState)
                        }

                        if !viewModel.navigatorStatusText.isEmpty {
                            Text(viewModel.navigatorStatusText)
                                .font(.headline)
                                .foregroundStyle(.primary)
                                .padding(.vertical, 10)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                        }

                        if viewModel.sharingState == .permissionDenied {
                            ErrorStateView(
                                systemImage: "exclamationmark.triangle",
                                title: "Location access needed",
                                message: "Enable location access in Settings to share your live location.",
                                primaryActionTitle: "Open Settings",
                                primaryAction: { viewModel.openSettings() }
                            )
                        } else {
                            StatusCard(
                                systemImage: statusIcon,
                                title: statusTitle,
                                message: statusMessage
                            )

                            if !viewModel.lastUpdatedText.isEmpty {
                                Text(viewModel.lastUpdatedText)
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                            }

                            ConsentStatusRow(
                                title: "Sharing",
                                statusText: statusMessage,
                                primaryActionTitle: primaryActionTitle,
                                primaryActionRole: primaryActionRole,
                                primaryAction: primaryAction,
                                secondaryActionTitle: secondaryActionTitle,
                                secondaryActionRole: .destructive,
                                secondaryAction: secondaryActionTitle == nil ? nil : secondaryAction
                            )
                        }

                        if let errorMessage = viewModel.errorMessage {
                            Text(errorMessage)
                                .font(.footnote)
                                .foregroundStyle(.red)
                        }

                        Text("Location sharing is only active during a navigation session.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    .padding(24)
                }
            }
        }
        .onAppear {
            if didShowLocationEducation {
                startIfNeeded()
            }
        }
    }

    private var statusIcon: String {
        switch viewModel.sharingState {
        case .notSharing:
            return "location.slash"
        case .sharingLive:
            return "location.fill"
        case .sharingStale:
            return "location.fill"
        case .paused:
            return "pause.circle"
        case .stopped:
            return "stop.circle"
        case .permissionDenied:
            return "exclamationmark.triangle"
        }
    }

    private var statusTitle: String {
        switch viewModel.sharingState {
        case .notSharing:
            return "Not sharing"
        case .sharingLive:
            return "Sharing live"
        case .sharingStale:
            return "Location delayed"
        case .paused:
            return "Sharing paused"
        case .stopped:
            return "Sharing stopped"
        case .permissionDenied:
            return "Location access needed"
        }
    }

    private var statusMessage: String {
        switch viewModel.sharingState {
        case .notSharing:
            return "Start sharing to let your navigator see your live location."
        case .sharingLive:
            return "Your navigator can see your live location."
        case .sharingStale:
            return "Last update delayed."
        case .paused:
            return "Resume to keep your navigator updated."
        case .stopped:
            return "Restart sharing to resume updates."
        case .permissionDenied:
            return "Enable location access in Settings to share your live location."
        }
    }

    private var primaryActionTitle: String {
        switch viewModel.sharingState {
        case .notSharing:
            return "Start Sharing"
        case .sharingLive, .sharingStale:
            return "Pause Sharing"
        case .paused:
            return "Resume Sharing"
        case .stopped:
            return "Start Sharing"
        case .permissionDenied:
            return "Open Settings"
        }
    }

    private var secondaryActionTitle: String? {
        switch viewModel.sharingState {
        case .sharingLive, .sharingStale, .paused:
            return "Stop Sharing"
        default:
            return nil
        }
    }

    private var primaryActionRole: ButtonRole? {
        switch viewModel.sharingState {
        case .sharingLive, .sharingStale, .paused:
            return nil
        case .permissionDenied:
            return nil
        default:
            return nil
        }
    }

    private func primaryAction() {
        switch viewModel.sharingState {
        case .notSharing:
            viewModel.startSharing()
        case .sharingLive, .sharingStale:
            viewModel.pauseSharing()
        case .paused:
            viewModel.resumeSharing()
        case .stopped:
            viewModel.startSharing()
        case .permissionDenied:
            viewModel.openSettings()
        }
    }

    private func secondaryAction() {
        viewModel.stopSharing()
    }

    private func startIfNeeded() {
        guard !hasStarted else { return }
        hasStarted = true
        viewModel.start()
    }
}
