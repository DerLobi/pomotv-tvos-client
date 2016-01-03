//
//  NetworkManager.swift
//  pomotv-tvos-client
//
//  Created by Christian Lobach on 03/01/16.
//  Copyright © 2016 Christian Lobach. All rights reserved.
//

import Alamofire
import YamlSwift
import Alamofire_YamlSwift
import XCDYouTubeKit

public class NetworkManager: NSObject {
    
    public static let sharedInstance = NetworkManager()
    
    private var videos: [String: [Video]]?
    
    private var youTubeVideos = [String: XCDYouTubeVideo]()

    public func getAllVideos(completion: ( ([String: [Video]]?, ErrorType?) -> Void)) {
        
        if let videos = videos {
            completion(videos, nil)
            return
        }
        
        Alamofire.request(.GET, "https://cdn.rawgit.com/chriseidhof/pomotv/master/data/videos.yml")
            .responseYaml { [weak self] response in
                if let yaml = response.result.value, events = yaml.dictionary {
                    
                    
                    var keys = events.map { key, value in
                        return key.string!
                    }
                    
                    keys.sortInPlace()
                    self?.videos = [String: [Video]]()
                    
                    for key in keys {
                        
                        if let yamlVideos = events[Yaml(stringLiteral: key)]?.array {
                            let parsedVideos = yamlVideos.map { Video(yaml: $0) }
                            self?.videos![key] = parsedVideos
                        }
                        
                    }
                }
                
                completion(self?.videos, nil)
        }
    }
    
    public func thumbnailURLForVideo(video: Video, completion: (NSURL?, ErrorType?) -> Void) {
        switch video.source {
        case .Youtube(let id):
            if let youTubeVideo = youTubeVideos[id] {
                completion(youTubeVideo.mediumThumbnailURL, nil)
                return
            }
            
            XCDYouTubeClient.defaultClient().getVideoWithIdentifier(id) { [weak self] youtubeVideo, error in
                if let youTubeVideo = youtubeVideo {
                    self?.youTubeVideos[id] = youTubeVideo
                    completion(youTubeVideo.mediumThumbnailURL, nil)
                }
            }
        default:
            break;
        }

    }

    public func streamingURLForVideo(video: Video, completion: (NSURL?, ErrorType?) -> Void) {
        switch video.source {
        case .Youtube(let id):
        if let youTubeVideo = youTubeVideos[id] {
            let bestStreamURL = youTubeVideo.streamURLs[XCDYouTubeVideoQuality.HD720.rawValue]
                ?? youTubeVideo.streamURLs[XCDYouTubeVideoQuality.Medium360.rawValue]
                ?? youTubeVideo.streamURLs[XCDYouTubeVideoQuality.Small240.rawValue]
            
            completion(bestStreamURL, nil)
            return
        }
        
        XCDYouTubeClient.defaultClient().getVideoWithIdentifier(id) { [weak self] youtubeVideo, error in
            if let youTubeVideo = youtubeVideo {
                self?.youTubeVideos[id] = youTubeVideo
                
                let bestStreamURL = youTubeVideo.streamURLs[XCDYouTubeVideoQuality.HD720.rawValue]
                    ?? youTubeVideo.streamURLs[XCDYouTubeVideoQuality.Medium360.rawValue]
                    ?? youTubeVideo.streamURLs[XCDYouTubeVideoQuality.Small240.rawValue]
                
                completion(bestStreamURL, nil)
                return
            }
        }
        default:
        break;
    }
    
    }

}
