//
//  NSArray+Additions.swift
//  NBUtility
//
//  Created by Fahid Attique on 01/08/2017.
//  Copyright © 2017 Fahid Attique. All rights reserved.
//

import Foundation

extension Array {
    mutating func removeObject<T: Equatable> (_ objet: T) -> Bool {
        
        for (idx, objectToCompare) in self.enumerated() {
            if let to = objectToCompare as? T {
                if objet == to {
                    self.remove(at: idx)
                    return true
                }
            }
        }
        return false
    }
    
}

extension Collection where Iterator.Element == String {
    var initials: [String] {
        return map{ String($0.characters.prefix(1)) }
    }
}
