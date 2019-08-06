//
//  SharedSpaceHomeViewController.swift
//  MyKlan
//
//  Created by Tejisav Brar on 2019-07-16.
//  Copyright © 2019 Team Lion. All rights reserved.
//

import UIKit

class SharedSpaceHomeViewController: AuthViewControllerWithSettings {
    
    var items: [MemberModel] = [
        MemberModel(id: "0", name: "Accounts", avatar: #imageLiteral(resourceName: "account-icon")),
        MemberModel(id: "1", name: "Contacts", avatar: #imageLiteral(resourceName: "phone-icon"))
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        populateAuthModelControllerFromTabBar()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationAuthViewController = segue.destination as! AuthViewController
        destinationAuthViewController.authModelController = authModelController
    }
}

extension SharedSpaceHomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MemberCell") as! MemberTableViewCell
        
        cell.selectionStyle = .none
        
        cell.memberName.text = items[indexPath.row].name
        cell.memberAvatar.image = items[indexPath.row].avatar
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var segue: String!
        
        if items[indexPath.row].id == "0" {
            segue = "SharedSpaceAccountsSegue"
        } else if items[indexPath.row].id == "1" {
            segue = "SharedSpaceContactsSegue"
        }
        
        self.performSegue(withIdentifier: segue, sender: self)
    }
}
