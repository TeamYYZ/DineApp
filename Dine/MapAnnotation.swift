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
    var requestTime: NSDate?
    var activity: Activity?
    
    override init() {
        title = " "
        restaurantName = "Whataburger"
        members = "Sam, Ian, Jessica, Louie"
        time = "12:30"
    }
    
     init(dictionary: NSDictionary) {
        self.title = dictionary["title"] as? String
        self.restaurantName = dictionary["restaurantName"] as? String
        self.members = dictionary["members"] as? String
        self.time = dictionary["time"] as? String
    }
    
    init(activity: Activity) {
        self.activity = activity
        self.title = activity.title
        self.restaurantName = activity.restaurant
        self.members = activity.ownerId
        self.requestTime = activity.requestTime
    }
}
