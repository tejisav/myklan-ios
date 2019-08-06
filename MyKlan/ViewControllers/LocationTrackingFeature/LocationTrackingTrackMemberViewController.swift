//
//  LocationTrackingTrackMemberViewController.swift
//  MyKlan
//
//  Created by Tejisav Brar on 2019-07-25.
//  Copyright © 2019 Team Lion. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import MapKit

class customPin: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    
    init(pinTitle:String, pinSubTitle:String, location:CLLocationCoordinate2D) {
        self.title = pinTitle
        self.subtitle = pinSubTitle
        self.coordinate = location
    }
}

class LocationTrackingTrackMemberViewController: AuthViewController {
    
    var member: MemberModel!
    
    @IBOutlet weak var mapView: MKMapView!
    
    var region: MKCoordinateRegion?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.getMemberLocation()
    }
    
    func getMemberLocation() {
        let headers: HTTPHeaders = [
            "Authorization": self.authModelController.session.authToken!
        ]
        
        let parameters: Parameters = [
            "memberId": member.id!
        ]
        
        AF.request("https://w4dtt62bhd.execute-api.us-east-1.amazonaws.com/dev/locationTracking/getLocation", parameters: parameters, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                print(value)
                let json = JSON(value)
                if json["latitude"].exists() && json["longitude"].exists() && json["lastLocationUpdate"].exists() {
                    let location = CLLocationCoordinate2D(latitude: json["latitude"].doubleValue, longitude: json["longitude"].doubleValue)
                    
                    self.region = MKCoordinateRegion(center: location, span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005))
                    self.mapView.setRegion(self.region!, animated: true)
                    
                    let pin = customPin(pinTitle: self.member.name!, pinSubTitle: json["lastLocationUpdate"].stringValue, location: location)
                    self.mapView.addAnnotation(pin)
                } else {
                    _ = self.navigationController?.popViewController(animated: true)
                    Helpers.showAlert(view: self, title: "Error", message: "Unable to get member's location.")
                }
            case .failure:
                if let data = response.data {
                    let json = String(data: data, encoding: String.Encoding.utf8)
                    print(json!)
                }
                _ = self.navigationController?.popViewController(animated: true)
                Helpers.showAlert(view: self, title: "Error", message: "Unable to get member's location.")
            }
        }
    }
    
    @IBAction func currentLocationButtonTapped(_ sender: Any) {
        self.mapView.setRegion(self.region!, animated: true)
    }
    
}

extension LocationTrackingTrackMemberViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "customannotation")
        annotationView.image = #imageLiteral(resourceName: "map-pin-icon")
        annotationView.canShowCallout = true
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        print("annotation title == \(String(describing: view.annotation?.title!))")
    }
    
}
