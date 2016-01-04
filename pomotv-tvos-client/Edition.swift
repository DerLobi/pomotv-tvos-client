//
//  Edition.swift
//  pomotv-tvos-client
//
//  Created by Christian Lobach on 04/01/16.
//  Copyright © 2016 Christian Lobach. All rights reserved.
//

import Foundation
import YamlSwift

public struct Edition {

    // the currently used possible different date formats
    private static var dateFormatters: [NSDateFormatter] = {
        let formats = [
            "MMMM dd, yyyy",
            "MMM dd, yyyy",
            "MMMM d, yyyy",
            "MMM d, yyyy"
        ]
        
        let formatters = formats.map({ format -> NSDateFormatter in
            let formatter = NSDateFormatter()
            formatter.dateFormat = format
            return formatter
        })
        
        return formatters
    }()
    
    public let event: String
    public let edition: String
    public let url: NSURL?
    public let date: NSDate?

    public var displayName: String {
        return "\(event) \(edition)"
    }
    
    public init(yaml: Yaml) {
        event = yaml["event"].string!
        edition =  yaml["edition"].string ?? String(yaml["edition"].int!)
        url = NSURL(string: yaml["url"].string!)
        date = self.dynamicType.dateFromString(yaml["date"].string!)
    }
    
    private static func dateFromString(string: String) -> NSDate? {
        
        // Only consider the start date, i.e. turn "February 4-6, 2015" into "February 4, 2015"
        let sanitizedString: String
        do {
            let regex = try NSRegularExpression(pattern: "[-–]+\\d+", options: NSRegularExpressionOptions())
            
            let castedString = string as NSString
            let range = castedString.rangeOfString(string)
             sanitizedString = regex.stringByReplacingMatchesInString(string, options: NSMatchingOptions(), range: range, withTemplate: "")
        } catch {
            return nil
        }
        
        var parsedDate: NSDate?
        
        for formatter in dateFormatters {
            if let _ = parsedDate {
                break
            }
            
            parsedDate = formatter.dateFromString(sanitizedString)
        }
        return parsedDate
    }
}

extension Edition: Equatable {}

public func ==(lhs: Edition, rhs: Edition) -> Bool {
    return lhs.event == rhs.event && lhs.edition == rhs.edition
}
