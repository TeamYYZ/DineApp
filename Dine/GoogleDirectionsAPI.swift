//
//  GoogleDirectionsAPI.swift
//  Dine
//
//  Created by you wu on 3/30/16.
//  Copyright © 2016 YYZ. All rights reserved.
//

import Foundation
import AFNetworking

class GoogleDirectionsAPI {
    static let baseURLString = "https://maps.googleapis.com/maps/api/directions/json"
    static let APIkey = "AIzaSyCB-uEIYAecXTiyLBVBI0EiNg941XV8j-U"
    
    class func direction(origin: CLLocationCoordinate2D, destination: CLLocationCoordinate2D, completion: ([Route]!, NSError!) -> Void) -> AFHTTPRequestOperation
    {
        let manager = AFHTTPRequestOperationManager()
        var params: [String: AnyObject] = ["key": APIkey]
        params["origin"] = "\(origin.latitude),\(origin.longitude)"
        params["destination"] = "\(destination.latitude),\(destination.longitude)"
        
        return manager.GET(
            baseURLString,
            parameters: params,
            success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
                let responseAsDictionary = response as! NSDictionary
                let dictionaries = responseAsDictionary["routes"] as? [NSDictionary]
                if dictionaries != nil {
                completion(Route.routes(array: dictionaries!), nil)
                }
            },
            failure: { (operation: AFHTTPRequestOperation?,
                error: NSError!) in
                print("Error: " + error.localizedDescription)
                completion(nil, error)
            }
        )!
    }
    
    class func degreesToRadians(degrees: Double) -> Double { return degrees * M_PI / 180.0 }
    class func radiansToDegrees(radians: Double) -> Double { return radians * 180.0 / M_PI }
    
    class func getBearingBetweenTwoPoints(point1 : CLLocation, point2 : CLLocation) -> Double {
        
        let lat1 = degreesToRadians(point1.coordinate.latitude)
        let lon1 = degreesToRadians(point1.coordinate.longitude)
        
        let lat2 = degreesToRadians(point2.coordinate.latitude);
        let lon2 = degreesToRadians(point2.coordinate.longitude);
        
        let dLon = lon2 - lon1;
        
        let y = sin(dLon) * cos(lat2);
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);
        let radiansBearing = atan2(y, x);
        
        return radiansToDegrees(radiansBearing)
    }
}