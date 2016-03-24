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
    var isPrivate: Bool?
    var ownerId: String?
    var requestTime: NSDate?
    var yelpBusinessId: String?
    var overview: String?
//    var yelpBusiness: YelpBusiness?
    var group: Group?
    var groupMessages: [Message]?
    var location: CLLocationCoordinate2D?
    var restaurant: String?
    
    static var current_activity: Activity?
    //The activity that the current_user has joined
    
    override init() {
        super.init()
        self.ownerId = PFUser.currentUser()?.objectId
    }
    
    func setupRestaurant(yelpBusinessId: String, restaurant: String /*, yelpBusiness: YelpBusiness*/) {
        self.yelpBusinessId = yelpBusinessId
        self.restaurant = restaurant
//        self.yelpBusinessId = yelpBusiness
        
    
    }
    
    func setupGroup(userList: [String]) {
        let group = Group(userList: userList)
        group.addMember(ownerId!, joined: true)
        self.group = group
    }
    
    func saveToBackend(successHandler: ()->(), failureHandler: ()->()) {
        let PFActivity = PFObject(className: "Activity")
        
        PFActivity["title"] = title
        PFActivity["ownerId"] = ownerId
        PFActivity["requestTime"] = requestTime
        PFActivity["yelpBusinessId"] = yelpBusinessId
        PFActivity["overview"] = overview
        PFActivity["groupMembers"] = group?.getUserListDictArray()
        PFActivity["location"] = [location!.latitude, location!.longitude]
        PFActivity["restaurant"] = restaurant
        
        PFActivity.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
            if success {
                successHandler()
            } else {
                failureHandler()
            }
        }
    
    
    }
    
    init (PFActivity: PFObject) {
        self.title = PFActivity["title"] as? String
        self.activityId = PFActivity.objectId
        self.ownerId = PFActivity["ownerId"] as? String
        self.requestTime = PFActivity["requestTime"] as? NSDate
        self.yelpBusinessId = PFActivity["yelpBusinessId"] as? String
        self.overview = PFActivity["overview"] as? String
        let groupDictArray = PFActivity["group"] as! [NSMutableDictionary]
        self.group = Group(membersDictArray: groupDictArray)
        self.location = (PFActivity["location"] as? CLLocationCoordinate2D)!
        self.restaurant = PFActivity["restaurant"] as? String
    }
    
    
    /*
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
    */
    
    
    
    
    
}
