//
//  Invitation.swift
//  Dine
//
//  Created by Senyang Zhuang on 3/21/16.
//  Copyright © 2016 YYZ. All rights reserved.
//

import UIKit

class Invitation: NSObject {
    
    var IID: String?
    var sender_id: String?
    var receivers_id: [String]?
    var AID: String?
    
    init(dictionary: NSDictionary){
        self.IID = dictionary["IID"] as? String
        self.sender_id = dictionary["sender"] as?  String
        self.receivers_id = dictionary["receivers_id"] as? [String]
        self.AID = dictionary["AID"] as? String
    
    }
    

}
