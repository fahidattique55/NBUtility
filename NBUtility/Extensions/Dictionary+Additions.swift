//
//  Dictionary+Additions.swift
//  NBUtility
//
//  Created by Fahid Attique on 20/12/2017.
//  Copyright © 2017 Fahid Attique. All rights reserved.
//

import Foundation

extension Dictionary {
    func nullKeyRemoval() -> Dictionary {
        var dict = self
        
        for (key, value) in dict {
            
            if value is Dictionary {
                let innerDict = value as! Dictionary
                dict.updateValue(innerDict.nullKeyRemoval() as! Value, forKey: key)
            } else {
                let keysToRemove = dict.keys.filter { dict[$0] is NSNull }
                for key in keysToRemove {
                    dict.removeValue(forKey: key)
                }
            }
            
        }
        
        return dict
    }
}
