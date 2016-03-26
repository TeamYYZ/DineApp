//
//  Notification.swift
//  Dine
//
//  Created by YiHuang on 3/24/16.
//  Copyright © 2016 YYZ. All rights reserved.
//

import Foundation
import Parse

enum NotificationType {
    case FriendRequest, Invitation, PrivateMessage
    
}

class UserNotification {
    var type: NotificationType
    var associatedId: String?
    var content: String
    var senderId: String
    var receiverId: String
    var senderName: String
    var senderAvatarPFFile: PFFile?
    
    // create from send notifications
    init(type: NotificationType, content: String, senderId: String, receiverId: String, associatedId: String?, senderName: String, senderAvatarPFFile: PFFile?) {
        self.type = type
        self.content = content
        self.senderId = senderId
        self.receiverId = receiverId
        if self.type == .Invitation {
            self.associatedId = associatedId
        }
        self.senderName = senderName
        self.senderAvatarPFFile = senderAvatarPFFile
    }
    
    // create from Parse
    init(dict: NSDictionary) {
        self.type = dict["type"] as! NotificationType
        self.content = dict["content"] as! String
        self.senderId = dict["senderId"] as! String
        self.receiverId = dict["receiverId"] as! String
        self.associatedId = dict["associatedId"] as? String
        self.senderName = dict["senderName"] as! String
        self.senderAvatarPFFile = dict["senderAvatar"] as? PFFile
    }
    
}