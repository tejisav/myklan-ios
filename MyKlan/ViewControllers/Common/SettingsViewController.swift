//
//  SettingsViewController.swift
//  MyKlan
//
//  Created by Tejisav Brar on 2019-07-16.
//  Copyright © 2019 Team Lion. All rights reserved.
//

import UIKit

class SettingsViewController: AuthViewController {
    
    @IBOutlet weak var chooseMemberButton: UIButton!
    @IBOutlet weak var logOutButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        logOutButton.layer.cornerRadius = 5
        chooseMemberButton.layer.cornerRadius = 5
    }
    
    @IBAction func logOutButtonTapped(_ sender: Any) {
        authModelController.onLogout(view: self)
    }
    
    @IBAction func chooseMemberButtonTapped(_ sender: Any) {
        authModelController.onChooseMember(view: self)
    }
}
