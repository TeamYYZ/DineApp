//
//  MapAnnotation.swift
//  Dine
//
//  Created by you wu on 3/13/16.
//  Copyright © 2016 YYZ. All rights reserved.
//

import UIKit
import MapKit

class MapAnnotation: NSObject {
    let title: String?
    var restaurantName: String?
    var members: String?
    var time: String?
    var profileURL: NSURL?
    var activity: Activity?
    
    override init() {
        title = " "
        restaurantName = "Whataburger"
        members = "Sam, Ian, Jessica, Louie"
        time = "12:30"
    }
    
    init(activity: Activity) {
        self.activity = activity
        self.title = activity.title
        self.restaurantName = activity.restaurant
        
        if let time = activity.requestTime {
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "hh:mm a"
            let dateString = dateFormatter.stringFromDate(time)
            self.time = dateString
        }
        var membersString = ""
        if let group = activity.group {
            for member in group.groupMembers {
                if member.joined {
                    membersString += member.screenName!+". "
                }
            }
        }

        self.members = membersString
        self.profileURL = activity.profileURL
    }
}
