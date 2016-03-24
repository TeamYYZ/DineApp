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
    
    init(userList: [String]) {
        for user in userList {
            groupMembers.append(GroupMember(userId: user, joined: false))
        }
    }
    
    func addMember(userId: String, joined: Bool) {
        groupMembers.append(GroupMember(userId: userId, joined: joined))
    }

    func getUserList() -> [GroupMember]?{
        return groupMembers
    }
    
    func getUserListDictArray() -> [NSMutableDictionary]? {
        var dictArray = [NSMutableDictionary]()
        for member in groupMembers {
            let dict = NSMutableDictionary()
            dict["userId"] = member.userId
            dict["joined"] = member.joined
            dictArray.append(dict)
            
        }
        return dictArray
        
    
    }
    
}
