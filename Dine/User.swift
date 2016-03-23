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
    var UID: String?
    var username: String?
    var firstName: String?
    var lastName: String?
    var password: String?
    var dateOfBirth: NSDate?
    var gender: Bool?
    var email: String?
    var profileDescription: String?
    var avatarImage: UIImage?
    var friendList: [String]?   // save user's objectID
    var current_location: CLLocation?
    
    static var currentUser: User?

    // for persistently store the current User object, generate a User object after restarting in Appdelegate
    
    init (pfUser: PFUser) {
        self.UID = pfUser.objectId
        self.username = pfUser.username
        self.password = pfUser.password
        if let lastName = pfUser["lastName"] as? String {
            self.lastName = lastName
        }
        if let firstName = pfUser["firstName"] as? String {
            self.firstName = firstName
        }
        
        
    }
    
    init(UID: String, username: String, firstName: String, lastName: String, password: String, dateOfBirth: NSDate, gender: Bool, email: String, profileDescription: String, avatarImage: UIImage, friendList: [String], current_location: CLLocation){
        self.UID = UID
        self.firstName = firstName
        self.lastName = lastName
        self.password = password
        self.dateOfBirth = dateOfBirth
        self.gender = gender
        self.profileDescription = profileDescription
        self.avatarImage = avatarImage
        self.friendList = friendList
        self.current_location = current_location
    }

}