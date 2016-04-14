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
    
    var activityId: String? {
        didSet {
            groupChatId = "ActivityChat_" + activityId!
            groupMemberId = "GroupMember_" + activityId!
        }
    }
    var title: String?
    var isPrivate: Bool?
    var owner: PFUser!
    var requestTime: NSDate!
    var yelpBusinessId: String?
    var profileURL: NSURL?
    var overview: String?
    var group: Group?
    var location: CLLocationCoordinate2D!
    var restaurant: String?
    var uniqueId: String?
    var groupChatId : String?
    var groupMemberId: String?
    
    static var current_activity: Activity? {
        didSet {
            if current_activity != nil {
                User.currentUser?.setCurrentActivity(current_activity?.activityId, successHandler: {
                    Log.warning("set Current Activity to User success")
                    }, failureHandler: { (error: NSError?) in
                        Log.error(error?.localizedDescription)
                        
                })
            }
        }
    }
    //The activity that the current_user has joined
    
    override init() {
        super.init()
        // FIXME: may be some problems with this line, owner should not be assigned in this constructor
        owner = PFUser.currentUser()
    }
    
    func setupRestaurant(yelpBusiness: Business) {
        
        self.restaurant = yelpBusiness.name
        self.yelpBusinessId = yelpBusiness.businessID
        self.profileURL = yelpBusiness.imageURL
        //location is the same as yelp business coordinate
        self.location = yelpBusiness.coordinate
        print("set up restaurant: " + self.restaurant!)
    }
    
    func setupGroup(userList: [GroupMember]) {
        let group = Group(userList: userList)
        let owner = GroupMember(user: User.currentUser!)
        group.addOwner(owner)
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
    
    func saveToBackend(successHandler: (String)->(), failureHandler: ((NSError?)->())?) {
        print("saveToBackend called")
        let PFActivity = PFObject(className: "Activity")
        
        PFActivity["title"] = title!
        PFActivity["owner"] = owner!
        PFActivity["requestTime"] = requestTime!
        PFActivity["yelpBusinessId"] = yelpBusinessId!
        PFActivity["overview"] = overview!
        PFActivity["location"] = [location.latitude, location.longitude]
        PFActivity["restaurant"] = restaurant!
        PFActivity["profileURL"] = profileURL?.absoluteString

        PFActivity.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
            if success {
                print("Step 1 success")
                self.activityId = PFActivity.objectId
                var PFGroupMemberArray = [PFObject]()
                if let groupMemberList = self.group?.getUserList() {
                    print("list exists")
                    for groupMember in groupMemberList {
                        let PFGroupMember = PFObject(className: self.groupMemberId!)
                        PFGroupMember["userId"] = groupMember.userId
                        PFGroupMember["screenName"] = groupMember.screenName
                        if let avatar = groupMember.avatar {
                            PFGroupMember["avatar"] = avatar
                        }
                        PFGroupMember["joined"] = groupMember.joined
                        if let owner = groupMember.owner {
                            PFGroupMember["owner"] = owner
                        }
                        PFGroupMemberArray.append(PFGroupMember)
                    }
                    print("Generate Member Array")
                    print(PFGroupMemberArray.count)
                    
                    PFObject.saveAllInBackground(PFGroupMemberArray, block: { (success: Bool, error: NSError?) in
                        if success {
                            print("Saving objects in GM Doc successfully!")
                            successHandler(PFActivity.objectId!)
                        } else {
                            failureHandler?(error)
                        }
                    })

                }
                
                
            } else {
                failureHandler?(error)
            }
        }
    
    
    }
    
    
    init (PFActivity: PFObject) {
        super.init()
        self.title = PFActivity["title"] as? String
        ({self.activityId = PFActivity.objectId})()
        print(activityId)
        self.owner = PFActivity["owner"] as? PFUser
        self.requestTime = PFActivity["requestTime"] as? NSDate
        self.yelpBusinessId = PFActivity["yelpBusinessId"] as? String
        self.overview = PFActivity["overview"] as? String
        if let loc = PFActivity["location"] as? [CLLocationDegrees] {
            self.location = CLLocationCoordinate2D(latitude: loc[0], longitude: loc[1])
        }
        self.restaurant = PFActivity["restaurant"] as? String
        if let profileString = PFActivity["profileURL"] as? String {
            self.profileURL = NSURL(string: profileString)

        }
        
    }
    
    func exitActivity(successHandler: (()->())?, failureHandler: ((NSError?)->())?) {
        User.currentUser?.setCurrentActivity(nil, successHandler: successHandler, failureHandler: failureHandler)
    }
    
    func fetchGroupMember (successHandler: ([GroupMember])->(), failureHandler: ((NSError?)->())?) {
        if let groupMemberId = self.groupMemberId {
            let groupMemberQuery = PFQuery(className: groupMemberId)
            groupMemberQuery.findObjectsInBackgroundWithBlock { (groupMembersList: [PFObject]?, error: NSError?) in
                if error == nil && groupMembersList != nil {
                    var ret = [GroupMember]()
                    for groupMember in groupMembersList! {
                        ret.append(GroupMember(pfObject: groupMember))
                    }
                    self.group = Group(userList: ret)
                    successHandler(ret)
                } else {
                    failureHandler?(error)
                }
                
                
            }
        } else {
            failureHandler?(NSError(domain: "groupMemberId not set", code: 1, userInfo: nil))
            print(self.groupMemberId)
        }

    }
    
    class func getCurrentActivity(_activityId: String, successHandler: ((Activity)->())?, failureHandler: ((NSError?)->())?) {
        let activityQuery = PFQuery(className: "Activity")
        activityQuery.getObjectInBackgroundWithId(_activityId, block: { (pfObject: PFObject?, error: NSError?) in
            if pfObject != nil && error == nil {
                let activity = Activity(PFActivity: pfObject!)
                Activity.current_activity = activity
                successHandler?(activity)
            } else {
                failureHandler?(error)
            }
            
        })
    
    }
    
    class func activitiesWithArray(array: [PFObject]) -> [Activity] {
        var activites = [Activity]()
        
        for object in array {
            activites.append(Activity(PFActivity: object))
        }
        return activites
    }
    
}
