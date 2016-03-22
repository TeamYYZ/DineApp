//
//  Chat.swift
//  Dine
//
//  Created by Senyang Zhuang on 3/21/16.
//  Copyright © 2016 YYZ. All rights reserved.
//

import UIKit

class Chat: NSObject {
   
    var CID: String?
    var times: [NSDate]?
    var messages: [String]?
    
    init(dictionary: NSDictionary){
        
        self.CID = dictionary["CID"] as? String
        self.times = dictionary["times"] as? [NSDate]
        self.messages = dictionary["messages"] as? [String]

    }
    
}
