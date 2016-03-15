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
    var objectID: String?
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
    
    static var currentUser: User?
    // for persistently store the current User object, generate a User object after restarting in Appdelegate
    
    init (pfUser: PFUser) {
        self.objectID = pfUser.objectId
        self.username = pfUser.username
        self.password = pfUser.password
        if let lastName = pfUser["lastName"] as? String {
            self.lastName = lastName
        }
        if let firstName = pfUser["firstName"] as? String {
            self.firstName = firstName
        }
    }

}