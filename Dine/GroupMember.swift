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
    
    class func fetchGroupMember(uniqueId: String, successHandler: ([GroupMember])->(), failureHandler: ((NSError?)->())?) {
        let groupMemberQuery = PFQuery(className: "GroupMember_" + uniqueId)
        groupMemberQuery.findObjectsInBackgroundWithBlock { (groupMembersList: [PFObject]?, error: NSError?) in
            if error == nil && groupMembersList != nil {
                var ret = [GroupMember]()
                for groupMember in groupMembersList! {
                    ret.append(GroupMember(pfObject: groupMember))
                }
                successHandler(ret)
            } else {
                failureHandler?(error)
            }
            
            
        }
    }
    
}