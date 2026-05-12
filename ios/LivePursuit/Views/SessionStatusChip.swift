import SwiftUI

struct SessionStatusChip: View {
    let sessionState: SessionState
    let consentState: ConsentState

    var body: some View {
        let config = configuration
        Label(config.title, systemImage: config.systemImage)
            .font(.caption.weight(.semibold))
            .foregroundStyle(.primary)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(.thinMaterial, in: Capsule())
            .overlay(
                Capsule()
                    .strokeBorder(.tertiary, lineWidth: 1)
            )
            .accessibilityLabel(config.accessibilityLabel)
            .accessibilityValue(config.accessibilityValue)
    }

    private var configuration: ChipConfig {
        if consentState == .revoked {
            return ChipConfig(
                title: "Consent revoked",
                systemImage: "hand.raised.fill",
                accessibilityLabel: "Consent",
                accessibilityValue: "Revoked"
            )
        }

        switch sessionState {
        case .active:
            return ChipConfig(
                title: "Active",
                systemImage: "location.fill",
                accessibilityLabel: "Session",
                accessibilityValue: "Active"
            )
        case .paused:
            return ChipConfig(
                title: "Paused",
                systemImage: "pause.fill",
                accessibilityLabel: "Session",
                accessibilityValue: "Paused"
            )
        case .ended:
            return ChipConfig(
                title: "Ended",
                systemImage: "xmark.circle.fill",
                accessibilityLabel: "Session",
                accessibilityValue: "Ended"
            )
        }
    }
}

private struct ChipConfig {
    let title: String
    let systemImage: String
    let accessibilityLabel: String
    let accessibilityValue: String
}
