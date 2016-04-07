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
        
        if let description = pfUser["description"] as? String{
            self.profileDescription = description
        
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
    
    func updateScreenName(screenName: String?, withCompletion completion: PFBooleanResultBlock?) {
        // Create Parse object PFObject
        if let name = screenName {
            if let user = pfUser {
                // Add relevant fields to the object
                user["screenName"] = name // PFFile column type
                user.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) in
                    if success == true && error == nil{
                        User.currentUser?.screenName = name
                        completion?(success, error)
                        //print("EEEEE")
                    }else{
                        print(error)
                    }
                })
                
            }
        }
        
    }
    
    func updateUsername(username: String?, withCompletion completion: PFBooleanResultBlock?) {
        // Create Parse object PFObject
        if let name = username{
            if let user = pfUser {
                // Add relevant fields to the object
                user["username"] = name // PFFile column type
                user.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) in
                    if success == true && error == nil{
                        User.currentUser?.username = name
                        completion?(success, error)
                        //print("EEEEE")
                    }else{
                        print(error)
                    }
                })
                
            }
        
        }
    }
    
    func updateDescription(description: String?, withCompletion completion: PFBooleanResultBlock?) {
        // Create Parse object PFObject
        if let text = description{
            if let user = pfUser {
                // Add relevant fields to the object
                user["description"] = text // PFFile column type
                user.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) in
                    if success == true && error == nil{
                        User.currentUser?.profileDescription = text
                        completion?(success, error)
                        //print("EEEEE")
                    }else{
                        print(error)
                    }
                })
                
            }
            
        }
    }
    
    


    
    func updateProfilePhoto(image: UIImage?, withCompletion completion: PFBooleanResultBlock?) {
        // Create Parse object PFObject
        if let image = image {
            if let user = pfUser {
                // Add relevant fields to the object
               user["avatar"] = self.getPFFileFromImage(image) // PFFile column type
                user.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) in
                    if success == true && error == nil{
                        User.currentUser?.avatarImage = image
                        completion?(success, error)
                    }else{
                        print(error)
                    }
               })

            }
        }
        
    }
    

    func getPFFileFromImage(image: UIImage?) -> PFFile? {
        // check if image is not nil
        if let image = image {
            // get image data and check if that is not nil
            if let imageData = UIImagePNGRepresentation(image) {
                return PFFile(name: "image.png", data: imageData)
            }
        }
        return nil
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