//
//  BeaconNotificationsHomeViewController.swift
//  MyKlan
//
//  Created by Tejisav Brar on 2019-07-30.
//  Copyright © 2019 Team Lion. All rights reserved.
//

import UIKit
import UserNotifications
import Alamofire
import SwiftyJSON

class BeaconNotificationsHomeViewController: AuthViewControllerWithSettings {
    
    @IBOutlet weak var addNewBeaconButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var beacons: [BeaconModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        populateAuthModelControllerFromTabBar()
        
        addNewBeaconButton.layer.borderColor = #colorLiteral(red: 0.7490196078, green: 0.4156862745, blue: 0.4431372549, alpha: 1)
        addNewBeaconButton.layer.borderWidth = 1
        addNewBeaconButton.layer.cornerRadius = 5
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.showSpinner(onView: self.view)

        BeaconModelController.getBeacons(view: self, completion: { (results) in
            if results != nil {
                self.beacons = results!
                self.authModelController.startMonitoringRegions(beacons: results!)
                self.tableView.reloadData()
            }
            self.removeSpinner()
        })
    }
    
    @objc func deleteBeaconButtonTapped(_ sender: UIButton!) {
        
        self.showSpinner(onView: self.view)
        
        let parameters: Parameters = [
            "beaconId": beacons[sender.tag].id!
        ]
        
        let headers: HTTPHeaders = [
            "Authorization": authModelController.session.authToken!
        ]
        
        AF.request("https://w4dtt62bhd.execute-api.us-east-1.amazonaws.com/dev/beaconNotifications/deleteBeacon", method: .delete, parameters: parameters, headers: headers).validate().responseJSON { response in
            
            switch response.result {
            case .success(let value):
                print(value)
                
                BeaconModelController.getBeacons(view: self, completion: { (results) in
                    if results != nil {
                        self.beacons = results!
                        self.authModelController.startMonitoringRegions(beacons: results!)
                        self.tableView.reloadData()
                    }
                    self.removeSpinner()
                })
            case .failure:
                if let data = response.data {
                    let json = String(data: data, encoding: String.Encoding.utf8)
                    Helpers.showAlert(view: self, title: "Error", message: json!)
                }
                self.removeSpinner()
            }
        }
    }
    
    @objc func viewBeaconButtonTapped(_ sender: UIButton!) {
        self.performSegue(withIdentifier: "BeaconNotificationsViewBeaconSegue", sender: sender)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "BeaconNotificationsViewBeaconSegue" {
            if let button = sender as? UIButton {
                let beaconNotificationsViewBeaconViewController = segue.destination as! BeaconNotificationsViewBeaconViewController
                beaconNotificationsViewBeaconViewController.authModelController = authModelController
                beaconNotificationsViewBeaconViewController.beacon = beacons[button.tag]
            }
        } else {
            let destinationAuthTableViewController = segue.destination as! AuthTableViewController
            destinationAuthTableViewController.authModelController = authModelController
        }
    }
}

extension BeaconNotificationsHomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if beacons.isEmpty {
            return 0
        }
        
        return beacons.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "BeaconCell") as! BeaconNotificationsTableViewCell
        
        cell.selectionStyle = .none
        
        cell.beaconTitle.text = beacons[indexPath.row].title
        cell.ViewBeaconButton.tag = indexPath.row
        cell.deleteBeaconButton.tag = indexPath.row
        
        cell.ViewBeaconButton.addTarget(self, action: #selector(BeaconNotificationsHomeViewController.viewBeaconButtonTapped(_:)), for: UIControl.Event.touchUpInside)
        
        cell.deleteBeaconButton.addTarget(self, action: #selector(BeaconNotificationsHomeViewController.deleteBeaconButtonTapped(_:)), for: UIControl.Event.touchUpInside)
        
        return cell
    }
}
