//
//  MemberAnnotation.swift
//  Dine
//
//  Created by you wu on 4/30/16.
//  Copyright © 2016 YYZ. All rights reserved.
//

import UIKit
import MapKit

class MemberAnnotation: NSObject, MKAnnotation {
    var coordinate = CLLocationCoordinate2D()
    var icon: UIImage?
    
    init(member: GroupMember) {
        if let loc = member.location {
        let circleCenter = CLLocationCoordinate2D(latitude: loc.latitude, longitude: loc.longitude)
        self.coordinate = circleCenter
        }
        
    }
}
