//
//  FirstViewController.swift
//  pomotv-tvos-client
//
//  Created by Christian Lobach on 03/01/16.
//  Copyright © 2016 Christian Lobach. All rights reserved.
//

import UIKit

import AlamofireImage

class VideosViewController: UICollectionViewController {

    
    var sections: [String] {
        return videos.keys.sort()
    }
    
    var videos: [String: [Video]] = [:]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NetworkManager.sharedInstance.getAllVideos { [weak self] videos, error in
            if let videos = videos {
                self?.videos = videos
                self?.collectionView?.reloadData()
            }
        }
        

    }
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return sections.count
    }

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let sectionTitle = sections[section]
        let videosForSection = videos[sectionTitle]!
        
        return videosForSection.count
    }

    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
        let view = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "header", forIndexPath: indexPath) as! HeaderView
        view.titleLabel.text = sections[indexPath.section]
        return view;
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("video", forIndexPath: indexPath) as! VideoCell
        
        let sectionTitle = sections[indexPath.section]
        let videosForSection = videos[sectionTitle]!
        
        let video = videosForSection[indexPath.item]
        
        NetworkManager.sharedInstance.thumbnailURLForVideo(video) { url, error in
            if let url = url {
                cell.imageView.af_setImageWithURL(url)
            }
        }
        
        cell.titleLabel.text = video.title
        
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        let sectionTitle = sections[indexPath.section]
        let videosForSection = videos[sectionTitle]!
        let video = videosForSection[indexPath.item]
        
        NetworkManager.sharedInstance.streamingURLForVideo(video) { [weak self] url, error in

            if let url = url {
                let viewController = VideoPlayerViewController()
                viewController.streamURL = url
                self?.presentViewController(viewController, animated: true, completion: nil)
                
            }
            
        }
        
    }

}

