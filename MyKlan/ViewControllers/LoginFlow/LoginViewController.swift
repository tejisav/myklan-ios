//
//  ViewController.swift
//  MyKlan
//
//  Created by Tejisav Brar on 2019-06-21.
//  Copyright © 2019 Team Lion. All rights reserved.
//

import UIKit
import Alamofire
import GoogleSignIn
import SwiftyJSON

class LoginViewController: AuthViewController, GIDSignInUIDelegate {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var bottomStyleView: UIView!
    @IBOutlet weak var loginWithGoogleButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment to automatically sign in the user.
        //GIDSignIn.sharedInstance().signInSilently()
        
        bottomStyleView.roundCorners(corners: .topLeft, radius: 100)
        loginButton.layer.cornerRadius = 5
        loginWithGoogleButton.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        loginWithGoogleButton.layer.borderWidth = 1
        loginWithGoogleButton.layer.cornerRadius = 5
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        
        super.viewWillDisappear(animated)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SignUpSegue" {
            let signUpViewController = segue.destination as! SignUpViewController
            print(authModelController.session)
            signUpViewController.authModelController = authModelController
        }
    }

    @IBAction func loginbuttonTapped(_ sender: UIButton) {
        
        if emailTextField.text!.isEmpty || passwordTextField.text!.isEmpty {
            return
        }
        
        self.showSpinner(onView: self.view)
        
        let parameters: Parameters = [
            "email": emailTextField.text!,
            "password": passwordTextField.text!
        ]
        
        AF.request("https://w4dtt62bhd.execute-api.us-east-1.amazonaws.com/dev/login", method: .post, parameters: parameters, encoding: JSONEncoding.default).validate().responseJSON { response in
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
    
    @IBAction func loginWithGoogleButtonTapped(_ sender: UIButton) {
        
        self.showSpinner(onView: self.view)
        
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().signIn()
    }
}
