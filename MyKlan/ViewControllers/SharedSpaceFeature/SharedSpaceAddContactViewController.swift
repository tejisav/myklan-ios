//
//  SharedSpaceAddContactViewController.swift
//  MyKlan
//
//  Created by Tejisav Brar on 2019-07-17.
//  Copyright © 2019 Team Lion. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import ContactsUI

class SharedSpaceAddContactViewController: AuthViewController {
    
    @IBOutlet weak var contactNameTextField: DesignableUITextField!
    @IBOutlet weak var contactNumberTextField: DesignableUITextField!
    @IBOutlet weak var contactInfoTextView: UITextView!
    @IBOutlet weak var importContactButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contactInfoTextView.layer.borderWidth = 1
        contactInfoTextView.layer.borderColor = UIColor.black.cgColor
        importContactButton.layer.cornerRadius = 5
        importContactButton.layer.borderColor = #colorLiteral(red: 0.7490196078, green: 0.4156862745, blue: 0.4431372549, alpha: 1)
        importContactButton.layer.borderWidth = 1
        contactInfoTextView.text = "Info (Optional)"
        contactInfoTextView.textColor = UIColor.lightGray
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
        
        self.showSpinner(onView: self.view)
        
        var parameters: Parameters = [
            "userId": authModelController.session.mongoID!,
            "name": contactNameTextField.text!,
            "number": contactNumberTextField.text!
        ]
        
        if contactInfoTextView.textColor != UIColor.lightGray && !contactInfoTextView.text!.isEmpty {
            parameters["info"] = contactInfoTextView.text!
        }
        
        let headers: HTTPHeaders = [
            "Authorization": authModelController.session.authToken!
        ]
        
        AF.request("https://w4dtt62bhd.execute-api.us-east-1.amazonaws.com/dev/sharedSpace/addContact", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).validate().responseJSON { response in
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
    
    @IBAction func importContactButtonTapped(_ sender: Any) {
        let contactPickerViewController = CNContactPickerViewController()
        contactPickerViewController.delegate = self
        contactPickerViewController.displayedPropertyKeys = [CNContactPhoneNumbersKey]
        self.present(contactPickerViewController, animated: true, completion: nil)
    }
}

extension SharedSpaceAddContactViewController: UITextViewDelegate {
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

extension SharedSpaceAddContactViewController: CNContactPickerDelegate {
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        picker.dismiss(animated: true, completion: nil)
        let name = CNContactFormatter.string(from: contact, style: .fullName)
        for number in contact.phoneNumbers {
            let mobile = number.value.value(forKey: "digits") as? String
            if (mobile?.count)! > 7 {
                contactNameTextField.text = name
                contactNumberTextField.text = mobile
            }
        }
    }
}
