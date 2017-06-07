//
//  String+Additions.swift
//  NBUtility
//
//  Created by Fahid Attique on 01/08/2017.
//  Copyright © 2017 Fahid Attique. All rights reserved.
//

import Foundation

extension String {
    var length: Int { return characters.count}
    
    mutating func removeFirstCharacter() -> Character {
        return remove(at: startIndex)
    }
    
    func characterAtIndex(_ index: Int) -> Character {
        return self[characters.index(startIndex, offsetBy: index)]
    }
    
    mutating func insertCharacter(_ character: Character, atIndex index: Int) -> () {
        
        guard index < length else { return }
        
        insert(character, at: self.index(startIndex, offsetBy: 4))
    }
    
    func dateFromString(_ pattern:String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = pattern
        return dateFormatter.date(from: self)
    }
}
