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
    case Vimeo(String)
    case WWDC(String)
    
    public init(kind: String, id: String?) {

        guard let id = id else {
            self = .Unknown
            return
        }
        
        switch (kind, id) {
        case ("youtube", let youtubeID):
            self = .Youtube(youtubeID)
        case ("vimeo", let vimeoID):
            self = .Vimeo(vimeoID)
        case ("wwdc", let wwdcID):
            self = .WWDC(wwdcID)
        default:
            self = .Unknown
        }
    }
    
    public var kindAndID: (String, String?) {
        switch self {
        case .Youtube(let id):
            return ("youtube", id)
        case .Vimeo(let id):
            return ("vimeo", id)
        case .WWDC(let id):
            return ("wwdc", id)
        case .Unknown:
            return ("unknown", nil)
        }
    }
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
    
    public init(title: String, speakers: [String], source: VideoSource, language: String, tags: [String]?) {
        self.title = title
        self.speakers = speakers
        self.source = source
        self.language = language
        self.tags = tags ?? []
    }

    public init(yaml: Yaml) {
        
        title = yaml["title"].string!
        language = yaml["language"].string!
        speakers = (yaml["speakers"].array?.map { $0.string! })!
        tags = yaml["tags"].array?.map { $0.string! } ??  []
        
        var kind = "unkonwn"
        var id: String?
        
        if let youtubeID = yaml["youtube"].string {
            kind = "youtube"
            id = youtubeID
        } else if let vimeoID = yaml["vimeo"].int {
            kind = "vimeo"
            id = String(vimeoID)
        } else if let wwdcID = yaml["wwdc"].string {
            kind = "wwdc"
            id = wwdcID
        }
        
        source = VideoSource(kind: kind, id: id)

    }
}
