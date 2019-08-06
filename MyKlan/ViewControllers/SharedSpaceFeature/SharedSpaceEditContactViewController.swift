//
//  SharedSpaceEditContactViewController.swift
//  MyKlan
//
//  Created by Tejisav Brar on 2019-07-17.
//  Copyright © 2019 Team Lion. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class SharedSpaceEditContactViewController: AuthViewController {
    
    @IBOutlet weak var contactNameTextField: DesignableUITextField!
    @IBOutlet weak var contactNumberTextField: DesignableUITextField!
    @IBOutlet weak var contactInfoTextView: UITextView!
    @IBOutlet weak var deleteContactButton: UIButton!
    
    var contact: ContactModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contactInfoTextView.layer.borderWidth = 1
        contactInfoTextView.layer.borderColor = UIColor.black.cgColor
        deleteContactButton.layer.cornerRadius = 5
        
        contactNameTextField.text = contact.name
        contactNumberTextField.text = contact.number
        
        if contact.info != nil && contact.info != "" {
            contactInfoTextView.text = contact.info
        } else {
            contactInfoTextView.text = "Info (Optional)"
            contactInfoTextView.textColor = UIColor.lightGray
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        removeNavBarBackgroundImage()
        
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        addNavBarBackgroundImage()
        
        super.viewWillDisappear(animated)
    }
    
    @IBAction func saveContactButtonTapped(_ sender: Any) {
        if contactNameTextField.text!.isEmpty || contactNumberTextField.text!.isEmpty {
            return
        }
        
        if contactNameTextField.text! == contact.name && contactNumberTextField.text! == contact.number && (contactInfoTextView.text! == contact.info || ((contact.info == nil || contact.info == "") && (contactInfoTextView.textColor == UIColor.lightGray || contactInfoTextView.text!.isEmpty))) {
            return
        }
        
        self.showSpinner(onView: self.view)
        
        var parameters: Parameters = [
            "contactId": contact.id!
        ]
        
        if contactNameTextField.text! != contact.name {
            parameters["name"] = contactNameTextField.text!
        }
        
        if contactNumberTextField.text! != contact.number {
            parameters["number"] = contactNumberTextField.text!
        }
        
        if (contact.info != nil || contact.info != "") && (contactInfoTextView.textColor == UIColor.lightGray || contactInfoTextView.text!.isEmpty) {
            parameters["info"] = ""
        } else if contactInfoTextView.text! != contact.info && contactInfoTextView.textColor != UIColor.lightGray && !contactInfoTextView.text!.isEmpty {
            parameters["info"] = contactInfoTextView.text!
        }
        
        let headers: HTTPHeaders = [
            "Authorization": authModelController.session.authToken!
        ]
        
        AF.request("https://w4dtt62bhd.execute-api.us-east-1.amazonaws.com/dev/sharedSpace/updateContact", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).validate().responseJSON { response in
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
    
    @IBAction func deleteContactButtonTapped(_ sender: Any) {
        
        self.showSpinner(onView: self.view)
        
        let parameters: Parameters = [
            "contactId": contact.id!
        ]
        
        let headers: HTTPHeaders = [
            "Authorization": authModelController.session.authToken!
        ]
        
        AF.request("https://w4dtt62bhd.execute-api.us-east-1.amazonaws.com/dev/sharedSpace/deleteContact", method: .delete, parameters: parameters, headers: headers).validate().responseJSON { response in
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

extension SharedSpaceEditContactViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if contactInfoTextView.textColor == UIColor.lightGray {
            contactInfoTextView.text = nil
            contactInfoTextView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if contactInfoTextView.text.isEmpty {
            contactInfoTextView.text = "Info (Optional)"
            contactInfoTextView.textColor = UIColor.lightGray
        }
    }
}
