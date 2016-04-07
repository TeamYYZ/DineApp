//
//  Business.swift
//  Yelp
//
//  Created by Timothy Lee on 4/23/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit
import MapKit

class Business: NSObject {
    let businessID: String?
    let name: String?
    let address: String?
    let imageURL: NSURL?
    let categories: String?
    let distance: String?
    let ratingImageURL: NSURL?
    let reviewCount: NSNumber?
    let reviews: [NSDictionary]?
    let coordinate: CLLocationCoordinate2D?
    
    init(dictionary: NSDictionary) {
        businessID = dictionary["id"] as? String
        name = dictionary["name"] as? String
        
        let imageURLString = dictionary["image_url"] as? String
        if imageURLString != nil {
            imageURL = NSURL(string: imageURLString!)
        } else {
            imageURL = nil
        }
        
        let location = dictionary["location"] as? NSDictionary
        var address = ""
        var coordinate = CLLocationCoordinate2D()
        if location != nil {
            let addressArray = location!["address"] as? NSArray
            if addressArray != nil && addressArray!.count > 0 {
                address = addressArray![0] as! String
            }
            
            let neighborhoods = location!["neighborhoods"] as? NSArray
            if neighborhoods != nil && neighborhoods!.count > 0 {
                if !address.isEmpty {
                    address += ", "
                }
                address += neighborhoods![0] as! String
            }
            
            coordinate = CLLocationCoordinate2D(latitude: Double(location!["coordinate"]!["latitude"]!! as! NSNumber), longitude: Double(location!["coordinate"]!["longitude"]!! as! NSNumber))
        }
        self.address = address
        self.coordinate = coordinate
        
        let categoriesArray = dictionary["categories"] as? [[String]]
        if categoriesArray != nil {
            var categoryNames = [String]()
            for category in categoriesArray! {
                let categoryName = category[0]
                categoryNames.append(categoryName)
            }
            categories = categoryNames.joinWithSeparator(", ")
        } else {
            categories = nil
        }
        
        let distanceMeters = dictionary["distance"] as? NSNumber
        if distanceMeters != nil {
            let milesPerMeter = 0.000621371
            distance = String(format: "%.2f mi", milesPerMeter * distanceMeters!.doubleValue)
        } else {
            distance = nil
        }
        
        let ratingImageURLString = dictionary["rating_img_url_large"] as? String
        if ratingImageURLString != nil {
            ratingImageURL = NSURL(string: ratingImageURLString!)
        } else {
            ratingImageURL = nil
        }
        
        reviewCount = dictionary["review_count"] as? NSNumber
        reviews = dictionary["reviews"] as? [NSDictionary]

    }
    
    class func businesses(array array: [NSDictionary]) -> [Business] {
        var businesses = [Business]()
        for dictionary in array {
            let business = Business(dictionary: dictionary)
            businesses.append(business)
        }
        return businesses
    }
    
    class func getDetailWithId(id: String, completion: (Business!, NSError!) -> Void) {
        YelpClient.sharedInstance.getBusinessWithId(id, completion: completion)
    }
    
    class func searchWithTerm(term: String, location: CLLocationCoordinate2D, completion: ([Business]!, NSError!) -> Void) {
        YelpClient.sharedInstance.searchWithTerm(term, location: location, completion: completion)
    }
    
    class func searchWithTerm(term: String, location: CLLocationCoordinate2D, sort: Int?, radius: Int, categories: [String]?, deals: Bool?, offset: Int?, completion: ([Business]!, NSError!) -> Void) -> Void {
        YelpClient.sharedInstance.searchWithTerm(term, location: location, sort: sort, radius: radius, categories: categories, deals: deals, offset: offset, completion: completion)
    }
}
