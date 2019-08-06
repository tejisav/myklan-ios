//
//  SharedSpaceContactsViewController.swift
//  MyKlan
//
//  Created by Tejisav Brar on 2019-07-17.
//  Copyright © 2019 Team Lion. All rights reserved.
//

import UIKit

class SharedSpaceContactsViewController: AuthViewControllerWithSettings {
    
    @IBOutlet weak var addNewContactButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var contacts: [ContactModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addNewContactButton.layer.borderColor = #colorLiteral(red: 0.7490196078, green: 0.4156862745, blue: 0.4431372549, alpha: 1)
        addNewContactButton.layer.borderWidth = 1
        addNewContactButton.layer.cornerRadius = 5
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.showSpinner(onView: self.view)
        
        ContactModelController.getContacts(view: self, completion: { (results) in
            if results != nil {
                self.contacts = results!
                self.tableView.reloadData()
            }
            self.removeSpinner()
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationAuthViewController = segue.destination as! AuthViewController
        destinationAuthViewController.authModelController = authModelController
        
        if segue.identifier == "SharedSpaceEditContactSegue" {
            if let cell = sender as? UITableViewCell,
                let indexPath = self.tableView.indexPath(for: cell) {
                (destinationAuthViewController as! SharedSpaceEditContactViewController).contact = contacts[indexPath.row]
            }
        }
    }
}

extension SharedSpaceContactsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if contacts.isEmpty {
            return 0
        }
        
        return contacts.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactCell") as! CommonTableViewCell
        
        cell.selectionStyle = .none
        
        cell.cellName.text = contacts[indexPath.row].name
        
        return cell
    }
}
