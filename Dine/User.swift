//
//  User.swift
//  Dine
//
//  Created by YiHuang on 3/15/16.
//  Copyright © 2016 YYZ. All rights reserved.
//

import UIKit
import Parse

class User {
    var userId: String?
    var pfUser: PFUser?
    var username: String?
    var screenName: String?
    var password: String?
    var dateOfBirth: NSDate?
    var gender: Bool?
    var email: String?
    var profileDescription: String?
    var avatarImage: UIImage?
    var friendList: [String]?   // save users' objectID
    var current_location: CLLocation?
    var notificationsRecv: [UserNotification]?
    
    static var currentUser: User?
    
    // for persistently store the current User object, generate a User object after restarting in Appdelegate
    
    init (userId: String) {
        self.userId = userId
    }
    
    init (pfUser: PFUser) {
        self.pfUser = pfUser
        self.userId = pfUser.objectId
        self.username = pfUser.username
        self.password = pfUser.password
        if let screenName = pfUser["screenName"] as? String {
            self.screenName = screenName
        }
        self.friendList = pfUser["friendList"] as? [String]
        let notificationDictArray = pfUser["notificationsRecv"] as! [NSDictionary]
        notificationsRecv = [UserNotification]()
        for notifyication in notificationDictArray {
            notificationsRecv?.append(UserNotification(dict: notifyication))
        }
    }
    
    func getNotifications() -> [UserNotification]?{
        // FIXME: will this fetch new notifications from server? I am not sure
        if let user = pfUser {
            notificationsRecv = [UserNotification]()
            let notificationDictArray = user["notificationsRecv"] as! [NSDictionary]
            for notifyication in notificationDictArray {
                notificationsRecv?.append(UserNotification(dict: notifyication))
            }
            return notificationsRecv
        } else {
            return nil
        }
    }
    
    
    
}