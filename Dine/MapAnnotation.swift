//
//  MapAnnotation.swift
//  Dine
//
//  Created by you wu on 3/13/16.
//  Copyright © 2016 YYZ. All rights reserved.
//

import UIKit
import MapKit

class MapAnnotation: NSObject, MKAnnotation {
    let title: String?
    let coordinate: CLLocationCoordinate2D
    var restaurantName: String?
    var members: String?
    var time: String?
    var activity: Activity?
    
    override init() {
        title = " "
        coordinate = CLLocationCoordinate2D(latitude: 30.601433, longitude: -96.314464)
        restaurantName = "Whataburger"
        members = "Sam, Ian, Jessica, Louie"
        time = "12:30"
    }
    
     init(dictionary: NSDictionary) {
        self.title = dictionary["title"] as? String
        self.coordinate = (dictionary["coordinate"] as? CLLocationCoordinate2D)!
        self.restaurantName = dictionary["restaurantName"] as? String
        self.members = dictionary["members"] as? String
        self.time = dictionary["time"] as? String
    }
    
    init(activity: Activity) {
        self.activity = activity
        self.title = " "
        self.coordinate = activity.location!
        self.restaurantName = activity.restaurant
        self.members = activity.requestPosterUsername
        self.time = activity.requestTime
    }
}
