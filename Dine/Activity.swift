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
    var owner: PFUser!
    var requestTime: NSDate!
    var yelpBusinessId: String?
    var profileURL: NSURL?
    var overview: String?
    var group: Group?
    //var groupMessages: [String]?
    var location: CLLocationCoordinate2D!
    var restaurant: String?
    var chatTableId : String?
    
    static var current_activity: Activity?
    //The activity that the current_user has joined
    
    override init() {
        super.init()
        self.owner = PFUser.currentUser()
    }
    
    func setupRestaurant(yelpBusiness: Business) {
        
        self.restaurant = yelpBusiness.name
        self.yelpBusinessId = yelpBusiness.businessID
        self.profileURL = yelpBusiness.imageURL
        //location is the same as yelp business coordinate
        self.location = yelpBusiness.coordinate
        print("set up restaurant: " + self.restaurant!)
    }
    
    func setupGroup(userList: [String]) {
        let group = Group(userList: userList)
        group.addMember(owner.objectId!, joined: true)
        self.group = group
    }
    
    func setupDetail(title: String?, time: NSDate, overview: String?) {
        self.title = title
        self.requestTime = time
        self.overview = overview
        print("set up detail: " + self.title!)
        print(time)
        print(overview)

    }
    
    func saveToBackend(successHandler: ()->(), failureHandler: ()->()) {
        let PFActivity = PFObject(className: "Activity")
        
        PFActivity["title"] = title!
        PFActivity["owner"] = owner!
        PFActivity["requestTime"] = requestTime!
        PFActivity["yelpBusinessId"] = yelpBusinessId!
        PFActivity["overview"] = overview!
        PFActivity["groupMembers"] = group!.getUserListDictArray()
        PFActivity["location"] = [location.latitude, location.longitude]
        PFActivity["restaurant"] = restaurant!
        PFActivity["profileURL"] = profileURL?.absoluteString

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
        self.owner = PFActivity["owner"] as? PFUser
        self.requestTime = PFActivity["requestTime"] as? NSDate
        self.yelpBusinessId = PFActivity["yelpBusinessId"] as? String
        self.overview = PFActivity["overview"] as? String
        if let groupDictArray = PFActivity["groupMembers"] as? [NSMutableDictionary] {
            self.group = Group(membersDictArray: groupDictArray)
        }
        if let loc = PFActivity["location"] as? [CLLocationDegrees] {
            self.location = CLLocationCoordinate2D(latitude: loc[0], longitude: loc[1])
        }
        self.restaurant = PFActivity["restaurant"] as? String
        if let profileString = PFActivity["profileURL"] as? String {
            self.profileURL = NSURL(string: profileString)

        }
    }
    
    class func activitiesWithArray(array: [PFObject]) -> [Activity] {
        var activites = [Activity]()
        
        for object in array {
            activites.append(Activity(PFActivity: object))
        }
        return activites
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
