import Foundation

struct Contact: Identifiable, Hashable {
    let id: String
    let name: String
    let isSharingEnabled: Bool
    let isSimulated: Bool

    init(id: String, name: String, isSharingEnabled: Bool, isSimulated: Bool = false) {
        self.id = id
        self.name = name
        self.isSharingEnabled = isSharingEnabled
        self.isSimulated = isSimulated
    }
}
