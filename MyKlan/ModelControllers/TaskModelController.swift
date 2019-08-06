//
//  TaskModelController.swift
//  MyKlan
//
//  Created by Tejisav Brar on 2019-07-17.
//  Copyright © 2019 Team Lion. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class TaskModelController {
    
    static func getTasks(view: AuthViewController, completion: @escaping ([TaskModel]?) -> ()) {
        
        var results: [TaskModel] = []
        
        let headers: HTTPHeaders = [
            "Authorization": view.authModelController.session.authToken!
        ]
        
        let parameters: Parameters = [
            "userId": view.authModelController.session.mongoID!
        ]
        
        AF.request("https://w4dtt62bhd.execute-api.us-east-1.amazonaws.com/dev/taskNotifications/getTasks", parameters: parameters, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                for (_, task) in json {
                    results.append(TaskModel(id: task["_id"].stringValue, title: task["title"].stringValue, description: task["description"].stringValue))
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
