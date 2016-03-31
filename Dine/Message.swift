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
    var messageId: String?
    var senderId: String?
    var screenName: String?
    var senderAvatarPFFile: PFFile?
    var content: String?
    var createdAt: NSDate?
    
    init(dictionary: NSDictionary) {
        self.messageId = dictionary["messageId"] as! String
        self.senderId = dictionary["senderId"] as! String
        self.screenName = dictionary["screenName"] as! String
        self.senderAvatarPFFile = dictionary["senderAvatarPFFile"] as! PFFile
        self.content = dictionary["content"] as? String
        self.createdAt = dictionary["createdAt"] as? NSDate
    }
    
    init(senderId: String, screenName: String, content: String){
        self.content = content
        self.screenName = screenName
        if let senderAvatarPFFile = senderAvatarPFFile{
            self.senderAvatarPFFile = senderAvatarPFFile
        }
        self.senderId = senderId

    }
    
    init(senderId: String, screenName: String,content: String, createdAt: NSDate){
        self.content = content
        self.screenName = screenName
//        self.senderAvatarPFFile = senderAvatarPFFile
        self.senderId = senderId
        self.createdAt = createdAt
    }
    
}
