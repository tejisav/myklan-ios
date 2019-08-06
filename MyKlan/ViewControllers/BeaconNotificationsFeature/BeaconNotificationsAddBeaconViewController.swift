//
//  BeaconNotificationsAddBeaconViewController.swift
//  MyKlan
//
//  Created by Tejisav Brar on 2019-07-30.
//  Copyright © 2019 Team Lion. All rights reserved.
//

import UIKit
import MapKit
import Alamofire
import SwiftyJSON

class BeaconNotificationsAddBeaconViewController: AuthTableViewController {
    
    var selectedMembers: [MemberModel] = []
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var radiusTextField: UITextField!
    @IBOutlet weak var onExitSwitch: UISwitch!
    @IBOutlet weak var onEntrySwitch: UISwitch!
    @IBOutlet weak var selectedMembersTextView: UITextView!
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.zoomToUserLocation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !selectedMembers.isEmpty {
            selectedMembersTextView.text = "Selected members are :-"
            for member in selectedMembers {
                selectedMembersTextView.text += "\n\(member.name!)"
            }
        } else {
            selectedMembersTextView.text = nil
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationAuthViewController = segue.destination as! AuthViewController
        destinationAuthViewController.authModelController = authModelController
    }
    
    @IBAction func zoomCurrentPositionButtonTapped(_ sender: Any) {
        mapView.zoomToUserLocation()
    }
    
    @IBAction func saveBeaconButtonTapped(_ sender: Any) {
        if titleTextField.text!.isEmpty || radiusTextField.text!.isEmpty || (!onExitSwitch.isOn && !onEntrySwitch.isOn) || selectedMembers.isEmpty {
            return
        }
        
        self.showSpinner(onView: self.view)
        
        let parameters: Parameters = [
            "userId": authModelController.session.mongoID!,
            "title": titleTextField.text!,
            "latitude": String(mapView.centerCoordinate.latitude),
            "longitude": String(mapView.centerCoordinate.longitude),
            "radius": radiusTextField.text!,
            "members": selectedMembers.map({ (member) -> String in
                return member.id!
            }),
            "onExit": onExitSwitch.isOn,
            "onEntry": onEntrySwitch.isOn
        ]
        
        let headers: HTTPHeaders = [
            "Authorization": authModelController.session.authToken!
        ]
        
        AF.request("https://w4dtt62bhd.execute-api.us-east-1.amazonaws.com/dev/beaconNotifications/addBeacon", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                print(value)
                _ = self.navigationController?.popViewController(animated: true)
            case .failure:
                if let data = response.data {
                    let json = String(data: data, encoding: String.Encoding.utf8)
                    Helpers.showAlert(view: self, title: "Error", message: json!)
                }
                self.removeSpinner()
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 6 {
            let minimalLastCellHeight = 200
            guard let previousCell = tableView.visibleCells.last else {
                return CGFloat(minimalLastCellHeight)
            }
            let lowestYCoordinate = previousCell.frame.maxY // low corner Y coordinate of previous cell
            return max(self.tableView.bounds.size.height - lowestYCoordinate, CGFloat(minimalLastCellHeight))
        }
        return super.tableView(tableView, heightForRowAt: indexPath)
    }
}

extension BeaconNotificationsAddBeaconViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let localSearchRequest = MKLocalSearch.Request()
        localSearchRequest.naturalLanguageQuery = searchBar.text
        let localSearch = MKLocalSearch(request: localSearchRequest)
        localSearch.start { (localSearchResponse, error) -> Void in
            
            if localSearchResponse == nil{
                Helpers.showAlert(view: self, title: "Info", message: "Location not found!")
                return
            }
            
            let coordinate = CLLocationCoordinate2D(latitude: localSearchResponse!.boundingRegion.center.latitude, longitude:     localSearchResponse!.boundingRegion.center.longitude)
            
            let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 100, longitudinalMeters: 100)
            self.mapView.setRegion(region, animated: true)
        }
    }
}
