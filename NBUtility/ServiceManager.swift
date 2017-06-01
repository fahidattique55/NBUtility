//
//  ServiceManager.swift
//  NBUtility
//
//  Created by Fahid Attique on 5/30/17.
//  Copyright © 2017 Fahid Attique. All rights reserved.
//

import Foundation
import Alamofire
import ObjectMapper
import AlamofireObjectMapper





/// Application mode
///
/// - Example:
///     - can be used for multiple purposes i.e: testing or for production release


enum AppMode: Int {
    case test = 0, production
}






/// Application mode variable
///
/// - Usage:
///     - Change the app mode from this variable's value



var appMode: AppMode {
    return .test
}







// Create an Enum named as EndPoint to add app specific end points. Conform it with Directable to make you

enum EndPoint: Directable {
    
    
    static var baseUrl: String {
        
        var baseUrl = ""
        
        switch appMode {
        case .test:
            baseUrl = "http://apidev.accuweather.com/currentconditions"
        case .production:
            baseUrl = "http://apidev.accuweather.com/currentconditions"
        }
        
        return baseUrl
    }

    
    
    
    
    case weatherConditions,
    countryList
    
    
    
    
    
    func directableURLString() -> String {
        
        var servicePath = ""
        
        switch (self) {
            
        case .weatherConditions:
            servicePath = "get-weather-conditions"
            
        case .countryList:
            servicePath = "get-countries-data"
            
        }
        
        let tail = "api"
        return EndPoint.baseUrl + "/" + tail + "/" + servicePath
    }
}










/// Service Manager of application
///
/// - Usage:
///     - Must implement the *authorizationHeadersIf* method to send headers to your server
///     - Must implement the *handleServerError* method to validate the error from your server



class ServiceManager: Routable {
    


    
    func authorizationHeadersIf(_ authorized: Bool) -> [String : String]? {
        
        var headers:[String: String]? = nil
        headers = [String : String]()
        if authorized {headers = ["Authorization": "Bearer \("appUtility.appAuthToken!")"]}
        headers!["platform"] = "ios"
        headers!["app-version"] = "1.4.2"
        
        return headers
    }
    
    
    
    


    func handleServerError(_ result: DataResponse<JSONTopModal>, failure: FailureErrorBlock!) -> Bool {
        
        let resultValue = result.value!
        if resultValue.isError {
            
            //            if resultValue.statusCode == loggedInAnotherDeviceErrorCode {
            //                handleTokenError(resultValue.message)
            //            }
            //            else if resultValue.statusCode == UserBlockErrorCode {
            //                handleUserBlockedError(resultValue.message)
            //            }
            //            else if resultValue.statusCode == TranslatorBlockErrorCode {
            //                handleInterpreterBlockedError(resultValue.message)
            //            }
            //            else if resultValue.statusCode == invalidTokenErrorCode {
            //                handleTokenError(resultValue.message)
            //            }
            //            else if resultValue.statusCode == forceUpdateRequired {
            //                handleForceUpdate(resultValue.message)
            //            }
            //            else {
            failure(NSError(errorMessage: resultValue.message, code: resultValue.statusCode))
            //            }
            
            return true
        }
        return false
    }
    
}
