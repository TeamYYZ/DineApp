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
    
    class func fetchGroupMember(activityId: String, successHandler: ([GroupMember])->(), failureHandler: ((NSError?)->())?) {
        let activityQuery = PFQuery(className: "Activity")
        activityQuery.getObjectInBackgroundWithId(activityId, block: { (activity: PFObject?, error: NSError?) -> Void in
            if error == nil && activity != nil{
                print("fetchGroupMember in GroupMember success")
                if let groupMembers = activity!["groupMembers"] as? [NSDictionary]{
                    var ret = [GroupMember]()
                    for member in groupMembers {
                        ret.append(GroupMember(dict: member))
                    
                    }
                    successHandler(ret)
                    return
                }
                
            }
            print("fetchGroupMember in GroupMember failure")

            failureHandler?(error)
        })
    
    
    }
    
}