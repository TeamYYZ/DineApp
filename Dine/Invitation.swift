//
//  Invitation.swift
//  Dine
//
//  Created by Senyang Zhuang on 3/21/16.
//  Copyright © 2016 YYZ. All rights reserved.
//

import UIKit
import Parse

class Invitation: NSObject {
    
    var sender_id: String?
    var receivers_id: [String]?
    var AID: String?
    
    init(object: PFObject){
        self.sender_id = object["sender"] as?  String
        self.receivers_id = object["receivers_id"] as? [String]
        self.AID = object["AID"] as? String
    
    }
    

}
