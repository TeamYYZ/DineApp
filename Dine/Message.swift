//
//  GroupChatMessage.swift
//  Dine
//
//  Created by YiHuang on 3/23/16.
//  Copyright © 2016 YYZ. All rights reserved.
//

import Foundation
import Parse

class Message {
    var sender: User?
    var content: String?
    var createdAt: NSDate?
    
    init(dictionary: NSDictionary) {
        let senderId = dictionary["sender"] as! String
        self.sender = User(userId: senderId)
        self.content = dictionary["content"] as! String
        self.createdAt = dictionary["createdAt"] as! NSDate
    }
    
    
}
