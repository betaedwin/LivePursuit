import CoreLocation
import Foundation

final class LocationService: NSObject, ObservableObject {
    @Published private(set) var authorizationStatus: CLAuthorizationStatus
    @Published private(set) var lastLocation: CLLocation?
    @Published private(set) var lastLocationTimestamp: Date?

    private let manager: CLLocationManager
    private var isSimulating = false
    private var shouldStartUpdatesAfterAuthorization = false

    override init() {
        manager = CLLocationManager()
        authorizationStatus = manager.authorizationStatus
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = 10
        manager.allowsBackgroundLocationUpdates = false
        manager.pausesLocationUpdatesAutomatically = true
    }

    func requestPermission() {
        switch authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedAlways, .authorizedWhenInUse:
            break
        case .denied, .restricted:
            break
        @unknown default:
            break
        }
    }

    func startUpdates() {
        switch authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            shouldStartUpdatesAfterAuthorization = false
            manager.startUpdatingLocation()
        case .notDetermined:
            shouldStartUpdatesAfterAuthorization = true
            manager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            shouldStartUpdatesAfterAuthorization = false
        @unknown default:
            shouldStartUpdatesAfterAuthorization = false
        }
    }

    func stopUpdates() {
        shouldStartUpdatesAfterAuthorization = false
        manager.stopUpdatingLocation()
    }

    func setSimulatedLocation(_ location: CLLocation) {
        isSimulating = true
        lastLocation = location
        lastLocationTimestamp = Date()
    }

    func stopSimulation() {
        isSimulating = false
    }
}

extension LocationService: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        if shouldStartUpdatesAfterAuthorization &&
            (manager.authorizationStatus == .authorizedWhenInUse || manager.authorizationStatus == .authorizedAlways) {
            shouldStartUpdatesAfterAuthorization = false
            manager.startUpdatingLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard !isSimulating else { return }
        guard let latest = locations.last else { return }
        lastLocation = latest
        lastLocationTimestamp = Date()
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
    }
}
