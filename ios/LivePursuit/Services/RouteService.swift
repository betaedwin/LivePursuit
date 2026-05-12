import Foundation
import MapKit

final class RouteService {
    func calculateRoute(from origin: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D) async throws -> MKRoute {
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: origin))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destination))
        request.transportType = .automobile

        let directions = MKDirections(request: request)
        let response = try await directions.calculate()
        guard let route = response.routes.first else {
            throw NSError(domain: "RouteService", code: 0, userInfo: [NSLocalizedDescriptionKey: "No routes available"])
        }
        return route
    }
}
