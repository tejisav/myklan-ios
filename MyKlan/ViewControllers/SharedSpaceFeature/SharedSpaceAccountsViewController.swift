//
//  SharedSpaceAccountsViewController.swift
//  MyKlan
//
//  Created by Tejisav Brar on 2019-07-17.
//  Copyright © 2019 Team Lion. All rights reserved.
//

import UIKit

class SharedSpaceAccountsViewController: AuthViewControllerWithSettings {
    
    @IBOutlet weak var addNewAccountButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var accounts: [AccountModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addNewAccountButton.layer.borderColor = #colorLiteral(red: 0.7490196078, green: 0.4156862745, blue: 0.4431372549, alpha: 1)
        addNewAccountButton.layer.borderWidth = 1
        addNewAccountButton.layer.cornerRadius = 5
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.showSpinner(onView: self.view)
        
        AccountModelController.getAccounts(view: self, completion: { (results) in
            if results != nil {
                self.accounts = results!
                self.tableView.reloadData()
            }
            self.removeSpinner()
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationAuthViewController = segue.destination as! AuthViewController
        destinationAuthViewController.authModelController = authModelController
        
        if segue.identifier == "SharedSpaceEditAccountSegue" {
            if let cell = sender as? UITableViewCell,
                let indexPath = self.tableView.indexPath(for: cell) {
                (destinationAuthViewController as! SharedSpaceEditAccountViewController).account = accounts[indexPath.row]
            }
        }
    }
}

extension SharedSpaceAccountsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if accounts.isEmpty {
            return 0
        }
        
        return accounts.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "AccountCell") as! CommonTableViewCell
        
        cell.selectionStyle = .none
        
        cell.cellName.text = accounts[indexPath.row].name
        
        return cell
    }
}
