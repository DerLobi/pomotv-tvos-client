//
//  AppDelegate.swift
//  pomotv-tvos-client
//
//  Created by Christian Lobach on 03/01/16.
//  Copyright © 2016 Christian Lobach. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        return true
    }

    func application(app: UIApplication, openURL url: NSURL, options: [String : AnyObject]) -> Bool {
        if let video = try? URLParser.parseVideoFromURL(url) {
            if let detailsViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("details") as? VideoDetailsViewController {
                detailsViewController.video = video
                let navigationController = UINavigationController(rootViewController: detailsViewController)
                window?.rootViewController?.presentViewController(navigationController, animated: true, completion: nil)
                return true
            }
        }
        
        return false
    }

}

