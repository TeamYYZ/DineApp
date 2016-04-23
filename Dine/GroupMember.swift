//
//  GroupMember.swift
//  Dine
//
//  Created by YiHuang on 3/23/16.
//  Copyright © 2016 YYZ. All rights reserved.
//

import Foundation


class GroupMember {
    var userId: String
    var joined: Bool
    var owner: Bool?
    var screenName: String?
    var avatar: PFFile?
    
    init(userId: String, joined: Bool) {
        self.userId = userId
        self.joined = joined
    }
    
    init(userId: String, joined: Bool, screenName: String, avatar: PFFile?) {
        self.userId = userId
        self.joined = joined
        self.screenName = screenName
        self.avatar = avatar
    }

    init(user: User) {
        self.userId = user.userId!
        self.joined = false
        self.screenName = user.screenName
        self.avatar = user.avatarImagePFFile
    }
    
    func setOwner() {
        owner = true
    }
    
    init(dict: NSDictionary) {
        self.userId = dict["userId"] as! String
        self.screenName = dict["screenName"] as? String
        self.avatar = dict["avatar"] as? PFFile
        self.joined = dict["joined"] as! Bool
        self.owner = dict["owner"] as? Bool
    
    }
    
    init(pfObject: PFObject) {
        self.userId = pfObject["userId"] as! String
        self.screenName = pfObject["screenName"] as? String
        self.avatar = pfObject["avatar"] as? PFFile
        self.joined = pfObject["joined"] as! Bool
        self.owner = pfObject["owner"] as? Bool
    }
    
    class func updateLocation(_activityId: String?, userId: String, location: PFGeoPoint, successHandler: (()->()), failureHandler: ((NSError?)->())?) {
        guard let activityId = _activityId else {
            failureHandler?(NSError(domain: "activityId is nil", code: 1, userInfo: nil))
            return
        }
        
        let query = PFQuery(className:"GroupMember")
        query.whereKey("userId", equalTo: userId)
        query.whereKey("activityId", equalTo: activityId)
        query.getFirstObjectInBackgroundWithBlock({ (member:PFObject?, error:NSError?) in
            if error != nil {
                failureHandler?(error)
            } else if let member = member {
                member["location"] = location
                member.saveInBackgroundWithBlock({ (succeed: Bool, error: NSError?) in
                    if (succeed) {
                        successHandler()
                    }else {
                        failureHandler?(error)
                    }
                })
            }
            
        })
    }
    
    func getLocation(activityId: String, successHandler: ((PFGeoPoint)->()), failureHandler: ((NSError?)->())?) {
        let query = PFQuery(className:"GroupMember")
        query.whereKey("userId", equalTo: self.userId)
        query.whereKey("activityId", equalTo: activityId)
        query.getFirstObjectInBackgroundWithBlock({ (member:PFObject?, error:NSError?) in
            if error != nil {
                failureHandler?(error)
            } else if let member = member {
                if let loc = member["location"] as? PFGeoPoint {
                    successHandler(loc)
                }else {
                    failureHandler?(error)
                }
            }
        })
    }
    
}