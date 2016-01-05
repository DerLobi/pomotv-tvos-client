//
//  ArrayExtensions.swift
//  pomotv-tvos-client
//
//  Created by Christian Lobach on 05/01/16.
//  Copyright © 2016 Christian Lobach. All rights reserved.
//

import Foundation

extension Array where Element: NSURLQueryItem {
    
    subscript(key: String) -> String? {
        
        for queryItem in self {
            if queryItem.name == key {
                return queryItem.value
            }
        }
        
        return nil
        
    }
    
    
}