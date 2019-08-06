//
//  AddMemberViewController.swift
//  MyKlan
//
//  Created by Tejisav Brar on 2019-07-05.
//  Copyright © 2019 Team Lion. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class AddMemberViewController: AuthViewController {
    
    @IBOutlet weak var memberSelectedImageView: UIImageView!
    @IBOutlet weak var memberNameTextField: DesignableUITextField!
    @IBOutlet weak var choosePhotoButton: UIButton!
    
    private var imageSelected: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        memberSelectedImageView.roundedImage()
        
        choosePhotoButton.layer.cornerRadius = 5
    }
    
    override func viewWillAppear(_ animated: Bool) {
        removeNavBarBackgroundImage()
        
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        addNavBarBackgroundImage()
        
        super.viewWillDisappear(animated)
    }
    
    @IBAction func choosePhotoButtonTapped(_ sender: Any) {
        ImagePickerManager().pickImage(self){ image in
            self.memberSelectedImageView.image = image.aspectFittedToHeight(250)
            self.imageSelected = true
        }
    }
    
    @IBAction func addMemberButtonTapped(_ sender: Any) {
        if memberNameTextField.text!.isEmpty {
            return
        }
        
        self.showSpinner(onView: self.view)
        
        var strBase64: String?
        
        if imageSelected {
            if let imageData: Data = memberSelectedImageView.image!.jpegData(compressionQuality: 1.0) {
                let imageSize: Int = imageData.count
                print("size of image in KB: %f ", Double(imageSize) / 1024.0)
                print("size of image in MB: %f ", Double(imageSize) / 1024.0 / 1024)
                strBase64 = imageData.base64EncodedString(options: .lineLength64Characters)
//                let dataDecoded : Data = Data(base64Encoded: strBase64, options: .ignoreUnknownCharacters)!
//                let decodedimage = UIImage(data: dataDecoded)
//                self.memberSelectedImageView.image = decodedimage
            }
        }
        
        var parameters: Parameters = [
            "userId": authModelController.session.mongoID!,
            "name": memberNameTextField.text!
        ]
        
        if strBase64 != nil {
            parameters["avatar"] = strBase64
        }
        
        
        let headers: HTTPHeaders = [
            "Authorization": authModelController.session.authToken!
        ]
        
        AF.request("https://w4dtt62bhd.execute-api.us-east-1.amazonaws.com/dev/addMember", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).validate().responseJSON { response in
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
