//
//  BeaconNotificationsSelectMemberViewController.swift
//  MyKlan
//
//  Created by Tejisav Brar on 2019-07-30.
//  Copyright © 2019 Team Lion. All rights reserved.
//

import UIKit

class BeaconNotificationsSelectMemberViewController: AuthViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var members: [MemberModel] = []
    var selectedMembers: [MemberModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.showSpinner(onView: self.view)
        
        MemberModelController.getMembers(view: self, completion: { (results) in
            if results != nil {
                self.members = results!
                self.tableView.reloadData()
            }
            self.removeSpinner()
        })
        
        super.viewWillAppear(animated)
    }
    
    
    @IBAction func returnSelectedMembersButtonTapped(_ sender: Any) {
        if selectedMembers.isEmpty {
            return
        }
        
        let count = self.navigationController?.viewControllers.count;
        (self.navigationController?.viewControllers[count! - 2] as! BeaconNotificationsAddBeaconViewController).selectedMembers = selectedMembers
        _ = self.navigationController?.popViewController(animated: true)
    }
}


extension BeaconNotificationsSelectMemberViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if members.isEmpty {
            return 0
        }
        
        return members.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "BeaconNotificationsMemberCell") as! BeaconNotificationsMembersTableViewCell
        
        cell.selectionStyle = .none
        cell.memberAvatar.roundedImage()
        
        cell.memberName.text = members[indexPath.row].name
        if members[indexPath.row].avatar != nil {
            cell.memberAvatar.image = members[indexPath.row].avatar
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! BeaconNotificationsMembersTableViewCell
        if cell.memberSelectedCheckmark.isHighlighted {
            selectedMembers.removeAll { (selectedMember) -> Bool in
                selectedMember.id == members[indexPath.row].id
            }
            cell.memberSelectedCheckmark.isHighlighted = false
        } else {
            selectedMembers.append(members[indexPath.row])
            cell.memberSelectedCheckmark.isHighlighted = true
        }
    }
    
}
