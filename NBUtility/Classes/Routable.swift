//
//  Routable.swift
//  NBUtility
//
//  Created by Fahid Attique on 29/05/2017
//  Copyright © 2017 Fahid Attique. All rights reserved.
//

import Alamofire
import ObjectMapper
import AlamofireObjectMapper





///  Service template type closures

struct ServiceSuccessBlock<T> {
    typealias array = (_ response: HTTPURLResponse?, _ result: [T]?) -> Void
    typealias object = (_ response: HTTPURLResponse?, _ result: T?) -> Void
}





///  JSON top model or base model for all server API call responses

class JSONTopModal: Mappable {
    
    var isError: Bool = false
    var message: String = ""
    var statusCode: Int = 0
    var data: AnyObject = NSObject()
    
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        
        isError <- map["error"]
        message <- map["message"]
        data <- map["data"]
        statusCode <- map["status_code"]
    }
    
}





///     Service method types for API calls

enum ServiceMethod {
    
    case get, post, put, delete
    
    var urlMethod: HTTPMethod {
        
        var method: HTTPMethod
        
        switch self {
        case .get:
            method = .get
            
        case .post:
            method = .post
            
        case .put:
            method = .put
            
        case .delete:
            method = .delete
        }
        return method
    }
}







/// Routable Protocol  ---  Shared implementation of helper methods for API calls is implemented in its extension


protocol Routable {

    typealias SuccessJSONBlock = (_ response: HTTPURLResponse?, _ result: JSONTopModal) -> Void
    typealias FailureErrorBlock = (_ error: NSError) -> Void
    

}





//  Extension of Routable protocol


extension Routable {
    

    
    
    
    
    /// Request method for non-mapping responses
    ///
    /// - Parameters:
    ///     - method:       *Service* type
    ///     - service:      *Service URL*
    ///     - parameters:   *Request JSON* parameters
    ///     - authorized:   Bool value for sending *Authorized Headers*
    ///     - encoding:     Encoding type for *Request JSON* parameters
    ///     - success:      *Service Block*
    ///     - failure:      *Failure Block*
    
    func request(_ method: ServiceMethod,
                 service: Url.Service,
                 parameters: [String: AnyObject]? = nil,
                 authorized: Bool = false,
                 encoding: ParameterEncoding = JSONEncoding.default,
                 success: SuccessJSONBlock!,
                 failure: FailureErrorBlock!) -> URLSessionTask {
        
        let request = simpleRequest(method, service: service, parameters: parameters, authorized: authorized, encoding: encoding, success: { (response, result) in
            success(response, result)
        }) { (fail) in
            failure(fail)
        }
        return request.task!
    }
    
    
    
    
    
    
    
    
    /// Request method for auto-mapping of server response to custom business medels
    ///
    /// - Parameters:
    ///     - method:       *Service* type
    ///     - service:      *Service URL*
    ///     - parameters:   *Request JSON* parameters
    ///     - authorized:   Bool value for sending *Authorized Headers*
    ///     - encoding:     Encoding type for *Request JSON* parameters
    ///     - success:      *Service Block*
    ///     - failure:      *Failure Block*
    
    func requestObject<T : Mappable>(_ method: ServiceMethod,
                 service: Url.Service,
                 parameters: [String: AnyObject]? = nil,
                 authorized: Bool = false,
                 mapperClass:T.Type,
                 encoding: ParameterEncoding = JSONEncoding.default,
                 success: @escaping ServiceSuccessBlock<T>.object,
                 failure: FailureErrorBlock!) -> URLSessionTask {
        
        let request = simpleRequest(method, service: service, parameters: parameters, authorized: authorized, encoding:encoding,  success: { (response, result) in
            
            let resultData = result.data as! [String: AnyObject]
            let resultObject = Mapper<T>(context: service).map(JSON: resultData)
            success(response, resultObject)
            
        }, failure: failure)
        return request.task!
    }
    
    
    
    
    
    
    
    /// Request method for auto-mapping of server response to array of custom business medels
    ///
    /// - Parameters:
    ///     - method:       *Service* type
    ///     - service:      *Service URL*
    ///     - parameters:   *Request JSON* parameters
    ///     - authorized:   Bool value for sending *Authorized Headers*
    ///     - encoding:     Encoding type for *Request JSON* parameters
    ///     - success:      *Service Block*
    ///     - failure:      *Failure Block*
    
    func requestArray<T : Mappable>(_ method: ServiceMethod,
                 service: Url.Service,
                 parameters: [String: AnyObject]? = nil,
                 authorized: Bool = false,
                 mapperClass:T.Type,
                 encoding: ParameterEncoding = JSONEncoding.default,
                 success: @escaping ServiceSuccessBlock<T>.array,
                 failure: FailureErrorBlock!) -> URLSessionTask {
        
        let request = simpleRequest(method, service: service, parameters: parameters, authorized: authorized, encoding: encoding, success: { (response, result) in
            
            let resultData = result.data as! [[String: AnyObject]]
            let resultArray = Mapper<T>(context: service).mapArray(JSONArray: resultData)
            success(response, resultArray)
            
        }, failure: failure)
        
        return request.task!
    }
    
    
    
    
    
    
    
    
    /// Simple Request method used in *request*, *requestObject* and *requestArray* for API calls
    ///
    /// - Parameters:
    ///     - method:       *Service* type
    ///     - service:      *Service URL*
    ///     - parameters:   *Request JSON* parameters
    ///     - authorized:   Bool value for sending *Authorized Headers*
    ///     - encoding:     Encoding type for *Request JSON* parameters
    ///     - success:      *Service Block*
    ///     - failure:      *Failure Block*

    func simpleRequest(_ method: ServiceMethod,
                       service: Url.Service,
                       parameters: [String: AnyObject]?,
                       authorized: Bool,
                       encoding: ParameterEncoding = JSONEncoding.default,
                       success: SuccessJSONBlock!,
                       failure: FailureErrorBlock!) -> Request{
        
        let urlString = Url.urlString(service)
        
        let request = Alamofire.request(urlString, method: method.urlMethod, parameters: parameters, encoding: encoding, headers: authorizationHeadersIf(authorized))
        
        
        if let params = parameters {
            QL1("Parameters: \(params)")
        }
        
        visibleNetworkActivityIndicator(true)
        
        request.responseObject { (response: DataResponse<JSONTopModal>) in
            self.handleServerResponse(response, success: success, failure: failure)
        }
        
        return request
    }
    
    
    
    /// Simple Request method used in *request*, *requestObject* and *requestArray* for API calls
    ///
    /// - Parameters:
    ///     - method:       *Service* type
    ///     - service:      *Service URL*
    ///     - parameters:   *Request JSON* parameters
    ///     - authorized:   Bool value for sending *Authorized Headers*
    ///     - encoding:     Encoding type for *Request JSON* parameters
    ///     - success:      *Service Block*
    ///     - failure:      *Failure Block*

    func request(_ method: ServiceMethod,
                 service: Url.Service,
                 multipartFormData: @escaping ((MultipartFormData) -> Void),
                 uploadProgress: @escaping ((Progress) -> Void),
                 sessionTask: ((_ task: URLSessionTask) -> Void)? = nil,
                 authorized: Bool = false,
                 success: SuccessJSONBlock!,
                 failure: FailureErrorBlock!) {
        
        multipartRequest(method, service: service, multipartFormData: multipartFormData, uploadProgress: uploadProgress, sessionTask: sessionTask, authorized: authorized, success: { (response, result) in
            
            success(response, result)
            
        }, failure: failure)
        
    }
    
    func request<T : Mappable>(_ method: ServiceMethod,
                 service: Url.Service,
                 multipartFormData: @escaping ((MultipartFormData) -> Void),
                 uploadProgress: @escaping ((Progress) -> Void),
                 sessionTask: ((_ task: URLSessionTask) -> Void)? = nil,
                 authorized: Bool = false,
                 mapperClass:T.Type,
                 success: @escaping ServiceSuccessBlock<T>.object,
                 failure: FailureErrorBlock!) {
        
        multipartRequest(method, service: service, multipartFormData: multipartFormData, uploadProgress: uploadProgress, sessionTask: sessionTask, authorized: authorized, success: { (response, result) in
            
            let resultData = result.data as! [String: AnyObject]
            let resultObject = Mapper<T>(context: service).map(JSON: resultData)
            success(response,resultObject)
            
        }, failure: failure)
        
    }
    
    func request<T : Mappable>(_ method: ServiceMethod,
                 service: Url.Service,
                 multipartFormData: @escaping ((MultipartFormData) -> Void),
                 uploadProgress: @escaping ((Progress) -> Void),
                 sessionTask: ((_ task: URLSessionTask) -> Void)? = nil,
                 authorized: Bool = false,
                 mapperClass:T.Type,
                 success: @escaping ServiceSuccessBlock<T>.array,
                 failure: FailureErrorBlock!){
        
        multipartRequest(method, service: service, multipartFormData: multipartFormData, uploadProgress:  uploadProgress, sessionTask: sessionTask, authorized: authorized, success: { (response, result) in
            
            let resultData = result.data as! [[String: AnyObject]]
            let resultArray = Mapper<T>(context: service).mapArray(JSONArray: resultData)
            success(response, resultArray)
            
        }, failure: failure)
    }

    
    func multipartRequest(_ method: ServiceMethod,
                          service: Url.Service,
                          multipartFormData: @escaping ((MultipartFormData) -> Void),
                          uploadProgress: @escaping ((Progress) -> Void),
                          sessionTask: ((_ task: URLSessionTask) -> Void)?,
                          authorized: Bool,
                          success: SuccessJSONBlock!,
                          failure: FailureErrorBlock!) {
        
        
        let urlString = Url.urlString(service)
        visibleNetworkActivityIndicator(true)
        
        
        let headers: HTTPHeaders = authorizationHeadersIf(authorized)!
        let URL = try! URLRequest(url: urlString, method: .post, headers: headers)
        
        
        Alamofire.upload(multipartFormData: multipartFormData, with: URL) { (encodingResult) in
            
            switch encodingResult {
                
            case .success(let request, _, _):
                
                if let sessionTask = sessionTask { sessionTask(request.task!)}
                
                request.responseObject { (response: DataResponse<JSONTopModal>) in
                    self.handleServerResponse(response, success: success, failure: failure)
                }
                
                request.uploadProgress(closure: { (Progress) in
                    print("Upload Progress: \(Progress.fractionCompleted)")
                    uploadProgress(Progress)
                })
                
                
            case .failure(let encodingError):
                self.visibleNetworkActivityIndicator(false)
                let error = encodingError as NSError
                failure(error)
            }
        }
    }
    
    
    
    func visibleNetworkActivityIndicator(_ visible: Bool) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = visible
    }
    
    
    func handleServerResponse(_ response: DataResponse<JSONTopModal>, success: SuccessJSONBlock!, failure: FailureErrorBlock!) {
        
        //        print("response URL: \(response.response?.URL)")
        
        //Hide Network Activity Indicator whatever the case is.
        visibleNetworkActivityIndicator(false)
        
        let result = response.result
        
        if self.checkForError(response, failure: failure) { return}
        
        //Here is the success case. Because error is already handled in above code
        let requestResponse = response.response
        let resultValue = result.value!
        
        
        
        //        if appMode == .test {
        print("response: \(requestResponse)")
        print("result: \(resultValue)")
        print(resultValue.data as Any)
        //        }
        
        
        success(requestResponse, resultValue)
    }

}



// MARK:- Private Methods

//private extension ServiceManager {
//    
//    func authorizationHeadersIf(_ authorized:Bool) -> [String: String]? {
//        var headers:[String: String]? = nil
//        headers = [String : String]()
//        if authorized {headers = ["Authorization": "Bearer \(appUtility.appAuthToken!)"]}
//        headers!["api-version"] = "1"
//        headers!["platform"] = "ios"
//        
//        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
//            headers!["app-version"] = version
//        }
//        
//        return headers
//    }
//    
//    func checkForError(_ result: DataResponse<JSONTopModal>, failure: FailureErrorBlock!) -> Bool {
//        
//        if let failureError = result.error {
//            
//            if failureError is AFError {
//                
//                switch failureError as! AFError {
//                case .responseSerializationFailed( _):
//                    failure(NSError(errorMessage: messageServerError))
//                default:
//                    failure(NSError(errorMessage: messageServerError))
//                }
//            }
//            else {
//                failure(result.error as! NSError)
//            }
//            
//            return true
//        }
//        
//        let resultValue = result.value!
//        
//        if resultValue.isError {
//            QL3("Error Code: " + String(resultValue.statusCode))
//            
//            if resultValue.statusCode == loggedInAnotherDeviceErrorCode {
//                appUtility.handleTokenError(resultValue.message)
//            }
//            else if resultValue.statusCode == UserBlockErrorCode {
//                appUtility.handleUserBlockedError(resultValue.message)
//            }
//            else if resultValue.statusCode == TranslatorBlockErrorCode {
//                appUtility.handleInterpreterBlockedError(resultValue.message)
//            }
//            else if resultValue.statusCode == invalidTokenErrorCode {
//                appUtility.handleTokenError(resultValue.message)
//            }
//            else if resultValue.statusCode == forceUpdateRequired {
//                appUtility.handleForceUpdate(resultValue.message)
//            }
//            else {
//                failure(NSError(errorMessage: resultValue.message, code: resultValue.statusCode))
//            }
//            
//            return true
//        }
//        
//        return false
//    }
//    
//    
//}

