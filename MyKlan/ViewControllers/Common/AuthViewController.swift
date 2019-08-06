//
//  AuthViewController.swift
//  MyKlan
//
//  Created by Tejisav Brar on 2019-07-05.
//  Copyright © 2019 Team Lion. All rights reserved.
//

import UIKit

class AuthViewController: UIViewController {
    
    var authModelController: AuthModelController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addNavBarBackgroundImage()
        addNavBarTitleImage()
        self.hideKeyboardWhenTappedAround()
    }
    
    func getImageFrom(gradientLayer:CAGradientLayer) -> UIImage? {
        var gradientImage:UIImage?
        UIGraphicsBeginImageContext(gradientLayer.frame.size)
        if let context = UIGraphicsGetCurrentContext() {
            gradientLayer.render(in: context)
            gradientImage = UIGraphicsGetImageFromCurrentImageContext()?.resizableImage(withCapInsets: UIEdgeInsets.zero, resizingMode: .stretch)
        }
        UIGraphicsEndImageContext()
        return gradientImage
    }
    
    func addNavBarBackgroundImage() {
        if let navigationBar = self.navigationController?.navigationBar {
            
//            let backImage = UIImage(named: "back-icon")
//            self.navigationController?.navigationBar.backIndicatorImage = backImage
//            self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = backImage
//            navigationBar.backItem?.title = ""
            navigationBar.tintColor = .white
            
            let gradient = CAGradientLayer()
            var bounds = navigationBar.bounds
            bounds.size.height += UIApplication.shared.statusBarFrame.size.height
            gradient.frame = bounds
            gradient.colors = [UIColor(rgb: 0x85E2B0).cgColor, UIColor(rgb: 0x11998E).cgColor]
            gradient.startPoint = CGPoint(x: 0, y: 0)
            gradient.endPoint = CGPoint(x: 0, y: 1)
            
            if let image = getImageFrom(gradientLayer: gradient) {
                navigationBar.setBackgroundImage(image, for: UIBarMetrics.default)
                navigationBar.shadowImage = UIImage()
                navigationBar.isTranslucent = false
//                navigationBar.barTintColor = UIColor(patternImage: image)
            }
        }
    }
    
    func removeNavBarBackgroundImage() {
        if let navigationBar = self.navigationController?.navigationBar {
            navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
            navigationBar.isTranslucent = true
        }
    }
    
    func addNavBarTitleImage() {
        if let navigationBar = self.navigationController?.navigationBar {
            let image = #imageLiteral(resourceName: "myklan-text")
            
            let imageView = UIImageView()
            
            imageView.contentMode = .center
            imageView.center = navigationBar.center
            imageView.image = image.aspectFittedToHeight(image.size.height - 10)
            
            navigationItem.titleView = imageView
        }
    }
}
