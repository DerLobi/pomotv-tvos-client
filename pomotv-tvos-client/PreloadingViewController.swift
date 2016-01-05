//
//  PreloadingViewController.swift
//  pomotv-tvos-client
//
//  Created by Christian Lobach on 03/01/16.
//  Copyright © 2016 Christian Lobach. All rights reserved.
//

import UIKit

class PreloadingViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        NetworkManager.sharedInstance.getAllVideos { [weak self] videos, error in
            if let _ = videos {
                self?.view.window?.rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("tabBar")                
            } else {
                // handle error
            }            
        }
    }
}
