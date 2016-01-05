//
//  ServiceProvider.swift
//  TopshelfExtension
//
//  Created by Christian Lobach on 04/01/16.
//  Copyright © 2016 Christian Lobach. All rights reserved.
//

import Foundation
import TVServices

public class ServiceProvider: NSObject, TVTopShelfProvider {

    private var cachedVideos: [Video]?
    
    private var cachedThumbnailURLs: [String: NSURL]?
    
    private var cachedMostRecentEdition: Edition?
    
    override init() {
        super.init()
    }

    // MARK: - TVTopShelfProvider protocol

    public var topShelfStyle: TVTopShelfContentStyle {
        // Return desired Top Shelf style.
        return .Sectioned
    }

    public var topShelfItems: [TVContentItem] {

        // prepare items from cached videos if available
        var containerItem: TVContentItem?
        
        if let cachedVideos = cachedVideos, cachedMostRecentEdition = cachedMostRecentEdition {
            containerItem = TVContentItem(contentIdentifier: TVContentIdentifier(identifier: cachedMostRecentEdition.displayName, container: nil)!)!
            containerItem?.title = cachedMostRecentEdition.displayName
            
            let videoItems = cachedVideos.map { video -> TVContentItem in
                let identifier = TVContentIdentifier(identifier: video.identifier, container: containerItem?.contentIdentifier)!
                let videoItem = TVContentItem(contentIdentifier: identifier)!
                videoItem.imageURL = cachedThumbnailURLs?[video.identifier]
                videoItem.title = video.title
                videoItem.imageShape = .HDTV
                return videoItem
            }
            
            containerItem?.topShelfItems = videoItems
        }
        
        // make request to get up to date
        NetworkManager.sharedInstance.getMostRecentEdition { [weak self] edition, error in
            if let edition = edition {
                
                if let cachedMostRecentEdition = self?.cachedMostRecentEdition where cachedMostRecentEdition == edition {
                    return
                } else {
                    self?.cachedMostRecentEdition = edition
                }
                
                NetworkManager.sharedInstance.getAllVideos { [weak self] videosByEvent, error in
                    if let videosByEvent = videosByEvent, recentVideos = videosByEvent[edition.displayName] {
                        self?.cachedVideos = recentVideos.reverse()
                        
                        NetworkManager.sharedInstance.thumbnailURLsForVideos(recentVideos.reverse()) { [weak self] urlsForVideos, error in
                            if let urlsForVideos = urlsForVideos {
                                self?.cachedThumbnailURLs = urlsForVideos
                                NSNotificationCenter.defaultCenter().postNotificationName(TVTopShelfItemsDidChangeNotification, object: nil)
                            }

                        }
                        
                    }
                }
                
            }
        }
        
        if let containerItem = containerItem {
            return [containerItem]
        }
        
        return []
        
    }

}

