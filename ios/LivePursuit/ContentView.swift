import SwiftUI

struct ContentView: View {
    @StateObject private var locationService = LocationService()
    @AppStorage("simModeEnabled") private var simModeEnabled = false

    var body: some View {
        NavigationStack {
            List {
                #if DEBUG
                Section("Developer") {
                    Toggle("Simulation Mode", isOn: $simModeEnabled)
                }
                #endif

                NavigationLink {
                    ContactListView(viewModel: NavigatorViewModel(locationService: locationService, navigator: DemoData.currentUser))
                } label: {
                    Label("Navigate to a Contact", systemImage: "map")
                }

                NavigationLink {
                    SharingStatusView(viewModel: SharingStatusViewModel(locationService: locationService, user: DemoData.currentUser))
                } label: {
                    Label("Share My Location", systemImage: "location.circle")
                }

                NavigationLink {
                    SettingsView(locationService: locationService)
                } label: {
                    Label("Settings", systemImage: "gear")
                }
            }
            .navigationTitle("Live Pursuit")
        }
    }
}
