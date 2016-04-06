//
//  Group.swift
//  Dine
//
//  Created by Senyang Zhuang on 3/21/16.
//  Copyright © 2016 YYZ. All rights reserved.
//

import UIKit
import Parse

class Group: NSObject {
    
    var groupMembers = [GroupMember]()
    
    init(membersDictArray: [NSMutableDictionary]) {
        for dict in membersDictArray {
            let member = GroupMember(userId: dict["userId"] as! String, joined: dict["joined"] as! Bool)
            groupMembers.append(member)
        }
        
    }
    
    init(userList: [GroupMember]) {
        for user in userList {
            groupMembers.append(user)
        }
    }

    func addOwner(owner: GroupMember) {
        owner.owner = true
        owner.joined = true
        groupMembers.insert(owner, atIndex: 0)
    }
    
    func addMember(groupMember: GroupMember) {
        groupMembers.append(groupMember)
    }
    
    func addMember(userId: String, joined: Bool) {
        groupMembers.append(GroupMember(userId: userId, joined: joined))
    }
    
    func getUserIdList() -> [String] {
        var members = [String]()
        for member in groupMembers {
            members.append(member.userId)
        }
        return members
    
    }

    func getUserList() -> [GroupMember]?{
        return groupMembers
    }
    
    func getUserListDictArray() -> [NSMutableDictionary]? {
        var dictArray = [NSMutableDictionary]()
        for member in groupMembers {
            let dict = NSMutableDictionary()
            dict["userId"] = member.userId
            dict["screenName"] = member.screenName
            dict["avatar"] = member.avatar
            dict["joined"] = member.joined
            dict["owner"] = member.owner
            dictArray.append(dict)
            
        }
        return dictArray
        
    
    }
    
}
