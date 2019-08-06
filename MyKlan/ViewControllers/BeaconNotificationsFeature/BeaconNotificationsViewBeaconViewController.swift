//
//  BeaconNotificationsViewBeaconViewController.swift
//  MyKlan
//
//  Created by Tejisav Brar on 2019-07-30.
//  Copyright © 2019 Team Lion. All rights reserved.
//

import UIKit
import MapKit

class BeaconNotificationsViewBeaconViewController: AuthViewController {
    
    var beacon: BeaconModel!
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let region = MKCoordinateRegion(center: beacon.coordinate!, span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005))
        self.mapView.setRegion(region, animated: true)
        
        let pin = customPin(pinTitle: beacon.title!, pinSubTitle: "", location: beacon.coordinate!)
        self.mapView.addAnnotation(pin)
        
        mapView.addOverlay(MKCircle(center: beacon.coordinate!, radius: beacon.radius!))
    }
    
    @IBAction func zoomCurrentPositionButtonTapped(_ sender: Any) {
        mapView.zoomToUserLocation()
    }
    
}

extension BeaconNotificationsViewBeaconViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "CustomAnnotation")
        annotationView.image = #imageLiteral(resourceName: "beacon-pin-icon-1")
        annotationView.canShowCallout = true
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKCircle {
            let circleRenderer = MKCircleRenderer(overlay: overlay)
            circleRenderer.lineWidth = 1.0
            circleRenderer.strokeColor = .purple
            circleRenderer.fillColor = UIColor.purple.withAlphaComponent(0.4)
            return circleRenderer
        }
        return MKOverlayRenderer(overlay: overlay)
    }
    
}
