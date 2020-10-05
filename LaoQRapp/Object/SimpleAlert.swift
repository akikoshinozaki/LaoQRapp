//
//  SimpleAlert.swift
//  m8navi2
//
//  Created by mapipo office on 2017/06/18.
//  Copyright © 2017年 mapipo office. All rights reserved.
//  mapipo office confidential

import UIKit
var window_ = UIWindow()
class SimpleAlert: NSObject {
    class func make (title: String?, message: String?) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let action1 = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(action1)
            if window_.rootViewController?.presentedViewController != nil ||
                window_.rootViewController?.presentingViewController != nil{
                window_.rootViewController?.dismiss(animated: false, completion: {
                    window_.rootViewController?.present(alert, animated: true, completion: nil)
                })
            } else {
               window_.rootViewController?.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    class func make (title: String?, message: String?, action:[UIAlertAction]) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            //let action1 = UIAlertAction(title: "OK", style: .default, handler: nil)
            for act in action {
                alert.addAction(act)
            }
            
            if let topViewController: UIViewController = SimpleAlert.getTopViewController(){
                //topViewController.view.addSubview(customView)
                topViewController.present(alert, animated: true, completion: nil)
            }
            /*
            if window_.rootViewController?.presentedViewController != nil ||
                window_.rootViewController?.presentingViewController != nil{
                window_.rootViewController?.dismiss(animated: false, completion: {
                    window_.rootViewController?.present(alert, animated: true, completion: nil)
                })
            } else {
                window_.rootViewController?.present(alert, animated: true, completion: nil)
            }*/
        }
    }
    
    class func getTopViewController() -> UIViewController? {
        if let rootViewController = UIApplication.shared.keyWindow?.rootViewController {
            var topViewController: UIViewController = rootViewController

            while let presentedViewController = topViewController.presentedViewController {
                topViewController = presentedViewController
            }

            return topViewController
        } else {
            return nil
        }
    }
    
    
}
