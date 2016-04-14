//
//  YelpClient.swift
//  Yelp
//
//  Created by Timothy Lee on 9/19/14.
//  Copyright (c) 2014 Timothy Lee. All rights reserved.
//

import UIKit

import AFNetworking
import BDBOAuth1Manager

// You can register for Yelp API keys here: http://www.yelp.com/developers/manage_api_keys
let yelpConsumerKey = "e_gFY6uWrUNwwkNlu2WIAw"
let yelpConsumerSecret = "_k3zLmus4L1NCFvG2qeI5fC1sxU"
let yelpToken = "uLDe1N0yRUiU7onjWZ7AdlECZU_3Wdc1"
let yelpTokenSecret = "IT09I2AcHaol2kwlANXfq-kyFsU"

enum YelpSortMode: Int {
    case BestMatched = 0, Distance, HighestRated
}

class YelpClient: BDBOAuth1RequestOperationManager {
    var accessToken: String!
    var accessSecret: String!
    
    class var sharedInstance : YelpClient {
        struct Static {
            static var token : dispatch_once_t = 0
            static var instance : YelpClient? = nil
        }
        
        dispatch_once(&Static.token) {
            Static.instance = YelpClient(consumerKey: yelpConsumerKey, consumerSecret: yelpConsumerSecret, accessToken: yelpToken, accessSecret: yelpTokenSecret)
        }
        return Static.instance!
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(consumerKey key: String!, consumerSecret secret: String!, accessToken: String!, accessSecret: String!) {
        self.accessToken = accessToken
        self.accessSecret = accessSecret
        let baseUrl = NSURL(string: "https://api.yelp.com/v2/")
        super.init(baseURL: baseUrl, consumerKey: key, consumerSecret: secret);
        
        let token = BDBOAuth1Credential(token: accessToken, secret: accessSecret, expiration: nil)
        self.requestSerializer.saveAccessToken(token)
    }
    
    func searchWithTerm(term: String, location: CLLocationCoordinate2D, completion: ([Business]!, NSError!) -> Void) -> AFHTTPRequestOperation {
        return searchWithTerm(term, location: location, sort: nil, radius: 0, categories: nil, deals: nil, offset: nil, completion: completion)
    }
    
    func getBusinessWithId(id: String, completion: (business: Business!, NSError!) -> Void) -> AFHTTPRequestOperation? {
        if let escapedId = id.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet()) {
            print(escapedId)
            let parameters: [String : AnyObject] = ["actionlinks": false]
            return self.GET("business/" + escapedId, parameters: parameters, success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
                let dictionary = response as? NSDictionary
                if dictionary != nil {
                    completion(business: Business(dictionary: dictionary!), nil)
                }
                }, failure: { (operation: AFHTTPRequestOperation?, error: NSError!) -> Void in
                    completion(business: nil, error)
            })!  
        
        } else {
            return nil
        }


    }
    
    
    func searchWithTerm(term: String, location: CLLocationCoordinate2D, sort: Int?, radius: Int, categories: [String]?, deals: Bool?, offset: Int?, completion: ([Business]!, NSError!) -> Void) -> AFHTTPRequestOperation {
        // For additional parameters, see http://www.yelp.com/developers/documentation/v2/search_api

        // Default the location to College Station
        var parameters: [String : AnyObject] = ["term": term, "ll": String(location.latitude)+","+String(location.longitude)]

        if sort != nil {
            parameters["sort"] = sort
        }
        if radius != 0 {
            parameters["radius_filter"] = radius
        }
        
        if categories != nil && categories!.count > 0 {
            parameters["category_filter"] = (categories!).joinWithSeparator(",")
        }
        
        if deals != nil {
            parameters["deals_filter"] = deals!
        }
        
        if offset != nil {
            parameters["offset"] = offset!
        }
        
        return self.GET("search", parameters: parameters, success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
            let responseAsDictionary = response as! NSDictionary
            let dictionaries = responseAsDictionary["businesses"] as? [NSDictionary]
            if dictionaries != nil {
                completion(Business.businesses(array: dictionaries!), nil)
            }
            }, failure: { (operation: AFHTTPRequestOperation?, error: NSError!) -> Void in
                completion(nil, error)
        })!
    }
}
