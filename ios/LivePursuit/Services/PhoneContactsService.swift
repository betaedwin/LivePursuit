import Contacts
import Foundation

struct PhoneContact: Identifiable, Hashable {
    let id: String
    let displayName: String
}

enum PhoneContactsState: Equatable {
    case notDetermined
    case loading
    case authorized
    case denied
    case restricted
    case failed(String)
}

@MainActor
final class PhoneContactsViewModel: ObservableObject {
    @Published private(set) var state: PhoneContactsState = .notDetermined
    @Published private(set) var contacts: [PhoneContact] = []

    private let store = CNContactStore()

    init() {
        refreshAuthorizationState()
        if state == .authorized {
            loadContacts()
        }
    }

    func requestAccess() {
        let status = CNContactStore.authorizationStatus(for: .contacts)
        switch status {
        case .authorized:
            state = .authorized
            loadContacts()
        case .notDetermined:
            state = .loading
            store.requestAccess(for: .contacts) { [weak self] granted, error in
                Task { @MainActor in
                    guard let self else { return }
                    if let error {
                        self.state = .failed(error.localizedDescription)
                    } else if granted {
                        self.state = .authorized
                        self.loadContacts()
                    } else {
                        self.refreshAuthorizationState()
                    }
                }
            }
        case .denied:
            state = .denied
        case .restricted:
            state = .restricted
        case .limited:
            state = .authorized
            loadContacts()
        @unknown default:
            state = .failed("Unknown Contacts permission state")
        }
    }

    func refreshIfAuthorized() {
        refreshAuthorizationState()
        if state == .authorized {
            loadContacts()
        }
    }

    func liveDestinationContact(from phoneContact: PhoneContact) -> Contact {
        Contact(id: "user-2", name: phoneContact.displayName, isSharingEnabled: true)
    }

    private func refreshAuthorizationState() {
        switch CNContactStore.authorizationStatus(for: .contacts) {
        case .notDetermined:
            state = .notDetermined
        case .authorized, .limited:
            state = .authorized
        case .denied:
            state = .denied
        case .restricted:
            state = .restricted
        @unknown default:
            state = .failed("Unknown Contacts permission state")
        }
    }

    private func loadContacts() {
        state = .loading
        let keys: [CNKeyDescriptor] = [
            CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
            CNContactIdentifierKey as CNKeyDescriptor,
            CNContactGivenNameKey as CNKeyDescriptor,
            CNContactFamilyNameKey as CNKeyDescriptor,
            CNContactOrganizationNameKey as CNKeyDescriptor,
        ]
        let request = CNContactFetchRequest(keysToFetch: keys)
        var fetchedContacts: [PhoneContact] = []

        do {
            try store.enumerateContacts(with: request) { contact, _ in
                let formattedName = CNContactFormatter.string(from: contact, style: .fullName)
                let fallbackName = contact.organizationName
                let rawName: String
                if let formattedName, !formattedName.isEmpty {
                    rawName = formattedName
                } else {
                    rawName = fallbackName
                }
                let displayName = rawName.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !displayName.isEmpty else { return }
                fetchedContacts.append(PhoneContact(id: contact.identifier, displayName: displayName))
            }

            contacts = fetchedContacts.sorted {
                $0.displayName.localizedStandardCompare($1.displayName) == .orderedAscending
            }
            state = .authorized
        } catch {
            contacts = []
            state = .failed(error.localizedDescription)
        }
    }
}
