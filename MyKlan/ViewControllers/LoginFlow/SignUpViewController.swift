//
//  SignUpViewController.swift
//  MyKlan
//
//  Created by Tejisav Brar on 2019-06-25.
//  Copyright © 2019 Team Lion. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class SignUpViewController: AuthViewController {
    
    var userEmail: String?
    
    @IBOutlet weak var familyNameTextField: DesignableUITextField!
    @IBOutlet weak var emailTextField: DesignableUITextField!
    @IBOutlet weak var passwordTextField: DesignableUITextField!
    @IBOutlet weak var confirmPasswordTextField: DesignableUITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if userEmail != nil {
            emailTextField.text = userEmail
            emailTextField.isEnabled = false
        }
    }
    
    @IBAction func signUpButtonTapped(_ sender: UIButton) {
        
        if familyNameTextField.text!.isEmpty || emailTextField.text!.isEmpty || passwordTextField.text!.isEmpty || confirmPasswordTextField.text!.isEmpty {
            return
        }
        
        if !Helpers.isValidEmail(emailStr: emailTextField.text!) {
            Helpers.showAlert(view: self, title: "Error", message: "\(emailTextField.text!) is not a valid email.")
            return
        }

        if !Helpers.isValidPassword(passwordStr: passwordTextField.text!) {
            Helpers.showAlert(view: self, title: "Error", message: """
The password must contain:
\u{2022} 1 lowercase character
\u{2022} 1 uppercase character
\u{2022} 1 numeric character
\u{2022} 8 characters or more
"""
            )
            return
        }
        
        if passwordTextField.text!.elementsEqual(confirmPasswordTextField.text!) != true
        {
            Helpers.showAlert(view: self, title: "Error", message: "Passwords do not match.")
            return
        }
        
        self.showSpinner(onView: self.view)
        
        let parameters: Parameters = [
            "familyName": familyNameTextField.text!,
            "email": emailTextField.text!,
            "password": passwordTextField.text!
        ]
        
        AF.request("https://w4dtt62bhd.execute-api.us-east-1.amazonaws.com/dev/register", method: .post, parameters: parameters, encoding: JSONEncoding.default).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                self.authModelController.session.authType = .email
                self.authModelController.session.authToken = json["token"].stringValue
                self.authModelController.session.email = self.emailTextField.text!
                self.authModelController.session.password = self.passwordTextField.text!
                self.authModelController.store()
                self.authModelController.onLogin(view: self)
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
