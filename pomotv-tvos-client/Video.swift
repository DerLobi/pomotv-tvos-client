//
//  Video.swift
//  pomotv-tvos-client
//
//  Created by Christian Lobach on 03/01/16.
//  Copyright © 2016 Christian Lobach. All rights reserved.
//

import Foundation
import YamlSwift

public enum VideoSource {
    case Unknown
    case Youtube(String)
    case Vimeo(Int)
}

public struct Video {
    let title: String
    let speakers: [String]
    let tags: [String]
    let language: String
    let source: VideoSource

    public init(yaml: Yaml) {
        title = yaml["title"].string!
        language = yaml["language"].string!
        speakers = (yaml["speakers"].array?.map { $0.string! })!
        tags = yaml["tags"].array?.map { $0.string! } ??  []
        
        if let youtubeID = yaml["youtube"].string {
            source = .Youtube(youtubeID)
        } else if let vimeoID = yaml["vimeo"].int {
            source = .Vimeo(vimeoID)
        } else {
            source = .Unknown
        }
    }
}