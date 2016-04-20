//
//  Utils.swift
//  Dine
//
//  Created by YiHuang on 4/5/16.
//  Copyright © 2016 YYZ. All rights reserved.
//

import Foundation

func resize(image: UIImage, newSize: CGSize) -> UIImage {
    let resizeImageView = UIImageView(frame: CGRectMake(0, 0, newSize.width, newSize.height))
    resizeImageView.contentMode = UIViewContentMode.ScaleAspectFill
    resizeImageView.image = image
    
    UIGraphicsBeginImageContext(resizeImageView.frame.size)
    resizeImageView.layer.renderInContext(UIGraphicsGetCurrentContext()!)
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return newImage
}

func getPFFileFromImage(image: UIImage?) -> PFFile? {
    // check if image is not nil
    if let image = image {
        // get image data and check if that is not nil
        if let imageData = UIImagePNGRepresentation(image) {
            return PFFile(name: "image.png", data: imageData)
        }
    }
    return nil
}

class Log {
    
    class func info(content: String?) {
        if let content = content {
            print("[Log][INFO]: \(content)")
        } else {
            print("[Log][INFO]: nil")
        }
    }
    
    class func error(content: String?) {
        if let content = content {
            print("[Log][ERROR]: \(content)")
        } else {
            print("[Log][ERROR]: nil")
        }
    }
    
    class func warning(content: String?) {
        if let content = content {
            print("[Log][WARN]: \(content)")
        } else {
            print("[Log][WARN]: nil")
        }
    }
}

extension NSDate {
    func yearsFrom(date:NSDate) -> Int{
        return NSCalendar.currentCalendar().components(NSCalendarUnit.Year, fromDate: date, toDate: self, options: .MatchLast).year
    }
    
    func monthsFrom(date:NSDate) -> Int{
        return NSCalendar.currentCalendar().components(NSCalendarUnit.Month, fromDate: date, toDate: self, options: .MatchLast).month
    }

    func daysFrom(date:NSDate) -> Int{
        return NSCalendar.currentCalendar().components(NSCalendarUnit.Day, fromDate: date, toDate: self, options: .MatchLast).day
    }
    func hoursFrom(date:NSDate) -> Int{
        return NSCalendar.currentCalendar().components(NSCalendarUnit.Hour, fromDate: date, toDate: self, options: .MatchLast).hour
    }
    func minutesFrom(date:NSDate) -> Int{
        return NSCalendar.currentCalendar().components(NSCalendarUnit.Minute, fromDate: date, toDate: self, options: .MatchLast).minute
    }
    func secondsFrom(date:NSDate) -> Int{
        return NSCalendar.currentCalendar().components(NSCalendarUnit.Second, fromDate: date, toDate: self, options: .MatchLast).second
    }

}