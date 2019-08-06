//
//  TaskNotificationsEditTaskViewController.swift
//  MyKlan
//
//  Created by Tejisav Brar on 2019-07-17.
//  Copyright © 2019 Team Lion. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class TaskNotificationsEditTaskViewController: AuthViewController {
    
    @IBOutlet weak var taskTitleTextField: DesignableUITextField!
    @IBOutlet weak var taskDescriptionTextView: UITextView!
    @IBOutlet weak var deleteTaskButton: UIButton!
    
    var task: TaskModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        taskDescriptionTextView.layer.borderWidth = 1
        taskDescriptionTextView.layer.borderColor = UIColor.black.cgColor
        deleteTaskButton.layer.cornerRadius = 5
        
        taskTitleTextField.text = task.title
        taskDescriptionTextView.text = task.description
    }
    
    override func viewWillAppear(_ animated: Bool) {
        removeNavBarBackgroundImage()
        
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        addNavBarBackgroundImage()
        
        super.viewWillDisappear(animated)
    }
    
    @IBAction func saveTaskButtonTapped(_ sender: Any) {
        if taskTitleTextField.text!.isEmpty || taskDescriptionTextView.text!.isEmpty || taskDescriptionTextView.textColor == UIColor.lightGray {
            return
        }
        
        if taskTitleTextField.text! == task.title && taskDescriptionTextView.text! == task.description {
            return
        }
        
        self.showSpinner(onView: self.view)
        
        var parameters: Parameters = [
            "taskId": task.id!
        ]
        
        if taskTitleTextField.text! != task.title {
            parameters["title"] = taskTitleTextField.text!
        }
        
        if taskDescriptionTextView.text! != task.description {
            parameters["description"] = taskDescriptionTextView.text!
        }
        
        let headers: HTTPHeaders = [
            "Authorization": authModelController.session.authToken!
        ]
        
        AF.request("https://w4dtt62bhd.execute-api.us-east-1.amazonaws.com/dev/taskNotifications/updateTask", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                print(value)
                _ = self.navigationController?.popViewController(animated: true)
            case .failure:
                if let data = response.data {
                    let json = String(data: data, encoding: String.Encoding.utf8)
                    Helpers.showAlert(view: self, title: "Error", message: json!)
                }
                self.removeSpinner()
            }
        }
    }
    
    @IBAction func deleteTaskButtonTapped(_ sender: Any) {
        
        self.showSpinner(onView: self.view)
        
        let parameters: Parameters = [
            "taskId": task.id!
        ]
        
        let headers: HTTPHeaders = [
            "Authorization": authModelController.session.authToken!
        ]
        
        AF.request("https://w4dtt62bhd.execute-api.us-east-1.amazonaws.com/dev/taskNotifications/deleteTask", method: .delete, parameters: parameters, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                print(value)
                _ = self.navigationController?.popViewController(animated: true)
            case .failure:
                if let data = response.data {
                    let json = String(data: data, encoding: String.Encoding.utf8)
                    Helpers.showAlert(view: self, title: "Error", message: json!)
                }
                self.removeSpinner()
            }
        }
    }
}

extension TaskNotificationsEditTaskViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if taskDescriptionTextView.textColor == UIColor.lightGray {
            taskDescriptionTextView.text = nil
            taskDescriptionTextView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if taskDescriptionTextView.text.isEmpty {
            taskDescriptionTextView.text = "Description"
            taskDescriptionTextView.textColor = UIColor.lightGray
        }
    }
}
