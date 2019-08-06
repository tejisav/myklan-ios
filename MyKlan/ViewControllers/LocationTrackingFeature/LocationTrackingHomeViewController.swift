//
//  LocationTrackingHomeViewController.swift
//  MyKlan
//
//  Created by Tejisav Brar on 2019-07-25.
//  Copyright © 2019 Team Lion. All rights reserved.
//

import UIKit

class LocationTrackingHomeViewController: AuthViewControllerWithSettings {
    
    @IBOutlet weak var tableView: UITableView!
    
    var members: [MemberModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        populateAuthModelControllerFromTabBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.showSpinner(onView: self.view)
        
        MemberModelController.getMembers(view: self, completion: { (results) in
            if results != nil {
                self.members = results!.filter { $0.id != self.authModelController.session.memberMongoID }
                self.tableView.reloadData()
            }
            self.removeSpinner()
        })
        
        super.viewWillAppear(animated)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "TrackMemberSegue" {
            let locationTrackingTrackMemberViewController = segue.destination as! LocationTrackingTrackMemberViewController
            locationTrackingTrackMemberViewController.authModelController = authModelController
            
            if let cell = sender as? UITableViewCell,
                let indexPath = self.tableView.indexPath(for: cell) {
                locationTrackingTrackMemberViewController.member = members[indexPath.row]
            }
        }
    }
}


extension LocationTrackingHomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if members.isEmpty {
            return 0
        }
        
        return members.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MemberCell") as! MemberTableViewCell
        
        cell.selectionStyle = .none
        cell.memberAvatar.roundedImage()
        
        cell.memberName.text = members[indexPath.row].name
        if members[indexPath.row].avatar != nil {
            cell.memberAvatar.image = members[indexPath.row].avatar
        }
        
        return cell
    }
    
}
