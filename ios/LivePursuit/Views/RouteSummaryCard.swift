import SwiftUI

struct RouteSummaryCard: View {
    let etaText: String
    let distanceText: String
    let arrivalText: String

    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: 16) {
                MetricBlock(title: "ETA", value: etaText)
                MetricBlock(title: "Distance", value: distanceText)
                MetricBlock(title: "Arrive", value: arrivalText)
            }

            VStack(alignment: .leading, spacing: 8) {
                MetricRow(title: "ETA", value: etaText)
                MetricRow(title: "Distance", value: distanceText)
                MetricRow(title: "Arrive", value: arrivalText)
            }
        }
        .padding(12)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Route summary")
        .accessibilityValue("ETA \(etaText), Distance \(distanceText), Arrive \(arrivalText)")
    }
}

private struct MetricBlock: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.headline)
                .foregroundStyle(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
    }
}

private struct MetricRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.headline)
                .foregroundStyle(.primary)
        }
        .accessibilityElement(children: .combine)
    }
}
