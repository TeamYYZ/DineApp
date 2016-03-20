//
//  ParseAPI.swift
//  Dine
//
//  Created by YiHuang on 3/15/16.
//  Copyright © 2016 YYZ. All rights reserved.
//

import UIKit
import Parse

class ParseAPI {
    static var sharedInstance = ParseAPI()
    
    class func signUp(username: String, password: String, screenName: String, successCallback: ()->(), failureCallback: (NSError?)->()) {
        let user = PFUser()
        user.username = username
        user.password = password
        user["screenName"] = screenName
        user.signUpInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
            if success {
                successCallback()
            } else {
                failureCallback(error)
            }
            
        }
    
    }
    
    class func signIn(username: String, password: String, successCallback: ()->(), failureCallback: (NSError?)->()) {
        PFUser.logInWithUsernameInBackground(username, password: password) { (user: PFUser?, error: NSError?) -> Void in
            if let user = user {
                User.currentUser = User(pfUser: user)
                successCallback()
                
            } else {
                failureCallback(error)
            }
        }
    
    }
    
    



}
