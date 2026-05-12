import CoreLocation
import MapKit

extension MKPolyline {
    func lastCoordinate() -> CLLocationCoordinate2D? {
        guard pointCount > 0 else { return nil }
        var coords = [CLLocationCoordinate2D](repeating: kCLLocationCoordinate2DInvalid, count: pointCount)
        getCoordinates(&coords, range: NSRange(location: 0, length: pointCount))
        return coords.last
    }

    func coordinates() -> [CLLocationCoordinate2D] {
        guard pointCount > 0 else { return [] }
        var coords = [CLLocationCoordinate2D](repeating: kCLLocationCoordinate2DInvalid, count: pointCount)
        getCoordinates(&coords, range: NSRange(location: 0, length: pointCount))
        return coords
    }
}

extension CLLocationCoordinate2D {
    func distance(to other: CLLocationCoordinate2D) -> CLLocationDistance {
        let a = CLLocation(latitude: latitude, longitude: longitude)
        let b = CLLocation(latitude: other.latitude, longitude: other.longitude)
        return a.distance(from: b)
    }

    func offset(byMetersNorth metersNorth: Double, metersEast: Double) -> CLLocationCoordinate2D {
        let latDegrees = metersNorth / 111_111
        let lonDegrees = metersEast / (111_111 * cos(latitude * .pi / 180))
        return CLLocationCoordinate2D(latitude: latitude + latDegrees, longitude: longitude + lonDegrees)
    }
}
