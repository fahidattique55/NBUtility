//
//  FacebookManager.swift
//  NBUtility
//
//  Created by Fahid Attique on 04/08/2017.
//  Copyright © 2017 Fahid Attique. All rights reserved.
//

import Foundation
import FBSDKLoginKit
import FBSDKCoreKit

class FacebookManager {
    
    fileprivate let cancelError = "You have cancelled Login."
    
    func tryAuthenticate(fromViewController viewController:UIViewController, success: @escaping ((_ facebookToken:String) -> Void),
                                                  failureBlock failure: @escaping ((_ error: NSError?) -> Void)) {
        
        if let currentAccessToken = FBSDKAccessToken.current() {
            success(currentAccessToken.tokenString)
            return
        }
        
        let fbLoginManager = FBSDKLoginManager()
        fbLoginManager.loginBehavior = .browser
        
        fbLoginManager.logIn(withReadPermissions: ["email"], from: viewController) { (result, error) in
            
            if let facebookError = error { //If any error returned from Facebook
                failure(facebookError as NSError?)
                return
            }
            
            if (result?.isCancelled)! { //If user has cancelled the login
                let canceledError = NSError(errorMessage: self.cancelError);
                failure(canceledError)
                return
            }
            
            
            success((result?.token.tokenString)!)
        }
        
    }
    
    func fetchLoggedUserInfo(successBlock success: @escaping ((_ facebookUserInfo:[String : AnyObject]) -> Void),
                                          failureBlock failure: @escaping ((_ error: NSError?) -> Void)) {
        
        let meRequest = FBSDKGraphRequest(graphPath: "me", parameters: nil)
        _ = meRequest?.start { (connection, graphObject, error) in
            
            if error != nil {
                failure(error as NSError?)
                return
            }
            
            success(graphObject as! [String: AnyObject])
        }
        
    }
    
    
    class func logout() {
        FBSDKLoginManager().logOut()
    }
    
}
