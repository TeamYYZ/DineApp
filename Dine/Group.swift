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
    
    var GID: String?
    var owner_uid: String?
    var group_members: [String]?
    var chat_id: String?
    
    init(dictionary: NSDictionary){
        self.GID = dictionary["GID"] as? String
        self.owner_uid = dictionary["owner_uid"] as? String
        self.group_members = dictionary["group_members"] as? [String]
        self.chat_id = dictionary["chatroom_id"] as? String
    }
    
    
}
