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
}