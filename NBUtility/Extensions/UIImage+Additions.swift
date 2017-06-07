//
//  UIImage+Additions.swift
//  NBUtility
//
//  Created by Fahid Attique on 10/08/2017.
//  Copyright © 2017 Fahid Attique. All rights reserved.
//

import UIKit

extension UIImage {
    
    fileprivate class func resolveAdaptiveImageName(_ nameStem: String) -> String {
        
        let height = UIScreen.main.bounds.size.height
        
        if height > 568.0 {
            // Oversize @2x will be used for iPhone 6, @3x for iPhone 6+
            // iPads... we'll work that out later
            if height > 667.0 {
                return nameStem + "-oversize@3x"
            } else {
                return nameStem + "-oversize"
            }
        }
        return nameStem
    }
    
    class func adaptiveImageNamed(_ name: String) -> UIImage? {
        return UIImage(named: resolveAdaptiveImageName(name))
    }
    
}
