import SwiftUI
import CoreLocation
import UIKit

struct SettingsView: View {
    @ObservedObject var locationService: LocationService
    @Environment(\.openURL) private var openURL

    var body: some View {
        List {
            Section("Permissions") {
                HStack {
                    Text("Location")
                    Spacer()
                    Text(locationStatusText)
                        .foregroundStyle(.secondary)
                }

                Button("Open System Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        openURL(url)
                    }
                }
            }

            Section("Privacy") {
                Text("Live location is only shared during an active navigation session and can be paused or stopped at any time.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            #if DEBUG
            Section("Field Test") {
                LabeledContent("User", value: "\(DemoData.currentUser.name) / \(DemoData.currentUser.id)")
                LabeledContent("Backend", value: AppConfig.backendBaseURL.absoluteString)
            }
            #endif
        }
        .navigationTitle("Settings")
    }

    private var locationStatusText: String {
        switch locationService.authorizationStatus {
        case .authorizedAlways:
            return "Always"
        case .authorizedWhenInUse:
            return "While Using"
        case .denied:
            return "Denied"
        case .restricted:
            return "Restricted"
        case .notDetermined:
            return "Not Asked"
        @unknown default:
            return "Unknown"
        }
    }
}
