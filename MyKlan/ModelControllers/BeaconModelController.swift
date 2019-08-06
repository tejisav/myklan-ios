//
//  BeaconModelController.swift
//  MyKlan
//
//  Created by Tejisav Brar on 2019-07-30.
//  Copyright © 2019 Team Lion. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import CoreLocation

class BeaconModelController {
    
    static func getBeacons(view: AuthViewController, completion: @escaping ([BeaconModel]?) -> ()) {
        
        var results: [BeaconModel] = []
        
        let headers: HTTPHeaders = [
            "Authorization": view.authModelController.session.authToken!
        ]
        
        let parameters: Parameters = [
            "userId": view.authModelController.session.mongoID!,
            "memberId": view.authModelController.session.memberMongoID!
        ]
        
        AF.request("https://w4dtt62bhd.execute-api.us-east-1.amazonaws.com/dev/beaconNotifications/getBeacons", parameters: parameters, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                for (_, beacon) in json {
                    results.append(BeaconModel(
                        id: beacon["_id"].stringValue,
                        title: beacon["title"].stringValue,
                        coordinate: CLLocationCoordinate2D(latitude: beacon["latitude"].doubleValue, longitude: beacon["longitude"].doubleValue),
                        radius: beacon["radius"].doubleValue,
                        members: beacon["members"].arrayValue.map{ $0.stringValue },
                        onExit: beacon["onExit"].boolValue,
                        onEntry: beacon["onEntry"].boolValue
                    ))
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
