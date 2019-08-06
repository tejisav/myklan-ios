//
//  AppDelegate.swift
//  MyKlan
//
//  Created by Tejisav Brar on 2019-06-21.
//  Copyright © 2019 Team Lion. All rights reserved.
//

import UIKit
import GoogleSignIn
import UserNotifications
import Alamofire
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    var authModelController: AuthModelController!
    
    var locationManager = CLLocationManager()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        UNUserNotificationCenter.current().delegate = self
        locationManager.delegate = self
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.distanceFilter = 500.0  // In meters.
        
        // Initialize sign-in
        GIDSignIn.sharedInstance().clientID = "354641100294-vuv9ou3p73kalgb2jba06mgjnaptsuv2.apps.googleusercontent.com"
        GIDSignIn.sharedInstance().delegate = self
        
        authModelController = AuthModelController()
        
        authModelController.locationManager = locationManager
        
        if !UserDefaults.standard.bool(forKey: "firstTimeLaunchOccurred") {
            authModelController.remove()
            UserDefaults.standard.set(true, forKey: "firstTimeLaunchOccurred")
        }
        
        authModelController.loginSilently { (success) in
            if success {
                self.authModelController.isUserFound { (success) in
                    if success {
                        self.authModelController.isMemberFound { (success) in
                            if success {
                                let mainNavigationStoryBoard: UIStoryboard = UIStoryboard(name: "MainNavigation", bundle: nil)
                                let mainTabBarController = mainNavigationStoryBoard.instantiateInitialViewController() as! UITabBarController
                                let memberHomeNavigationController = mainTabBarController.viewControllers?.first as! UINavigationController
                                let mainHomeViewController = memberHomeNavigationController.topViewController as! MainHomeViewController
                                mainHomeViewController.authModelController = self.authModelController
                                self.window?.rootViewController = mainTabBarController
                                self.window?.makeKeyAndVisible()
                            } else {
                                let memberFlowStoryBoard: UIStoryboard = UIStoryboard(name: "MemberFlow", bundle: nil)
                                let memberNavigationController = memberFlowStoryBoard.instantiateInitialViewController() as! UINavigationController
                                let selectMemberViewController = memberNavigationController.topViewController as! SelectMemberViewController
                                selectMemberViewController.authModelController = self.authModelController
                                self.window?.rootViewController = memberNavigationController
                                self.window?.makeKeyAndVisible()
                            }
                        }
                    }
                }
            } else if GIDSignIn.sharedInstance().hasAuthInKeychain() {
                GIDSignIn.sharedInstance().signInSilently()
            } else {
                let loginFlowStoryBoard: UIStoryboard = UIStoryboard(name: "LoginFlow", bundle: nil)
                let loginNavigationController = loginFlowStoryBoard.instantiateInitialViewController() as! UINavigationController
                let loginViewController = loginNavigationController.topViewController as! LoginViewController
                loginViewController.authModelController = self.authModelController
                self.window?.rootViewController = loginNavigationController
                self.window?.makeKeyAndVisible()
            }
        }
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        
        if authModelController.session.memberMongoID != nil {
            let content = UNMutableNotificationContent()
            content.title = "App Terminated"
            content.body = "Please start the app again to continue using location features."
            content.sound = UNNotificationSound.default
            let request = UNNotificationRequest(identifier: "AppTermination", content: content, trigger: nil)
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
            // block main thread
            DispatchQueue.global().async {
                sleep(1)
                DispatchQueue.main.sync {
                    CFRunLoopStop(CFRunLoopGetCurrent())
                }
            }
            CFRunLoopRun()
        }
    }
    
}


extension AppDelegate: GIDSignInDelegate {
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance().handle(url as URL?,
                                                 sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
                                                 annotation: options[UIApplication.OpenURLOptionsKey.annotation])
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return GIDSignIn.sharedInstance().handle(url,
                                                 sourceApplication: sourceApplication,
                                                 annotation: annotation)
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            print("\(error.localizedDescription)")
            let loginFlowStoryBoard: UIStoryboard = UIStoryboard(name: "LoginFlow", bundle: nil)
            let loginNavigationController = loginFlowStoryBoard.instantiateInitialViewController() as! UINavigationController
            let loginViewController = loginNavigationController.topViewController as! LoginViewController
            loginViewController.authModelController = self.authModelController
            self.window?.rootViewController = loginNavigationController
            self.window?.makeKeyAndVisible()
        } else {
            // Perform any operations on signed in user here.
            //            let userId = user.userID                  // For client-side use only!
            let idToken = user.authentication.idToken // Safe to send to the server
            //            let fullName = user.profile.name
            //            let givenName = user.profile.givenName
            //            let familyName = user.profile.familyName
            let email = user.profile.email
            // ...
            
            authModelController.session.authType = .google
            authModelController.session.authToken = idToken
            authModelController.store()
            
            authModelController.isUserFound { (success) in
                if success {
                    self.authModelController.isMemberFound { (success) in
                        if success {
                            let mainNavigationStoryBoard: UIStoryboard = UIStoryboard(name: "MainNavigation", bundle: nil)
                            let mainTabBarController = mainNavigationStoryBoard.instantiateInitialViewController() as! UITabBarController
                            let memberHomeNavigationController = mainTabBarController.viewControllers?.first as! UINavigationController
                            let mainHomeViewController = memberHomeNavigationController.topViewController as! MainHomeViewController
                            mainHomeViewController.authModelController = self.authModelController
                            self.window?.rootViewController = mainTabBarController
                            self.window?.makeKeyAndVisible()
                        } else {
                            let memberFlowStoryBoard: UIStoryboard = UIStoryboard(name: "MemberFlow", bundle: nil)
                            let memberNavigationController = memberFlowStoryBoard.instantiateInitialViewController() as! UINavigationController
                            let selectMemberViewController = memberNavigationController.topViewController as! SelectMemberViewController
                            selectMemberViewController.authModelController = self.authModelController
                            self.window?.rootViewController = memberNavigationController
                            self.window?.makeKeyAndVisible()
                        }
                    }
                } else {
                    let loginFlowStoryBoard: UIStoryboard = UIStoryboard(name: "LoginFlow", bundle: nil)
                    let loginNavigationController = loginFlowStoryBoard.instantiateInitialViewController() as! UINavigationController
                    let signUpViewController = loginFlowStoryBoard.instantiateViewController(withIdentifier: "SignUpViewController") as! SignUpViewController
                    signUpViewController.authModelController = self.authModelController
                    signUpViewController.userEmail = email
                    (loginNavigationController.topViewController as! LoginViewController).authModelController = self.authModelController
                    loginNavigationController.pushViewController(signUpViewController, animated: false)
                    self.window?.rootViewController = loginNavigationController
                    self.window?.makeKeyAndVisible()
                }
            }
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        // ...
    }
    
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }
    
    //    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
    //        if response.notification.request.identifier == "TaskNotifications" {
    //            print(response.notification.request.content.title)
    //        } else {
    //            if let notification = response.notification.request.content.userInfo as? [String:AnyObject] {
    //                let message = parseRemoteNotification(notification: notification)
    //                print(message as Any)
    //            }
    //        }
    //
    //        completionHandler()
    //    }
    //
    //    private func parseRemoteNotification(notification:[String:AnyObject]) -> String? {
    //        if let aps = notification["aps"] as? [String:AnyObject] {
    //            let alert = aps["alert"] as? String
    //            return alert
    //        }
    //
    //        return nil
    //    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print("token: \(token)")
        
        if authModelController.session.memberDeviceToken != token && authModelController.session.memberMongoID != nil {
            let parameters: Parameters = [
                "memberId": authModelController.session.memberMongoID!,
                "deviceToken": token
            ]
            
            let headers: HTTPHeaders = [
                "Authorization": authModelController.session.authToken!
            ]
            
            AF.request("https://w4dtt62bhd.execute-api.us-east-1.amazonaws.com/dev/updateDeviceToken", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).validate().responseJSON { response in
                switch response.result {
                case .success(let value):
                    print(value)
                    self.authModelController.session.memberDeviceToken = token
                    self.authModelController.store()
                case .failure:
                    if let data = response.data {
                        let json = String(data: data, encoding: String.Encoding.utf8)
                        print(json!)
                        if json! == "Nothing changed." {
                            self.authModelController.session.memberDeviceToken = token
                            self.authModelController.store()
                        }
                    }
                }
            }
        }
    }
    
    //    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
    //        print("failed to register for remote notifications with with error: \(error)")
    //    }
    
//    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
//
//        print("Recived: \(userInfo)")
//
//        if userInfo["id"] as! String == "requestLocation" {
//            locationManager.requestLocation()
//        }
//
//        completionHandler(.newData)
//    }
    
}

extension AppDelegate: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("Location: \(String(describing: manager.location!.coordinate))")
        
        if authModelController.session.memberMongoID != nil {
            let parameters: Parameters = [
                "memberId": authModelController.session.memberMongoID!,
                "latitude": manager.location!.coordinate.latitude.description,
                "longitude": manager.location!.coordinate.longitude.description,
                "lastLocationUpdate": manager.location!.timestamp.description(with: .current)
            ]
            
            let headers: HTTPHeaders = [
                "Authorization": authModelController.session.authToken!
            ]
            
            AF.request("https://w4dtt62bhd.execute-api.us-east-1.amazonaws.com/dev/locationTracking/updateLocation", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).validate().responseJSON { response in
                switch response.result {
                case .success(let value):
                    print(value)
                case .failure:
                    if let data = response.data {
                        let json = String(data: data, encoding: String.Encoding.utf8)
                        print(json!)
                    }
                }
            }
        }
    }
    
    func handleEvent(for region: CLRegion!, message: String?) {
        
        #if targetEnvironment(simulator)
        let content = UNMutableNotificationContent()
        content.title = region.identifier
        content.body = "\(authModelController.session.memberName!) \(message!)"
        content.sound = UNNotificationSound.default
        let request = UNNotificationRequest(identifier: "BeaconNotification", content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        #endif
        
        if authModelController.session.memberMongoID != nil && authModelController.session.memberName != nil {
            let parameters: Parameters = [
                "beaconId": region.identifier,
                "message": "\(authModelController.session.memberName!) \(message!)"
            ]
            
            let headers: HTTPHeaders = [
                "Authorization": authModelController.session.authToken!
            ]
            
            AF.request("https://w4dtt62bhd.execute-api.us-east-1.amazonaws.com/dev/beaconNotifications/notifyMembers", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).validate().responseJSON { response in
                switch response.result {
                case .success(let value):
                    print(value)
                case .failure:
                    if let data = response.data {
                        let json = String(data: data, encoding: String.Encoding.utf8)
                        print(json!)
                    }
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if region is CLCircularRegion {
            handleEvent(for: region, message: "entered the region")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        if region is CLCircularRegion {
            handleEvent(for: region, message: "left the region")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error: \(error)")
    }
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print("Monitoring failed for region with identifier: \(region!.identifier)")
    }
}
