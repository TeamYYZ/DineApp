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
    var avatarImagePFFile: PFFile?
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
        self.avatarImagePFFile = pfUser["avatar"] as? PFFile
        if let screenName = pfUser["screenName"] as? String {
            self.screenName = screenName
        }
        self.friendList = pfUser["friendList"] as? [String]
        notificationsRecv = [UserNotification]()
        if let notificationDictArray = pfUser["notificationsRecv"] as? [NSDictionary] {
            for notification in notificationDictArray {
                notificationsRecv?.append(UserNotification(dict: notification))
            }
        }

    }
    
    func getNotifications(successHandler: ([UserNotification]?)->()) {
        let userQuery = PFUser.query()
        userQuery?.getObjectInBackgroundWithId(userId!, block: { (user: PFObject?, error: NSError?) -> Void in
            if error == nil && user != nil{
                self.notificationsRecv = [UserNotification]()
                let notificationDictArray = user!["notificationsRecv"] as? [NSDictionary]
                if let dictArray = notificationDictArray {
                    for notification in dictArray {
                        self.notificationsRecv?.append(UserNotification(dict: notification))
                    }
                    successHandler(self.notificationsRecv)
                }

                
            }

        })
    }
    
    func getFriendsList(successHandler: ([String]?)->()) {
        let userQuery = PFUser.query()
        userQuery?.getObjectInBackgroundWithId(userId!, block: { (user: PFObject?, error: NSError?) -> Void in
            if error == nil && user != nil{
                self.friendList = [String]()
                let notificationArray = user!["friendList"] as? [String]
                if let friendArray = notificationArray {
                    self.friendList = friendArray
                    successHandler(self.friendList)
                }
                
                
            }
            
        })
    }
    
    func save(){
        let userQuery = PFUser.query()
        userQuery?.getObjectInBackgroundWithId(userId!, block: { (pfUser: PFObject?, error: NSError?) in
            if pfUser != nil && error == nil{
                print(pfUser)
                pfUser?.saveInBackground()
            }
        })
    }
    
    
    
}