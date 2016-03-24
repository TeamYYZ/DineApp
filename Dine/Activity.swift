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
    
    var activityId: String?
    var title: String?
    var requestPosterUsername: String?
    var requestTime: String?
    var yelpBusinessId: String?
    var overview: String?
    var group: Group?
    var chat: Chat?
    var location: CLLocationCoordinate2D?
    var restaurant: String?
    
    static var current_activity: Activity?
    //The activity that the current_user has joined
    
    override init() {
        super.init()
    }
    
    func setupRestaurant(yelpBusinessId: String, restaurant: String) {
        
    
    }
    
    func setupGroup() {
    
    
    
    }
    
    init (dictionary: PFObject) {
        self.activityId = dictionary["AID"] as? String
        self.requestPosterUsername = dictionary["request_poster_username"] as? String
        self.requestTime = dictionary["request_time"] as? String
        self.yelpBusinessId = dictionary["yelp_business_id"] as? String
        self.overview = dictionary["overview"] as? String
        self.group = dictionary["group"] as? Group
        self.location = (dictionary["location"] as? CLLocationCoordinate2D)!
        self.restaurant = dictionary["restaurant"] as? String
    }
    
    init(AID: String, request_poster_username: String, request_time: String, yelp_business_id: String, overview: String, group: Group, location: CLLocationCoordinate2D, restaurant: String){
    
        self.activityId = AID
        self.requestPosterUsername = request_poster_username
        self.requestTime = request_time
        self.yelpBusinessId = yelp_business_id
        self.overview = overview
        self.group = group
        self.location = location
        self.restaurant = restaurant
        
    }
    
    
    
    
    
    
}
