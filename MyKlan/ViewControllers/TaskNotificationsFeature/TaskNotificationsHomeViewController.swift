//
//  TaskNotificationsHomeViewController.swift
//  MyKlan
//
//  Created by Tejisav Brar on 2019-07-17.
//  Copyright © 2019 Team Lion. All rights reserved.
//

import UIKit
import UserNotifications
import Alamofire
import SwiftyJSON

class TaskNotificationsHomeViewController: AuthViewControllerWithSettings {
    
    @IBOutlet weak var addNewTaskButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var tasks: [TaskModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        populateAuthModelControllerFromTabBar()
        
        addNewTaskButton.layer.borderColor = #colorLiteral(red: 0.7490196078, green: 0.4156862745, blue: 0.4431372549, alpha: 1)
        addNewTaskButton.layer.borderWidth = 1
        addNewTaskButton.layer.cornerRadius = 5
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.showSpinner(onView: self.view)
        
        TaskModelController.getTasks(view: self, completion: { (results) in
            if results != nil {
                self.tasks = results!
                self.tableView.reloadData()
            }
            self.removeSpinner()
        })
    }
    
    @objc func taskAlertButtonTapped(_ sender: UIButton!) {
        
        self.showSpinner(onView: self.view)
        
        #if targetEnvironment(simulator)
            let content = UNMutableNotificationContent()
            content.title = tasks[sender.tag].title!
            content.body = tasks[sender.tag].description!
            content.sound = UNNotificationSound.default
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
            let request = UNNotificationRequest(identifier: "TaskNotification", content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        #endif
        
        let parameters: Parameters = [
            "userId": authModelController.session.mongoID!,
            "taskId": tasks[sender.tag].id!
        ]
        
        let headers: HTTPHeaders = [
            "Authorization": authModelController.session.authToken!
        ]
        
        AF.request("https://w4dtt62bhd.execute-api.us-east-1.amazonaws.com/dev/taskNotifications/notifyMembers", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                print(value)
                Helpers.showAlert(view: self, title: "Info", message: "All family members successfully notified!")
            case .failure:
                if let data = response.data {
                    let json = String(data: data, encoding: String.Encoding.utf8)
                    Helpers.showAlert(view: self, title: "Error", message: json!)
                }
            }
            self.removeSpinner()
        }
    }
    
    @objc func taskEditButtonTapped(_ sender: UIButton!) {
        self.performSegue(withIdentifier: "TaskNotificationsEditTaskSegue", sender: sender)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationAuthViewController = segue.destination as! AuthViewController
        destinationAuthViewController.authModelController = authModelController
        
        if segue.identifier == "TaskNotificationsEditTaskSegue" {
            if let button = sender as? UIButton {
                (destinationAuthViewController as! TaskNotificationsEditTaskViewController).task = tasks[button.tag]
            }
        }
    }
}

extension TaskNotificationsHomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tasks.isEmpty {
            return 0
        }
        
        return tasks.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell") as! TaskNotificationsTableViewCell
        
        cell.selectionStyle = .none
        
        cell.taskTitle.text = tasks[indexPath.row].title
        cell.taskAlertButton.tag = indexPath.row
        cell.taskEditButton.tag = indexPath.row
        
        cell.taskAlertButton.addTarget(self, action: #selector(TaskNotificationsHomeViewController.taskAlertButtonTapped(_:)), for: UIControl.Event.touchUpInside)
        
        cell.taskEditButton.addTarget(self, action: #selector(TaskNotificationsHomeViewController.taskEditButtonTapped(_:)), for: UIControl.Event.touchUpInside)
        
        return cell
    }
}
