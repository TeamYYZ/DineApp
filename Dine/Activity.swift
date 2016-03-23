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
    var request_time: String?
    var yelp_business_id: String?
    var overview: String?
    var group: Group?
    var location: CLLocationCoordinate2D
    var restaurant: String?
    
    static var current_activity: Activity?
    //The activity that the current_user has joined
    
    init (dictionary: NSDictionary) {
        self.AID = dictionary["AID"] as? String
        self.request_poster_username = dictionary["request_poster_username"] as? String
        self.request_time = dictionary["request_time"] as? String
        self.yelp_business_id = dictionary["yelp_business_id"] as? String
        self.overview = dictionary["overview"] as? String
        self.group = dictionary["group"] as? Group
        self.location = (dictionary["location"] as? CLLocationCoordinate2D)!
        self.restaurant = dictionary["restaurant"] as? String
    }
    
    init(AID: String, request_poster_username: String, request_time: String, yelp_business_id: String, overview: String, group: Group, location: CLLocationCoordinate2D, restaurant: String){
    
        self.AID = AID
        self.request_poster_username = request_poster_username
        self.request_time = request_time
        self.yelp_business_id = yelp_business_id
        self.overview = overview
        self.group = group
        self.location = location
        self.restaurant = restaurant
        
    }
    
    
    
    
    
    
}
