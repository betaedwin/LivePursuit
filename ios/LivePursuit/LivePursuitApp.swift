import SwiftUI

@main
struct LivePursuitApp: App {
    init() {
        #if DEBUG
        let arguments = ProcessInfo.processInfo.arguments
        if arguments.contains("-uiTestPRDScreenshots") {
            UserDefaults.standard.set(true, forKey: "simModeEnabled")
            UserDefaults.standard.set(false, forKey: "didShowLocationEducation")
        }
        #endif
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
