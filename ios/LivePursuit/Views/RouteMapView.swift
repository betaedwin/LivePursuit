import MapKit
import SwiftUI

struct RouteMapView: UIViewRepresentable {
    let route: MKRoute?
    let destinationCoordinate: CLLocationCoordinate2D?
    let navigatorCoordinate: CLLocationCoordinate2D?
    let destinationStyle: DestinationMarkerStyle
    let showsUserLocation: Bool
    let highlightReroute: Bool

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = showsUserLocation
        mapView.userTrackingMode = showsUserLocation ? .follow : .none
        mapView.pointOfInterestFilter = .excludingAll
        return mapView
    }

    func updateUIView(_ mapView: MKMapView, context: Context) {
        context.coordinator.highlightReroute = highlightReroute
        mapView.showsUserLocation = showsUserLocation
        mapView.userTrackingMode = showsUserLocation ? .follow : .none
        mapView.removeOverlays(mapView.overlays)
        mapView.removeAnnotations(mapView.annotations)

        if let route {
            mapView.addOverlay(route.polyline)
            context.coordinator.updateVisibleRegion(for: route, in: mapView)
        }

        if let destinationCoordinate {
            let annotation = DestinationAnnotation(
                coordinate: destinationCoordinate,
                title: destinationStyle == .pursuit ? "Pursuit Unit" : "Destination",
                isPursuit: destinationStyle == .pursuit
            )
            mapView.addAnnotation(annotation)
        }

        if let navigatorCoordinate {
            let annotation = NavigatorAnnotation(
                coordinate: navigatorCoordinate,
                title: "Navigator"
            )
            mapView.addAnnotation(annotation)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    final class Coordinator: NSObject, MKMapViewDelegate {
        var highlightReroute = false
        private var lastRouteIdentifier: ObjectIdentifier?

        func updateVisibleRegion(for route: MKRoute, in mapView: MKMapView) {
            let identifier = ObjectIdentifier(route.polyline)
            guard identifier != lastRouteIdentifier else { return }
            lastRouteIdentifier = identifier
            mapView.setVisibleMapRect(
                route.polyline.boundingMapRect,
                edgePadding: UIEdgeInsets(top: 80, left: 40, bottom: 180, right: 40),
                animated: true
            )
        }

        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polyline = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(polyline: polyline)
                renderer.strokeColor = highlightReroute ? UIColor.systemGreen : UIColor.systemBlue
                renderer.lineWidth = 6
                renderer.lineCap = .round
                return renderer
            }
            return MKOverlayRenderer(overlay: overlay)
        }

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if annotation is MKUserLocation {
                return nil
            }
            if let destination = annotation as? DestinationAnnotation {
                let identifier = "DestinationMarker"
                let view = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
                    ?? MKMarkerAnnotationView(annotation: destination, reuseIdentifier: identifier)
                view.annotation = destination
                view.canShowCallout = true
                view.markerTintColor = destination.isPursuit ? UIColor.systemRed : UIColor.systemBlue
                view.glyphImage = UIImage(systemName: destination.isPursuit ? "shield.lefthalf.filled" : "mappin.and.ellipse")
                view.glyphTintColor = .white
                view.displayPriority = .required
                return view
            }
            if let navigator = annotation as? NavigatorAnnotation {
                let identifier = "NavigatorMarker"
                let view = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
                    ?? MKMarkerAnnotationView(annotation: navigator, reuseIdentifier: identifier)
                view.annotation = navigator
                view.canShowCallout = true
                view.markerTintColor = UIColor.systemTeal
                view.glyphImage = UIImage(systemName: "car.fill")
                view.glyphTintColor = .white
                view.displayPriority = .required
                return view
            }
            return nil
        }
    }
}

enum DestinationMarkerStyle {
    case standard
    case pursuit
}

final class DestinationAnnotation: NSObject, MKAnnotation {
    let coordinate: CLLocationCoordinate2D
    let title: String?
    let isPursuit: Bool

    init(coordinate: CLLocationCoordinate2D, title: String, isPursuit: Bool) {
        self.coordinate = coordinate
        self.title = title
        self.isPursuit = isPursuit
        super.init()
    }
}

final class NavigatorAnnotation: NSObject, MKAnnotation {
    let coordinate: CLLocationCoordinate2D
    let title: String?

    init(coordinate: CLLocationCoordinate2D, title: String) {
        self.coordinate = coordinate
        self.title = title
        super.init()
    }
}
