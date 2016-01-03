//
//  VideoDetailsViewController.swift
//  pomotv-tvos-client
//
//  Created by Christian Lobach on 03/01/16.
//  Copyright © 2016 Christian Lobach. All rights reserved.
//

import UIKit

public class VideoDetailsViewController: UIViewController {
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var speakersLabel: UILabel!
    @IBOutlet weak var languageLabel: UILabel!
    @IBOutlet weak var tagsLabel: UILabel!
    
    public var video: Video?
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        if let video = video {
            
            titleLabel.text = video.title
            speakersLabel.text = video.speakers.joinWithSeparator(", ")
            tagsLabel.text = video.tags.joinWithSeparator(", ")
            languageLabel.text = video.language
            
            NetworkManager.sharedInstance.thumbnailURLForVideo(video) { [weak self] url, error in
                if let url = url {
                    self?.backgroundImageView.af_setImageWithURL(url)
                    self?.thumbnailImageView.af_setImageWithURL(url)
                }
            }
        }
     
    }
    
    
    @IBAction func viewButtonTapped(sender: AnyObject) {

        if let video = video {
            NetworkManager.sharedInstance.streamingURLForVideo(video) { [weak self] url, error in
                
                if let url = url {
                    let viewController = VideoPlayerViewController()
                    viewController.streamURL = url
                    self?.navigationController?.pushViewController(viewController, animated: true)
                    
                }
                
            }
        }
    }

}
