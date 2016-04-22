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
    var pfActivity: PFObject?
    var activityId: String?
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
    var isPublic: Bool?
    
    // MARK: The activity that the current_user has joined
    static var current_activity: Activity? {
        didSet {
            User.currentUser?.setCurrentActivity(current_activity?.activityId, successHandler: {
                Log.warning("set Current Activity to User success")
                }, failureHandler: { (error: NSError?) in
                    Log.error(error?.localizedDescription)
                    
            })
        }
    }
    
    override init() {
        super.init()
        // FIXME: may be some problems with this line, owner should not be assigned in this constructor
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
    
    func setupDetail(title: String?, time: NSDate, overview: String?, isPublic: Bool) {
        self.title = title
        self.requestTime = time
        self.overview = overview
        self.isPublic = isPublic
    }
    
    func saveToBackend(successHandler: (String)->(), failureHandler: ((NSError?)->())?) {
        print("saveToBackend called")
        let PFActivity = PFObject(className: "Activity")
        
        PFActivity["title"] = title!
        if let currentUser = PFUser.currentUser() {
            PFActivity["owner"] = currentUser as PFUser
            owner = currentUser
        }
        
        PFActivity["requestTime"] = requestTime!
        
        if let yelpBusinessId = self.yelpBusinessId {
            PFActivity["yelpBusinessId"] = yelpBusinessId
        }
        
        PFActivity["overview"] = overview!
        PFActivity["pfLocation"] = PFGeoPoint(latitude: location.latitude, longitude: location.longitude)
        PFActivity["restaurant"] = restaurant!
        PFActivity["profileURL"] = profileURL?.absoluteString
        
        if let isPublic = self.isPublic {
            PFActivity["isPublic"] = isPublic
        }
        
        PFActivity.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
            if success {
                print("Step 1 success")
                self.activityId = PFActivity.objectId
                self.pfActivity = PFActivity
                var PFGroupMemberArray = [PFObject]()
                if let groupMemberList = self.group?.getUserList() {
                    print("list exists")
                    for groupMember in groupMemberList {
                        let PFGroupMember = PFObject(className: "GroupMember")
                        PFGroupMember["userId"] = groupMember.userId
                        PFGroupMember["screenName"] = groupMember.screenName
                        if let avatar = groupMember.avatar {
                            PFGroupMember["avatar"] = avatar
                        }
                        PFGroupMember["joined"] = groupMember.joined
                        if let owner = groupMember.owner {
                            PFGroupMember["owner"] = owner
                        }
                        PFGroupMember["activityId"] = self.activityId
                        
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
        self.pfActivity = PFActivity
        self.title = PFActivity["title"] as? String
        ({self.activityId = PFActivity.objectId})()
        print(activityId)
        self.owner = PFActivity["owner"] as? PFUser
        self.requestTime = PFActivity["requestTime"] as? NSDate
        self.yelpBusinessId = PFActivity["yelpBusinessId"] as? String
        self.overview = PFActivity["overview"] as? String
        if let loc = PFActivity["pfLocation"] as? PFGeoPoint {
            self.location = CLLocationCoordinate2D(latitude: loc.latitude, longitude: loc.longitude)
        }
        self.restaurant = PFActivity["restaurant"] as? String
        if let profileString = PFActivity["profileURL"] as? String {
            self.profileURL = NSURL(string: profileString)

        }
        
    }
    
    func deleteActivity(successHandler: (()->())?) {
        if let pfActivityToDelete = self.pfActivity {
            pfActivityToDelete.deleteInBackgroundWithBlock({ (success: Bool, error: NSError?) in
                successHandler?()
            })
        }
    
    }
    
    class func joinActivityById(activityId: String, successHandler: ((Activity)->())?, failureHandler: ((NSError?)->())?) {
        
        let query = PFQuery(className: "GroupMember")
        query.whereKey("userId", equalTo: PFUser.currentUser()!.objectId!)
        query.whereKey("activityId", equalTo: activityId)
        query.getFirstObjectInBackgroundWithBlock({ (groupMember: PFObject?, error: NSError?) in
            if error == nil && groupMember != nil{
                groupMember!["joined"] = true
                groupMember?.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) in
                    if success {
                        Log.info("accept (joinActivityById) SUCCESS")
                        if let userQuery = PFUser.currentUser() {
                            userQuery["currentActivity"] = activityId
                            userQuery.saveInBackground()
                            let activityQuery = PFQuery(className: "Activity")
                            activityQuery.getObjectInBackgroundWithId(activityId, block: { (pfObject: PFObject?, error: NSError?) in
                                if pfObject != nil && error == nil {
                                    let activity = Activity(PFActivity: pfObject!)
                                    
                                    successHandler?(activity)
                                } else {
                                    failureHandler?(error)
                                }
                                
                                
                            })
                            
                            
                        }
                    }
                })
                
            }
            
        })

    }
    
    func joinActivity(successHandler: (()->())?, failureHandler: ((NSError?)->())?) {
        if let activityId = self.activityId {
            let query = PFQuery(className: "GroupMember")
            query.whereKey("userId", equalTo: PFUser.currentUser()!.objectId!)
            query.whereKey("activityId", equalTo: activityId)
            query.getFirstObjectInBackgroundWithBlock({ (groupMember: PFObject?, error: NSError?) in
                if error == nil && groupMember != nil {
                    groupMember!["joined"] = true
                    groupMember?.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) in
                        if success {
                            successHandler?()
                        }
                        
                    })
                } else {
                    if let error = error {
                        // MARK: 101 = found nothing in DB
                        if error.code == 101 {
                            let PFGroupMember = PFObject(className: "GroupMember")
                            if let userId = User.currentUser?.userId {
                                PFGroupMember["userId"] = userId
                            } else {
                                Log.error("userId not found due to lack of currentUser in User class")
                                return
                            }
                            if let screenName = User.currentUser?.screenName {
                                PFGroupMember["screenName"] = screenName
                            } else {
                                Log.error("screenName not found due to lack of currentUser in User class")
                                return
                            }
                            if let avatar = User.currentUser?.avatarImagePFFile {
                                PFGroupMember["avatar"] = avatar
                            }
                            PFGroupMember["joined"] = true
                            PFGroupMember["owner"] = false
                            PFGroupMember["activityId"] = activityId
                            PFGroupMember.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) in
                                if success {
                                    successHandler?()
                                } else {
                                    failureHandler?(error)
                                    Log.error("Fail to insert group member")
                                    
                                }
                            })
                        } else {
                            failureHandler?(error)
                        }
                    } else {
                        failureHandler?(NSError(domain: "Unexpected Error", code: 4, userInfo: nil))
                    }
                    
                }
                
            })
        }
        
    }
    
    
    
    func exitActivity(successHandler: (()->())?, failureHandler: ((NSError?)->())?) {
        if let currentActivity = Activity.current_activity {
            let groupMemberQuery = PFQuery(className:  "GroupMember")
            groupMemberQuery.whereKey("userId", equalTo: User.currentUser!.userId!)
            groupMemberQuery.whereKey("activityId", equalTo: currentActivity.activityId!)
            groupMemberQuery.getFirstObjectInBackgroundWithBlock({ (groupMember: PFObject?, error: NSError?) in
                groupMember?.deleteEventually()
                successHandler?()
            })
            
        } else {
            failureHandler?(NSError(domain: "no current activity found", code: 3, userInfo: nil))
            return
        }
        


        if User.currentUser?.userId == owner.objectId {
            Log.info("I am the owner, so delete the activity object in cloud")
            deleteActivity(nil)
        }
        
        Activity.current_activity = nil

    }
    
    func fetchGroupMember (successHandler: ([GroupMember])->(), failureHandler: ((NSError?)->())?) {
        if let activityId = self.activityId {
            let groupMemberQuery = PFQuery(className: "GroupMember")
            groupMemberQuery.whereKey("activityId", equalTo: activityId)
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
            failureHandler?(NSError(domain: "activityId not found", code: 03, userInfo: nil))
        
        }


    }
    
    class func getActivityById(_activityId: String, successHandler: ((Activity)->())?, failureHandler: ((NSError?)->())?) {
        let activityQuery = PFQuery(className: "Activity")
        activityQuery.getObjectInBackgroundWithId(_activityId, block: { (pfObject: PFObject?, error: NSError?) in
            if pfObject != nil && error == nil {
                let activity = Activity(PFActivity: pfObject!)
                Activity.current_activity = activity
                successHandler?(activity)
            } else {
                failureHandler?(error)
                Log.error("failed to getActivityById \(error?.localizedDescription)")
            }
            
        })
    }
    
    class func getCurrentActivity(_activityId: String, successHandler: ((Activity)->())?, failureHandler: ((NSError?)->())?) {
        let activityQuery = PFQuery(className: "Activity")
        activityQuery.getObjectInBackgroundWithId(_activityId, block: { (pfObject: PFObject?, error: NSError?) in
            if pfObject != nil && error == nil {
                let activity = Activity(PFActivity: pfObject!)
                Activity.current_activity = activity
                successHandler?(activity)
            } else {
                if let error = error {
                    if error.code == 101 {
                        User.currentUser?.setCurrentActivity(nil, successHandler: nil, failureHandler: nil)
                    }
                }
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
