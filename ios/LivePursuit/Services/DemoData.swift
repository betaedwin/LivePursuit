import Foundation

enum DemoData {
    static let currentUser = UserProfile(id: AppConfig.currentUserId, name: AppConfig.currentUserName)

    static let contacts: [Contact] = [
        Contact(id: AppConfig.simulatedContactId, name: "Simulated Destination", isSharingEnabled: true, isSimulated: true),
        Contact(id: "user-2", name: "Avery", isSharingEnabled: true),
        Contact(id: "user-3", name: "Jordan", isSharingEnabled: true),
        Contact(id: "user-4", name: "Casey", isSharingEnabled: false),
    ]
}
