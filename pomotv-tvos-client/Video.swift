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
    case WWDC(String)
}

public struct Video {
    public let title: String
    public let speakers: [String]
    public let tags: [String]
    public let language: String
    public let source: VideoSource
    
    public var identifier: String {
        switch source {
        case .Youtube(let id):
            return "youtube:\(id)"
        case .Vimeo(let id):
            return "vimeo:\(id)"
        case .WWDC(let id):
            return "wwdc:\(id)"
        case .Unknown:
            return "unknown:\(title)"
        }
    }

    public init(yaml: Yaml) {
        title = yaml["title"].string!
        language = yaml["language"].string!
        speakers = (yaml["speakers"].array?.map { $0.string! })!
        tags = yaml["tags"].array?.map { $0.string! } ??  []
        
        if let youtubeID = yaml["youtube"].string {
            source = .Youtube(youtubeID)
        } else if let vimeoID = yaml["vimeo"].int {
            source = .Vimeo(vimeoID)
        } else if let wwdcID = yaml["wwdc"].string {
            source = .WWDC(wwdcID)
        } else {
            source = .Unknown
        }
    }
}
