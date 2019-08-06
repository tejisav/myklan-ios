//
//  AuthViewControllerWithSettings.swift
//  MyKlan
//
//  Created by Tejisav Brar on 2019-07-16.
//  Copyright © 2019 Team Lion. All rights reserved.
//

import UIKit

class AuthViewControllerWithSettings: AuthViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addNavBarRightButton()
    }
    
    func populateAuthModelControllerFromTabBar() {
        let firstNavigationController = self.tabBarController?.viewControllers?.first as! UINavigationController
        let firstAuthViewController = firstNavigationController.topViewController as! AuthViewController
        
        self.authModelController = firstAuthViewController.authModelController
    }
    
    func addNavBarRightButton() {
        let image = #imageLiteral(resourceName: "settings-icon")
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: image.aspectFittedToHeight(image.size.height - 10), style: .plain, target: self, action: #selector(settingsButtonTapped(sender:)))
    }
    
    @objc func settingsButtonTapped(sender: UIBarButtonItem) {
        let mainfeaturesStoryBoard: UIStoryboard = UIStoryboard(name: "MemberHome", bundle: nil)
        let settingsViewController = mainfeaturesStoryBoard.instantiateViewController(withIdentifier: "SettingsViewController") as! SettingsViewController
        settingsViewController.authModelController = authModelController
        self.navigationController?.pushViewController(settingsViewController, animated: true)
    }
}
