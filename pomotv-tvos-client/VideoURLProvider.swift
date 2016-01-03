//
//  VideoURLProvider.swift
//  pomotv-tvos-client
//
//  Created by Christian Lobach on 04/01/16.
//  Copyright © 2016 Christian Lobach. All rights reserved.
//

import Foundation
import XCDYouTubeKit
import YTVimeoExtractor

public protocol VideoURLProvider {    
    func thumbnailURL() -> NSURL?
    func bestStreamingURL() -> NSURL?
}

extension XCDYouTubeVideo: VideoURLProvider {
    
    public func thumbnailURL() -> NSURL? {
        return mediumThumbnailURL
    }
    
    public func bestStreamingURL() -> NSURL? {
        return streamURLs[XCDYouTubeVideoQuality.HD720.rawValue]
            ?? streamURLs[XCDYouTubeVideoQuality.Medium360.rawValue]
            ?? streamURLs[XCDYouTubeVideoQuality.Small240.rawValue]
    }
}

extension YTVimeoVideo: VideoURLProvider {
    
    public func thumbnailURL() -> NSURL? {
        if let urlString = thumbnailURLs?[YTVimeoVideoThumbnailQuality.Small.rawValue] as? String {
            return NSURL(string: urlString)
        }
        return nil
    }
    
    public func bestStreamingURL() -> NSURL? {
        
        // "Expression was too complex to be solved in reasonable time
        
        let hdURL = streamURLs?[YTVimeoVideoQuality.HD1080.rawValue]
            ?? streamURLs?[YTVimeoVideoQuality.HD720.rawValue]
        
        let sdURL = streamURLs?[YTVimeoVideoQuality.Medium480.rawValue]
            ?? streamURLs?[YTVimeoVideoQuality.Medium360.rawValue]
            ?? streamURLs?[YTVimeoVideoQuality.Low270.rawValue]
        
        if let urlString = (hdURL ?? sdURL) as? String {
            return NSURL(string: urlString)
        }
        return nil
    }
}
