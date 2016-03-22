//
//  Activity.swift
//  Dine
//
//  Created by Senyang Zhuang on 3/21/16.
//  Copyright © 2016 YYZ. All rights reserved.
//

import UIKit
import Parse

class Activity: NSObject {
    
    var AID: String?
    var request_poster_username: String?
    var request_time: NSDate?
    var yelp_business_id: String?
    var overview: String?
    var GID: String?
    
    static var current_activity: Activity?
    //The activity that the current_user has joined
    
    init (dictionary: NSDictionary) {
        self.AID = dictionary["AID"] as? String
        self.request_poster_username = dictionary["request_poster_username"] as? String
        self.request_time = dictionary["request_time"] as? NSDate
        self.yelp_business_id = dictionary["yelp_business_id"] as? String
        self.overview = dictionary["overview"] as? String
        self.GID = dictionary["GID"] as? String
    }
    
    
    
    
    
    
}
