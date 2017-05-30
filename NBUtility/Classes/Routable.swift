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
import QorumLogs




/// Returns the url string by appending base, tail and UrlService string ---
/// Make sure to comform this protocol with *Struct UrlService* in your service manager file to return full url strings


public protocol Directable: MapContext {
    func directableURLString() -> String
}






/// Extend the *UrlService* to add your app specific url service strings
///
/// - Example:
///     - static let login  = UrlService(rawValue: "user/login")
///     - static let logout = UrlService(rawValue: "user/logout")



public struct UrlService : RawRepresentable {
    
    public typealias RawValue = String
    public var rawValue: String
    public init(rawValue: RawValue) {
        self.rawValue = rawValue
    }
}







///  Service template type closures for auto-mapping of custom object and custom object's array

public struct ServiceSuccessBlock<T> {
    typealias array = (_ response: HTTPURLResponse?, _ result: [T]?) -> Void
    typealias object = (_ response: HTTPURLResponse?, _ result: T?) -> Void
}





// Service response closures

public typealias SuccessJSONBlock = (_ response: HTTPURLResponse?, _ result: JSONTopModal) -> Void
public typealias FailureErrorBlock = (_ error: NSError) -> Void







///  JSON top model or base model for all server API call responses

public class JSONTopModal: Mappable {
    
    var isError: Bool = false
    var message: String = ""
    var statusCode: Int = 0
    var data: AnyObject = NSObject()
    
    required public init?(map: Map) {}
    
    public func mapping(map: Map) {
        
        isError <- map["error"]
        message <- map["message"]
        data <- map["data"]
        statusCode <- map["status_code"]
    }
}





///     Service method types for API calls

public enum ServiceMethod {
    
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


public protocol Routable {


    
    /// Header Authorization
    ///
    /// - Parameters:
    ///     - authorized:   Bool value to send app specific headers to your header

    func authorizationHeadersIf(_ authorized:Bool) -> [String: String]?

    
    
    /// Error validation of your server
    ///
    /// - Parameters:
    ///     - result:    Auto-mapped JSON top model to handle error. You can take many decisions on this reponse i.e: Token Expiry etc
    ///     - failure:   *Failure block* -> used by Routable protocol in shared implementation

    func handleServerError(_ result: DataResponse<JSONTopModal>, failure: FailureErrorBlock!) -> Bool

}





//  Extension of Routable protocol for providing shared implementation of request, response and error handling methods


extension Routable {
    


                                                        //MARK: - Simple Requests

    
    
    
    /// Request method for non-mapping responses
    ///
    /// - Parameters:
    ///     - method:       *Service* type
    ///     - service:      *Service URL*
    ///     - parameters:   *Request JSON* parameters
    ///     - authorized:   Bool value for sending *Authorized Headers*
    ///     - encoding:     Encoding type for *Request JSON* parameters
    ///     - success:      *Success Block*
    ///     - failure:      *Failure Block*
    
    func request(_ method: ServiceMethod,
                 service: Directable,
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
    ///     - mapperClass:  Object type for auto-mapping
    ///     - encoding:     Encoding type for *Request JSON* parameters
    ///     - success:      *Success Block*
    ///     - failure:      *Failure Block*
    
    func requestForObject<T : Mappable>(_ method: ServiceMethod,
                 service: Directable,
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
    ///     - mapperClass:  Object type for auto-mapping
    ///     - encoding:     Encoding type for *Request JSON* parameters
    ///     - success:      *Success Block*
    ///     - failure:      *Failure Block*
    
    func requestForArray<T : Mappable>(_ method: ServiceMethod,
                 service: Directable,
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
    ///     - success:      *Success Block*
    ///     - failure:      *Failure Block*

    func simpleRequest(_ method: ServiceMethod,
                       service: Directable,
                       parameters: [String: AnyObject]?,
                       authorized: Bool,
                       encoding: ParameterEncoding = JSONEncoding.default,
                       success: SuccessJSONBlock!,
                       failure: FailureErrorBlock!) -> Request{
        
        
        
        let urlString = service.directableURLString()
        
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
    
    
    
    
    
                                                        //MARK: - Multipart Requests

    
    
    
    
    /// Request method for non-mapping responses
    ///
    /// - Parameters:
    ///     - method:               *Service* type
    ///     - service:              *Service URL*
    ///     - multipartFormData:    *multipart* block
    ///     - uploadProgress:       *progress* block
    ///     - sessionTask:          *URLSessionTask* block
    ///     - authorized:           Bool value for sending *Authorized Headers*
    ///     - success:              *Success Block*
    ///     - failure:              *Failure Block*

    func mutipartRequest(_ method: ServiceMethod,
                 service: Directable,
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
    
    

    
    
    
    /// Request method for auto-mapping of server response to custom business medels
    ///
    /// - Parameters:
    ///     - method:               *Service* type
    ///     - service:              *Service URL*
    ///     - multipartFormData:    *multipart* block
    ///     - uploadProgress:       *progress* block
    ///     - sessionTask:          *URLSessionTask* block
    ///     - authorized:           Bool value for sending *Authorized Headers*
    ///     - mapperClass:          Object type for auto-mapping
    ///     - success:              *Success Block*
    ///     - failure:              *Failure Block*

    
    func mutipartRequestForObject<T : Mappable>(_ method: ServiceMethod,
                 service: Directable,
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
    
    
    
    
    
    
    /// Request method for auto-mapping of server response to array of custom business medels
    ///
    /// - Parameters:
    ///     - method:               *Service* type
    ///     - service:              *Service URL*
    ///     - multipartFormData:    *multipart* block
    ///     - uploadProgress:       *progress* block
    ///     - sessionTask:          *URLSessionTask* block
    ///     - authorized:           Bool value for sending *Authorized Headers*
    ///     - mapperClass:          Object type for auto-mapping
    ///     - success:              *Success Block*
    ///     - failure:              *Failure Block*

    func mutipartRequestForArray<T : Mappable>(_ method: ServiceMethod,
                 service: Directable,
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

    
    
    
    
    
    
    /// Simple Request method used in *mutipartRequest*, *mutipartRequestForObject* and *mutipartRequestForArray* for API calls
    ///
    /// - Parameters:
    ///     - method:               *Service* type
    ///     - service:              *Service URL*
    ///     - multipartFormData:    *multipart* block
    ///     - uploadProgress:       *progress* block
    ///     - sessionTask:          *URLSessionTask* block
    ///     - authorized:           Bool value for sending *Authorized Headers*
    ///     - success:              *Success Block*
    ///     - failure:              *Failure Block*

    func multipartRequest(_ method: ServiceMethod,
                          service: Directable,
                          multipartFormData: @escaping ((MultipartFormData) -> Void),
                          uploadProgress: @escaping ((Progress) -> Void),
                          sessionTask: ((_ task: URLSessionTask) -> Void)?,
                          authorized: Bool,
                          success: SuccessJSONBlock!,
                          failure: FailureErrorBlock!) {
        
        
        let urlString = service.directableURLString()
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
                    QL2("Upload Progress: \(Progress.fractionCompleted)")
                    uploadProgress(Progress)
                })
                
                
            case .failure(let encodingError):
                self.visibleNetworkActivityIndicator(false)
                let error = encodingError as NSError
                failure(error)
            }
        }
    }
    
    
    
    
    
                                                        //MARK: - Network Visiblity

    
    
    
    
    /// Set visiblity of activity indicator
    ///
    /// - Parameters:
    ///     - visible:           Bool value for making *activity indicator* visible

    func visibleNetworkActivityIndicator(_ visible: Bool) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = visible
    }
    

    
    
    
    
    
    
    
    
    
                                                        //MARK: - Response Handling

    
    
    
    
    
    /// Receiving response from server for API calls
    ///
    /// - Parameters:
    ///     - response:          Response from server which is auto-mapped to *JSONTopModal*
    ///     - success:           *Success Block*
    ///     - failure:           *Failure Block*

    func handleServerResponse(_ response: DataResponse<JSONTopModal>, success: SuccessJSONBlock!, failure: FailureErrorBlock!) {
        
        //Hide Network Activity Indicator whatever the case is.
        visibleNetworkActivityIndicator(false)
        
        let result = response.result
        
        if self.checkForError(response, failure: failure) { return}
        
        //Here is the success case. Because error is already handled in above code
        let requestResponse = response.response
        let resultValue = result.value!
        
        QL1("response: \(requestResponse)")
        QL1("result: \(resultValue)")
        QL1(resultValue.data as Any)
        
        success(requestResponse, resultValue)
    }

    
    
    
    
    
    
    
                                                            //MARK: - Error Handling

    
    
    
    
    /// Handling error in case of API call failure
    ///
    /// - Parameters:
    ///     - result:     Response from server which is auto-mapped to *JSONTopModal*
    ///     - failure:    *Failure Block*

    
    func checkForError(_ result: DataResponse<JSONTopModal>, failure: FailureErrorBlock!) -> Bool {
        
        if let failureError = result.error {
            
            if failureError is AFError {
                
                switch failureError as! AFError {
                case .responseSerializationFailed( _):
                    failure(NSError(errorMessage: "Server is not responding"))
                default:
                    failure(NSError(errorMessage: "Server is not responding"))
                }
            }
            else {
                failure(result.error! as NSError)
            }
            return true
        }
        
        return handleServerError(result, failure: failure)
    }

}
