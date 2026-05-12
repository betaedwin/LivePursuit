import SwiftUI
import UIKit

struct ContactListView: View {
    @StateObject private var viewModel: NavigatorViewModel
    @StateObject private var phoneContactsViewModel = PhoneContactsViewModel()
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

                Section("Phone Contacts") {
                    phoneContactsContent
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
            .onAppear {
                phoneContactsViewModel.refreshIfAuthorized()
            }
        }
    }

    @ViewBuilder
    private var phoneContactsContent: some View {
        switch phoneContactsViewModel.state {
        case .notDetermined:
            Button {
                phoneContactsViewModel.requestAccess()
            } label: {
                Label("Use Phone Contacts", systemImage: "person.crop.circle.badge.plus")
            }
        case .loading:
            HStack {
                ProgressView()
                Text("Loading contacts")
                    .foregroundStyle(.secondary)
            }
        case .authorized:
            if phoneContactsViewModel.contacts.isEmpty {
                Text("No contacts found")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(phoneContactsViewModel.contacts) { phoneContact in
                    let contact = phoneContactsViewModel.liveDestinationContact(from: phoneContact)
                    NavigationLink {
                        NavigatorView(viewModel: viewModel, contact: contact)
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(phoneContact.displayName)
                                .font(.headline)
                            Text("Navigate to \(phoneContact.displayName)")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 6)
                    }
                }
            }
        case .denied, .restricted:
            VStack(alignment: .leading, spacing: 8) {
                Text("Contacts access needed")
                    .font(.headline)
                Text("Enable Contacts access in Settings to pick a real contact for field testing.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Button("Open Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
            }
            .padding(.vertical, 6)
        case .failed(let message):
            VStack(alignment: .leading, spacing: 4) {
                Text("Unable to load contacts")
                    .font(.headline)
                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 6)
        }
    }
}
