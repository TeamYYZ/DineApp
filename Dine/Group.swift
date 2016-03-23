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
    
    var group_members: [String]?
    var chat_id: String?
    
    static var current_group: Group?
    
    init(object: PFObject){
        self.group_members = object["group_members"] as? [String]
        self.chat_id = object["chatroom_id"] as? String
    }
    
    init(owner_uid: String, group_members: [String], chat_id: String){
        self.group_members = group_members
        self.chat_id = chat_id

    }
    
    
}
