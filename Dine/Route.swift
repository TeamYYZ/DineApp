//
//  Route.swift
//  Dine
//
//  Created by you wu on 3/30/16.
//  Copyright © 2016 YYZ. All rights reserved.
//

import UIKit

class Route: NSObject {
    struct Step {
        var distance: String?
        var duration: String?
        var startLoc: CLLocationCoordinate2D?
        var endLoc: CLLocationCoordinate2D?
        var polyLine: String?
        var instruction: String?
        var maneuver: String?
        
        init(dictionary:NSDictionary) {
            distance = dictionary["distance"]?["text"] as? String
            duration = dictionary["duration"]?["text"] as? String
            if let lat = dictionary["end_location"]?["lat"] as? CLLocationDegrees {
                if let lng = dictionary["end_location"]?["lng"] as? CLLocationDegrees {
                    endLoc = CLLocationCoordinate2D(latitude: lat, longitude: lng)
                }
            }
            
            if let lat = dictionary["start_location"]?["lat"] as? CLLocationDegrees {
                if let lng = dictionary["start_location"]?["lng"] as? CLLocationDegrees {
                    startLoc = CLLocationCoordinate2D(latitude: lat, longitude: lng)
                }
            }
            
            instruction = dictionary["html_instructions"] as? String
            polyLine = dictionary["polyline"] as? String
            maneuver = dictionary["maneuver"] as? String
        }
    }
    var steps = [Step]()
    
    init(dictionary: NSDictionary) {
        if let legs = dictionary["legs"] as? [NSDictionary] {
            if let stepsDic = legs[0]["steps"] as? [NSDictionary] {
                for step in stepsDic {
                    steps.append(Step(dictionary: step))
                }
            }
        }
    }
    
    class func routes(array array: [NSDictionary]) -> [Route] {
        var routes = [Route]()
        for dictionary in array {
            let route = Route(dictionary: dictionary)
            routes.append(route)
        }
        return routes
    }
}
