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
    return .production
}







// Extension of UrlService to add app specific url service methods
//
// - Examples:
//     - static let login  = UrlService(rawValue: "user/login")
//     - static let logout = UrlService(rawValue: "user/logout")



extension UrlService {
    static let weatherConditions  = UrlService(rawValue: "260622.json?language=en&apikey=hoArfRosT1215")
}









// Extension of UrlService to conform protocol UrlDirectable
//
// - Warning !!!
//     - Must implement this method to define app specific directable URLs including base, tail and service method strings
//     - static let logout = UrlService(rawValue: "user/logout")




extension UrlService: UrlDirectable {
    
    func directableURLString() -> String {
        
        let servicePath = self.rawValue
        let tail = "v1"
        return ServiceManager.baseUrl + "/" + tail + "/" + servicePath
    }
}










/// Service Manager of application
///
/// - Usage:
///     - Must implement the *authorizationHeadersIf* method to send headers to your server
///     - Must implement the *handleServerError* method to validate the error from your server



class ServiceManager: Routable {
    
    
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
    
    

    
    
    
    
    /// Header Authorization
    ///
    /// - Parameters:
    ///     - authorized:   Bool value to send app specific headers to your header

    func authorizationHeadersIf(_ authorized: Bool) -> [String : String]? {
        
        var headers:[String: String]? = nil
        headers = [String : String]()
        if authorized {headers = ["Authorization": "Bearer \("appUtility.appAuthToken!")"]}
        headers!["platform"] = "ios"
        
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            headers!["app-version"] = version
        }
        
        return headers
    }
    
    
    
    
    
    

    /// Error validation of your server
    ///
    /// - Parameters:
    ///     - result:    Auto-mapped JSON top model to handle error. You can take many decisions on this reponse i.e: Token Expiry etc
    ///     - failure:   *Failure block* -> used by Routable protocol in shared implementation

    func handleServerError(_ result: DataResponse<JSONTopModal>, failure: Routable.FailureErrorBlock!) -> Bool {
        
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
