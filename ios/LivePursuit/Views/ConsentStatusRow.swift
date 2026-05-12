import SwiftUI

struct ConsentStatusRow: View {
    let title: String
    let statusText: String
    let primaryActionTitle: String
    let primaryActionRole: ButtonRole?
    let primaryAction: () -> Void
    let secondaryActionTitle: String?
    let secondaryActionRole: ButtonRole?
    let secondaryAction: (() -> Void)?

    init(
        title: String,
        statusText: String,
        primaryActionTitle: String,
        primaryActionRole: ButtonRole? = nil,
        primaryAction: @escaping () -> Void,
        secondaryActionTitle: String? = nil,
        secondaryActionRole: ButtonRole? = nil,
        secondaryAction: (() -> Void)? = nil
    ) {
        self.title = title
        self.statusText = statusText
        self.primaryActionTitle = primaryActionTitle
        self.primaryActionRole = primaryActionRole
        self.primaryAction = primaryAction
        self.secondaryActionTitle = secondaryActionTitle
        self.secondaryActionRole = secondaryActionRole
        self.secondaryAction = secondaryAction
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(statusText)
                    .font(.body)
                    .foregroundStyle(.primary)
            }

            HStack(spacing: 12) {
                Button(role: primaryActionRole, action: primaryAction) {
                    Text(primaryActionTitle)
                        .frame(minHeight: 44)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(primaryActionRole == .destructive ? .red : .accentColor)

                if let secondaryActionTitle, let secondaryAction {
                    Button(role: secondaryActionRole, action: secondaryAction) {
                        Text(secondaryActionTitle)
                            .frame(minHeight: 44)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .tint(secondaryActionRole == .destructive ? .red : .accentColor)
                }
            }
        }
        .padding(12)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .accessibilityElement(children: .contain)
    }
}
