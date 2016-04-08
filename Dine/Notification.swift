//
//  Notification.swift
//  Dine
//
//  Created by YiHuang on 3/24/16.
//  Copyright © 2016 YYZ. All rights reserved.
//

import Foundation
import Parse

enum NotificationType: String {
    case FriendRequest = "FriendRequest"
    case Invitation = "Invitation"
    case PrivateMessage = "PrivateMessage"
    case Unknown = "Unknown"
    
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
        let notificationType = dict["type"] as! String
        switch notificationType {
        case "Invitation":
            self.type = .Invitation
        case "FriendRequest":
            self.type = .FriendRequest
        case "PrivateMessage":
            self.type = .PrivateMessage
        default:
            self.type = .Unknown
        }
        
        self.content = dict["content"] as! String
        self.senderId = dict["senderId"] as! String
        self.receiverId = dict["receiverId"] as! String
        self.associatedId = dict["associatedId"] as? String
        self.senderName = dict["senderName"] as! String
        self.senderAvatarPFFile = dict["senderAvatar"] as? PFFile
    }
    
    func getDict() -> NSMutableDictionary {
        let dict = NSMutableDictionary()
        dict["type"] = self.type.rawValue
        dict["content"] = self.content
        dict["senderId"] = self.senderId
        dict["receiverId"] = self.receiverId
        dict["associatedId"] = self.associatedId
        dict["senderName"] = self.senderName
        dict["senderAvatar"] = self.senderAvatarPFFile
        return dict
    }
    
    
    func saveToBackend(successHandler: ()->(), failureHandler: (NSError?)->()) {
        PFCloud.callFunctionInBackground("addNotification", withParameters: ["notification": self.getDict()]) {
            (response: AnyObject?, error: NSError?) -> Void in
            if error == nil {
                print("Notification sent")
                successHandler()
            } else {
                print(error!)
            }

        }
        
    }
    
    class func broadcastInBackend(notificationList: [NSDictionary], successHandler: ()->(), failureHandler: (NSError?)->()) {
        PFCloud.callFunctionInBackground("broadcastNotifications", withParameters: ["notificationList": notificationList]) {
            (response: AnyObject?, error: NSError?) -> Void in
            if error == nil {
                print("Notification sent")
                successHandler()
            } else {
                print(error!)
            }
            
        }

    }
    
    func acceptRequest() {
        switch self.type {
        case .FriendRequest:
            PFCloud.callFunctionInBackground("acceptFriendRequest", withParameters: ["fromUser": self.senderId, "notification": self.getDict()]) {
            (response: AnyObject?, error: NSError?) -> Void in
                if error == nil {
                    let success = response as! Bool
                    if success {
                        print("accept SUCCESS")
                    }
                } else {
                    print(error!.localizedDescription)
                }
            }
        case .Invitation:
            if let activityId = associatedId {
                let query = PFQuery(className: "GroupMember_" + activityId)
                query.whereKey("userId", equalTo: PFUser.currentUser()!.objectId!)
                query.getFirstObjectInBackgroundWithBlock({ (groupMember: PFObject?, error: NSError?) in
                    if error == nil && groupMember != nil{
                        groupMember!["joined"] = true
                        groupMember?.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) in
                            if success {
                                print("accept SUCCESS")
                            }
                        })
                        
                    }
                    
                })
            
            }

        default:
            print("Undefined notification type")
        
        }
    }
    
    func delete() {
        
        if self.type == .Unknown {
            return
        }
        
        let userQuery = PFUser.query()
        userQuery?.getObjectInBackgroundWithId(self.receiverId, block: { (pfObject: PFObject?, error: NSError?) -> Void in
            if error == nil {
                if let user = pfObject {
                    user.removeObject(self.getDict(), forKey: "notificationsRecv")
                    user.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
                        if success {
                            print("Notification Deleted")
                        }
                    })
                    
                }
                
            }
        })
    }
}