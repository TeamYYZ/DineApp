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
    
    class func sendVericode(mobileNumber: String, successHandler: (vericode: String)->(), failureHandler: ((NSError?)->())?) {
        PFCloud.callFunctionInBackground("verifyCellPhoneNumber", withParameters: ["cellNumber": mobileNumber]) {
            (response: AnyObject?, error: NSError?) -> Void in
            if error == nil {
                Log.info("vericode sent")
                if let vericode = response as? String {
                    successHandler(vericode: vericode)
                }
            } else {
                failureHandler?(error!)
            }
            
        }
    
    }
    
    class func signUp(username: String, password: String, screenName: String, successCallback: ()->(), failureCallback: (NSError?)->()) {
        let user = PFUser()
        user.username = username
        user.password = password
        user["screenName"] = screenName
        user.signUpInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
            if success {
                User.currentUser = User(pfUser: user)
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
    
    class func getActivites(locSW: CLLocation, locNE: CLLocation, completion: (acts: [Activity]!, error: NSError?) -> Void) {
        let query = PFQuery(className: "Activity")
        query.whereKey("isPublic", equalTo: true)
        query.whereKey("pfLocation", withinGeoBoxFromSouthwest: PFGeoPoint(location: locSW) , toNortheast: PFGeoPoint(location: locNE))
        query.limit = 10
        query.findObjectsInBackgroundWithBlock { (activities: [PFObject]?, error: NSError?) -> Void in
            if let actObjects = activities {
                // do something with the data fetched
                let acts = Activity.activitiesWithArray(actObjects)
                completion(acts: acts, error: nil)
                
            } else {
                // handle error
                completion(acts: nil, error: error)
            }
        }
    }

    class func getUserByID(id: String!, completion: (screenName: String!, error: NSError?) -> Void) {
        let user = try? PFQuery.getUserObjectWithId(id)
        
        if let user = user {
        if let screenName = user["screenName"] as? String{
            completion(screenName: screenName, error: nil)
        }
        }
        completion(screenName: nil, error: nil)
    }


}
