//
//  AuthModelController.swift
//  MyKlan
//
//  Created by Tejisav Brar on 2019-06-28.
//  Copyright © 2019 Team Lion. All rights reserved.
//

import Foundation
import SwiftKeychainWrapper
import Alamofire
import SwiftyJSON
import GoogleSignIn
import UserNotifications
import CoreLocation

class AuthModelController {
    
    public var session: SessionModel
    public var locationManager: CLLocationManager?
    
    init() {
        session = SessionModel()
        retrive()
    }
    
    func retrive() {
        if let sessionData = KeychainWrapper.standard.data(forKey: "session"),
            let session = try? JSONDecoder().decode(SessionModel.self, from: sessionData) {
            self.session = session
//            print(String(data: sessionData, encoding: .utf8)!)
        }
    }
    
    func store() {
        if let sessionData = try? JSONEncoder().encode(session) {
//            print(String(data: sessionData, encoding: .utf8)!)
            KeychainWrapper.standard.set(sessionData, forKey: "session")
        }
    }
    
    func remove() {
        GIDSignIn.sharedInstance().signOut()
        session = SessionModel()
        KeychainWrapper.standard.removeAllKeys()
    }
    
    func isTokenValid(completion: @escaping (Bool) -> ()) {
        if (session.authType != nil && session.authToken != nil) {
            let headers: HTTPHeaders = [
                "Authorization": session.authToken!
            ]
            
            AF.request("https://w4dtt62bhd.execute-api.us-east-1.amazonaws.com/dev/verifyToken", headers: headers).validate().responseJSON { response in
                switch response.result {
                    case .success:
                        completion(true)
                    case .failure:
                        completion(false)
                }
            }
        } else {
            completion(false)
        }
    }
    
    func isUserFound(completion: @escaping (Bool) -> ()) {
        if (session.authType != nil && session.authToken != nil) {
            let headers: HTTPHeaders = [
                "Authorization": session.authToken!
            ]
            
            AF.request("https://w4dtt62bhd.execute-api.us-east-1.amazonaws.com/dev/me", headers: headers).validate().responseJSON { response in
                switch response.result {
                    case .success(let value):
                        let json = JSON(value)
                        self.session.mongoID = json["_id"].stringValue
                        self.session.familyName = json["familyName"].stringValue
                        self.session.email = json["email"].stringValue
                        completion(true)
                    case .failure:
                        completion(false)
                }
            }
        } else {
            completion(false)
        }
    }
    
    func isMemberFound(completion: @escaping (Bool) -> ()) {
        if (session.memberMongoID != nil) {
            
            let parameters: Parameters = [
                "memberId": session.memberMongoID!
            ]
            
            let headers: HTTPHeaders = [
                "Authorization": session.authToken!
            ]
            
            AF.request("https://w4dtt62bhd.execute-api.us-east-1.amazonaws.com/dev/getMember", parameters: parameters, headers: headers).validate().responseJSON { response in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    self.session.memberName = json["name"].stringValue
                    self.requestAuthorization()
                    completion(true)
                case .failure:
                    self.session.memberMongoID = nil
                    self.store()
                    completion(false)
                }
            }
        } else {
            completion(false)
        }
    }
    
    func loginSilently(completion: @escaping (Bool) -> ()) {
        if (session.authType != nil) {
            if (session.authType == .email && session.email != nil && session.password != nil) {
                
                let parameters: Parameters = [
                    "email": session.email!,
                    "password": session.password!
                ]
                
                AF.request("https://w4dtt62bhd.execute-api.us-east-1.amazonaws.com/dev/login", method: .post, parameters: parameters, encoding: JSONEncoding.default).validate().responseJSON { response in
                    switch response.result {
                        case .success(let value):
                            let json = JSON(value)
                            self.session.authToken = json["token"].stringValue
                            completion(true)
                        case .failure:
                            completion(false)
                    }
                }
            } else {
                completion(false)
            }
        } else {
            completion(false)
        }
    }
    
    func onLogin(view: AuthViewController) {
        isUserFound { (success) in
            if success {
                let memberFlowStoryBoard: UIStoryboard = UIStoryboard(name: "MemberFlow", bundle: nil)
                let memberNavigationController = memberFlowStoryBoard.instantiateInitialViewController() as! UINavigationController
                let selectMemberViewController = memberNavigationController.topViewController as! SelectMemberViewController
                selectMemberViewController.authModelController = self
                view.present(memberNavigationController, animated: true, completion: nil)
            }
        }
    }
    
    func onLogout(view: AuthViewController) {
        remove()
        let loginFlowStoryBoard: UIStoryboard = UIStoryboard(name: "LoginFlow", bundle: nil)
        let loginNavigationController = loginFlowStoryBoard.instantiateInitialViewController() as! UINavigationController
        let loginViewController = loginNavigationController.topViewController as! LoginViewController
        loginViewController.authModelController = self
        view.present(loginNavigationController, animated: true, completion: nil)
    }
    
    func onChooseMember(view: AuthViewController) {
        session.memberMongoID = nil
        session.memberName = nil
        session.memberDeviceToken = nil
        store()
        let memberFlowStoryBoard: UIStoryboard = UIStoryboard(name: "MemberFlow", bundle: nil)
        let selectMemberNavigationController = memberFlowStoryBoard.instantiateInitialViewController() as! UINavigationController
        let selectMemberViewController = selectMemberNavigationController.topViewController as! SelectMemberViewController
        selectMemberViewController.authModelController = self
        view.present(selectMemberNavigationController, animated: true, completion: nil)
    }
    
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { (granted, error) in
            print("granted: \(granted)")
        }
        
        UIApplication.shared.registerForRemoteNotifications()
        
        locationManager!.requestAlwaysAuthorization()
        
        locationManager!.startUpdatingLocation()
        locationManager!.startMonitoringSignificantLocationChanges()
    }
    
    func startMonitoringRegions(beacons: [BeaconModel]) {
        for beacon in beacons {
            let clampedRadius = min(beacon.radius!, locationManager!.maximumRegionMonitoringDistance)
            let region = CLCircularRegion(center: beacon.coordinate!, radius: clampedRadius, identifier: beacon.id!)
            region.notifyOnEntry = beacon.onEntry!
            region.notifyOnExit = beacon.onExit!
            locationManager!.startMonitoring(for: region)
        }
        stopMonitoringDeletedRegions(beacons: beacons)
    }
    
    func stopMonitoringDeletedRegions(beacons: [BeaconModel]) {
        for region in locationManager!.monitoredRegions {
            var regionExist = false
            let circularRegion = region as? CLCircularRegion
            if circularRegion != nil {
                for beacon in beacons {
                    if circularRegion!.identifier == beacon.id! {
                        regionExist = true
                    }
                }
                if !regionExist {
                    locationManager!.stopMonitoring(for: circularRegion!)
                }
            }
        }
    }
}
