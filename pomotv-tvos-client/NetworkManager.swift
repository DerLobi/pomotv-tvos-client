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
import YTVimeoExtractor

public class NetworkManager: NSObject {
    
    public static let sharedInstance = NetworkManager()
    
    private var cachedVideos: [String: [Video]]?
    
    private var youTubeVideos = [String: XCDYouTubeVideo]()
    
    private var vimeoVideos = [Int: YTVimeoVideo]()
    
    public func getMostRecentEdition(completion: (Edition?, ErrorType?) -> Void) {
        
        Alamofire.request(.GET, "https://raw.githubusercontent.com/chriseidhof/pomotv/master/data/editions.yml")
            .responseYaml { response in
                if let yaml = response.result.value, editions = yaml.array {
     
                    let parsedEditions = editions.map { edition in
                        return Edition(yaml: edition)
                    }
                    
                    let mostRecentEvent = parsedEditions.sort { edition1, edition2 in
                        if let firstDate = edition1.date {
                            if let secondDate = edition2.date {
                                return firstDate.compare(secondDate) == .OrderedAscending
                            } else {
                                return false
                            }
                        } else {
                            return true
                        }
                    }.last
                    
                    completion(mostRecentEvent, nil)
                } else if let error = response.result.error {
                    completion(nil, error)
                }
        }

    }
    
    public func getAllVideos(completion: ([String: [Video]]?, ErrorType?) -> Void) {
        
        if let cachedVideos = cachedVideos {
            completion(cachedVideos, nil)
            return
        }
        
        Alamofire.request(.GET, "https://raw.githubusercontent.com/chriseidhof/pomotv/master/data/videos.yml")
            .responseYaml { [weak self] response in
                if let yaml = response.result.value, events = yaml.dictionary {
                    
                    
                    var keys = events.map { key, value in
                        return key.string!
                    }

                    keys.sortInPlace()
                    self?.cachedVideos = [String: [Video]]()
                    
                    for key in keys {
                        
                        if let yamlVideos = events[Yaml(stringLiteral: key)]?.array {
                            let parsedVideos = yamlVideos.map { Video(yaml: $0) }
                            self?.cachedVideos![key] = parsedVideos
                        }
                        
                    }
                    completion(self?.cachedVideos, nil)
                    
                } else if let error = response.result.error {
                    completion(nil, error)
                }
                

        }
    }

    public func thumbnailURLsForVideos(videos: [Video], completion: ([String: NSURL]?, ErrorType?) -> Void) {
        
        let thumbnailGroup = dispatch_group_create()
        
        var urls = [String: NSURL]()
        
        for video in videos {
            dispatch_group_enter(thumbnailGroup)
            thumbnailURLForVideo(video) { url, error in
                if let url = url {
                    urls[video.identifier] = url
                }
                dispatch_group_leave(thumbnailGroup)
            }
        }
        
        dispatch_group_notify(thumbnailGroup, dispatch_get_main_queue()) {
            completion(urls, nil)
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
        case .Vimeo(let id):
            if let vimeoVideo = vimeoVideos[id] {
                completion(vimeoVideo.thumbnailURL(), nil)
                return
            }
            
            YTVimeoExtractor.sharedExtractor().fetchVideoWithIdentifier(String(id), withReferer: nil) { [weak self] vimeoVideo, error in
                
                if let vimeoVideo = vimeoVideo {
                    self?.vimeoVideos[id] = vimeoVideo
                    completion(vimeoVideo.thumbnailURL(), nil)
                    return
                }
                
                if let error = error {
                    completion(nil, error)
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
                
                if let error = error {
                    completion(nil, error)
                }

            }
        case .Vimeo(let id):
            if let vimeoVideo = vimeoVideos[id] {
                completion(vimeoVideo.bestStreamingURL(), nil)
                return
            }
            
            YTVimeoExtractor.sharedExtractor().fetchVideoWithIdentifier(String(id), withReferer: nil) { vimeoVideo, error in
                
                if let vimeoVideo = vimeoVideo {
                    completion(vimeoVideo.bestStreamingURL(), nil)
                    return
                }
                
                if let error = error {
                    completion(nil, error)
                }
            }

        default:
            break;
        }
    
    }

}
