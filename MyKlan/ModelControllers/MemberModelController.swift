//
//  MemberModelController.swift
//  MyKlan
//
//  Created by Tejisav Brar on 2019-07-16.
//  Copyright © 2019 Team Lion. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class MemberModelController {
    
    static func getMembers(view: AuthViewController, completion: @escaping ([MemberModel]?) -> ()) {
        
        var results: [MemberModel] = []
        
        let headers: HTTPHeaders = [
            "Authorization": view.authModelController.session.authToken!
        ]
        
        let parameters: Parameters = [
            "userId": view.authModelController.session.mongoID!
        ]
        
        AF.request("https://w4dtt62bhd.execute-api.us-east-1.amazonaws.com/dev/getMembers", parameters: parameters, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                for (_, member) in json {
                    var decodedimage: UIImage?
                    
                    if member["avatar"].exists() {
                        let dataDecoded : Data = Data(base64Encoded: member["avatar"].stringValue, options: .ignoreUnknownCharacters)!
                        decodedimage = UIImage(data: dataDecoded)
                    }
                    results.append(MemberModel(id: member["_id"].stringValue, name: member["name"].stringValue, avatar: decodedimage))
                }
                completion(results)
            case .failure:
                if let data = response.data {
                    let json = String(data: data, encoding: String.Encoding.utf8)
                    Helpers.showAlert(view: view, title: "Error", message: json!)
                }
                completion(nil)
            }
        }
    }
}
