//
//  URLParser.swift
//  pomotv-tvos-client
//
//  Created by Christian Lobach on 05/01/16.
//  Copyright © 2016 Christian Lobach. All rights reserved.
//

import Foundation

public enum URLParserError: ErrorType {
    case InvalidURL
    case InvalidScheme
    case MissingParameters
}

private enum URLParserVideoKey: String {
    case Title
    case Speakers
    case Language
    case Tags
    case SourceKind
    case SourceID
}

public class URLParser {
    
    private static let scheme = "pomotv"
    private static let videoHost = "video"
    
    public static func parseVideoFromURL(url: NSURL) throws -> Video {
        
        guard let components = NSURLComponents(URL: url, resolvingAgainstBaseURL: false) else { throw URLParserError.InvalidURL }
        guard components.scheme == "pomotv" else { throw URLParserError.InvalidScheme }
        guard let queryItems = components.queryItems else { throw URLParserError.MissingParameters }
        guard let title = queryItems[URLParserVideoKey.Title.rawValue] else { throw URLParserError.MissingParameters }
        guard let speakers = queryItems[URLParserVideoKey.Speakers.rawValue]?.componentsSeparatedByString(",") else { throw URLParserError.MissingParameters }
        guard let language = queryItems[URLParserVideoKey.Language.rawValue] else { throw URLParserError.MissingParameters }

        let tags = queryItems[URLParserVideoKey.Tags.rawValue]?.componentsSeparatedByString(",")

        guard let sourceKind = queryItems[URLParserVideoKey.SourceKind.rawValue] else { throw URLParserError.MissingParameters }
        guard let sourceID = queryItems[URLParserVideoKey.SourceID.rawValue] else { throw URLParserError.MissingParameters }
        let source = VideoSource(kind: sourceKind, id: sourceID)
        
        let video = Video(title: title, speakers: speakers, source: source, language: language, tags: tags)

        
        return video
    }
    
    public static func displayURLForVideo(video: Video) -> NSURL? {
        let components = NSURLComponents()
        
        components.scheme = scheme
        components.host = videoHost
        
        let (sourceKind, sourceID) = video.source.kindAndID
        
        guard let id = sourceID else { return nil }
        
        components.queryItems = [
            NSURLQueryItem(name: URLParserVideoKey.Title.rawValue, value: video.title),
            NSURLQueryItem(name: URLParserVideoKey.Language.rawValue, value: video.language),
            NSURLQueryItem(name: URLParserVideoKey.Speakers.rawValue, value: video.speakers.joinWithSeparator(",")),
            NSURLQueryItem(name: URLParserVideoKey.Tags.rawValue, value: video.tags.joinWithSeparator(",")),
            NSURLQueryItem(name: URLParserVideoKey.SourceKind.rawValue, value: sourceKind),
            NSURLQueryItem(name: URLParserVideoKey.SourceID.rawValue, value: id),
        ]
        
        return components.URL
    }
}