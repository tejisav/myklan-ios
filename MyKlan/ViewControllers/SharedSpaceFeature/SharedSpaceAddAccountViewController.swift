//
//  SharedSpaceAddAccountViewController.swift
//  MyKlan
//
//  Created by Tejisav Brar on 2019-07-17.
//  Copyright © 2019 Team Lion. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class SharedSpaceAddAccountViewController: AuthViewController {
    
    @IBOutlet weak var accountNameTextField: DesignableUITextField!
    @IBOutlet weak var accountUsernameTextField: DesignableUITextField!
    @IBOutlet weak var accountPasswordTextField: DesignableUITextField!
    @IBOutlet weak var accountInfoTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        accountInfoTextView.layer.borderWidth = 1
        accountInfoTextView.layer.borderColor = UIColor.black.cgColor
        accountInfoTextView.text = "Info (Optional)"
        accountInfoTextView.textColor = UIColor.lightGray
    }
    
    override func viewWillAppear(_ animated: Bool) {
        removeNavBarBackgroundImage()
        
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        addNavBarBackgroundImage()
        
        super.viewWillDisappear(animated)
    }
    
    @IBAction func saveAccountButtonTapped(_ sender: Any) {
        if accountNameTextField.text!.isEmpty || accountUsernameTextField.text!.isEmpty || accountPasswordTextField.text!.isEmpty {
            return
        }
        
        self.showSpinner(onView: self.view)
        
        var parameters: Parameters = [
            "userId": authModelController.session.mongoID!,
            "name": accountNameTextField.text!,
            "username": accountUsernameTextField.text!,
            "password": accountPasswordTextField.text!
        ]
        
        if accountInfoTextView.textColor != UIColor.lightGray && !accountInfoTextView.text!.isEmpty {
            parameters["info"] = accountInfoTextView.text!
        }
        
        let headers: HTTPHeaders = [
            "Authorization": authModelController.session.authToken!
        ]
        
        AF.request("https://w4dtt62bhd.execute-api.us-east-1.amazonaws.com/dev/sharedSpace/addAccount", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).validate().responseJSON { response in
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

extension SharedSpaceAddAccountViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if accountInfoTextView.textColor == UIColor.lightGray {
            accountInfoTextView.text = nil
            accountInfoTextView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if accountInfoTextView.text.isEmpty {
            accountInfoTextView.text = "Info (Optional)"
            accountInfoTextView.textColor = UIColor.lightGray
        }
    }
}
