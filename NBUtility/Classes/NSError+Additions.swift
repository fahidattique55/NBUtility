//
//  NSError+Additions.swift
//  NBUtility
//
//  Created by Fahid Attique on 29/05/2017.
//  Copyright © 2017 Fahid Attique. All rights reserved.
//

import Foundation

let appDomain = "com.appDomain"
let generalAppError = "Something went wrong."

public extension NSError {
    public convenience init(errorMessage:String?, code: Int? = nil) {
        
        var errorMessage = errorMessage
        
        if errorMessage == nil {
            errorMessage = generalAppError
        }
        
        var errorCode = -1
        if let code = code { errorCode = code}
        
        self.init(domain: appDomain, code: errorCode, userInfo: [NSLocalizedDescriptionKey: errorMessage!])
    }
    
}
