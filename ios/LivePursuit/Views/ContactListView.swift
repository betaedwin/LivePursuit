import SwiftUI

struct ContactListView: View {
    @StateObject private var viewModel: NavigatorViewModel
    @AppStorage("simModeEnabled") private var simModeEnabled = false

    init(viewModel: NavigatorViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            List {
                if simModeEnabled, let simulated = DemoData.contacts.first(where: { $0.isSimulated }) {
                    Section("Sim Mode") {
                        NavigationLink {
                            NavigatorView(viewModel: viewModel, contact: simulated)
                        } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(simulated.name)
                                    .font(.headline)
                                Text("Run deterministic navigation scenarios")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.vertical, 6)
                        }
                    }
                }

                Section("Active Location Sharing") {
                    ForEach(DemoData.contacts.filter { $0.isSharingEnabled && !$0.isSimulated }) { contact in
                        NavigationLink {
                            NavigatorView(viewModel: viewModel, contact: contact)
                        } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(contact.name)
                                    .font(.headline)
                                Text("Navigate to \(contact.name)")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.vertical, 6)
                        }
                    }
                }

                Section("Not Sharing") {
                    ForEach(DemoData.contacts.filter { !$0.isSharingEnabled }) { contact in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(contact.name)
                                    .font(.headline)
                                Text("Location sharing is disabled")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Image(systemName: "lock.slash")
                                .foregroundStyle(.tertiary)
                        }
                        .padding(.vertical, 6)
                    }
                }
            }
            .navigationTitle("Choose a Contact")
        }
    }
}
