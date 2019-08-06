//
//  AccountModelController.swift
//  MyKlan
//
//  Created by Tejisav Brar on 2019-07-17.
//  Copyright © 2019 Team Lion. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class AccountModelController {
    
    static func getAccounts(view: AuthViewController, completion: @escaping ([AccountModel]?) -> ()) {
        
        var results: [AccountModel] = []
        
        let headers: HTTPHeaders = [
            "Authorization": view.authModelController.session.authToken!
        ]
        
        let parameters: Parameters = [
            "userId": view.authModelController.session.mongoID!
        ]
        
        AF.request("https://w4dtt62bhd.execute-api.us-east-1.amazonaws.com/dev/sharedSpace/getAccounts", parameters: parameters, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                for (_, account) in json {
                    results.append(AccountModel(id: account["_id"].stringValue, name: account["name"].stringValue, username: account["username"].stringValue, password: account["password"].stringValue, info: account["info"].stringValue))
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
