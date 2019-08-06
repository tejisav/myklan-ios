//
//  ContactModelController.swift
//  MyKlan
//
//  Created by Tejisav Brar on 2019-07-17.
//  Copyright © 2019 Team Lion. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ContactModelController {
    
    static func getContacts(view: AuthViewController, completion: @escaping ([ContactModel]?) -> ()) {
        
        var results: [ContactModel] = []
        
        let headers: HTTPHeaders = [
            "Authorization": view.authModelController.session.authToken!
        ]
        
        let parameters: Parameters = [
            "userId": view.authModelController.session.mongoID!
        ]
        
        AF.request("https://w4dtt62bhd.execute-api.us-east-1.amazonaws.com/dev/sharedSpace/getContacts", parameters: parameters, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                for (_, contact) in json {
                    results.append(ContactModel(id: contact["_id"].stringValue, name: contact["name"].stringValue, number: contact["number"].stringValue, info: contact["info"].stringValue))
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
