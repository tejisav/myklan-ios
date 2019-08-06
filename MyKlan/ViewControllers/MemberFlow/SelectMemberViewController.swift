//
//  SelectMemberViewController.swift
//  MyKlan
//
//  Created by Tejisav Brar on 2019-07-04.
//  Copyright © 2019 Team Lion. All rights reserved.
//

import UIKit

class SelectMemberViewController: AuthViewController {
    
    @IBOutlet weak var familyName: UILabel!
    @IBOutlet weak var addMemberButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var members: [MemberModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        familyName.text = authModelController.session.familyName
        
        addMemberButton.layer.borderColor = #colorLiteral(red: 0.7490196078, green: 0.4156862745, blue: 0.4431372549, alpha: 1)
        addMemberButton.layer.borderWidth = 1
        addMemberButton.layer.cornerRadius = 5
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        
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
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        
        super.viewWillDisappear(animated)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddMemberSegue" {
            let addMemberViewController = segue.destination as! AddMemberViewController
            
            addMemberViewController.authModelController = authModelController
        }
    }
}


extension SelectMemberViewController: UITableViewDelegate, UITableViewDataSource {
    
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        authModelController.session.memberMongoID = members[indexPath.row].id
        authModelController.session.memberName = members[indexPath.row].name
        authModelController.store()
        
        authModelController.session.memberDeviceToken = nil
        authModelController.requestAuthorization()
        
        let mainNavigationStoryBoard: UIStoryboard = UIStoryboard(name: "MainNavigation", bundle: nil)
        let mainTabBarController = mainNavigationStoryBoard.instantiateInitialViewController() as! UITabBarController
        let memberHomeNavigationController = mainTabBarController.viewControllers?.first as! UINavigationController
        let mainHomeViewController = memberHomeNavigationController.topViewController as! MainHomeViewController
        mainHomeViewController.authModelController = self.authModelController
        self.present(mainTabBarController, animated: true, completion: nil)
    }
    
    
//    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
//        return true
//    }
//
//
//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
//
//        if editingStyle == .delete {
//            videos.remove(at: indexPath.row)
//
//            tableView.beginUpdates()
//            tableView.deleteRows(at: [indexPath], with: .automatic)
//            tableView.endUpdates()
//        }
//    }
}
