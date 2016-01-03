//
//  VideoPlayerViewController.swift
//  pomotv-tvos-client
//
//  Created by Christian Lobach on 03/01/16.
//  Copyright © 2016 Christian Lobach. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit


class VideoPlayerViewController: AVPlayerViewController {

    var streamURL: NSURL?
    
    override func viewDidAppear(animated: Bool) {

        player = AVPlayer(URL: streamURL!)
        player?.play()

    }
    
}
