//
//  RestaurantDetailViewController.swift
//  Dine
//
//  Created by you wu on 3/14/16.
//  Copyright © 2016 YYZ. All rights reserved.
//

import UIKit
import MapKit

class RestaurantDetailViewController: UITableViewController {
    
    let kHeaderHeight:CGFloat = 150.0
    var profileView: UIImageView!
    var smallProfileView: UIImageView!
    var blurView: UIVisualEffectView!
    weak var activityInProgress: Activity?
    var business: Business!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let tableHeaderView = UIView(frame: CGRectMake(0, 0, CGRectGetWidth(self.view.frame), kHeaderHeight))
        profileView = UIImageView(image: UIImage(named: "map"))
        smallProfileView = UIImageView(image: UIImage(named: "map"))
        if business.imageURL != nil {
            profileView.setImageWithURL(business.imageURL!)
            smallProfileView.setImageWithURL(business.imageURL!)
        }
        profileView.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), kHeaderHeight)
        profileView.clipsToBounds = true
        profileView.contentMode = .ScaleAspectFill
        
        //blur image
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.ExtraLight)
        blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = profileView.frame
        blurView.alpha = 0.8
        
        smallProfileView.frame = CGRectMake(CGRectGetWidth(self.view.frame)/2.0-40.0, kHeaderHeight/2.0 - 40, 80, 80)
        smallProfileView.clipsToBounds = true
        smallProfileView.layer.cornerRadius = 5
        smallProfileView.contentMode = .ScaleAspectFill
        
        tableHeaderView.addSubview(profileView)
        tableHeaderView.addSubview(blurView)
        tableHeaderView.addSubview(smallProfileView)
        
        tableView.tableHeaderView = tableHeaderView
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 120
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return (business.reviews?.count)!+2
    }


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            //profile
        let cell = tableView.dequeueReusableCellWithIdentifier("profileCell", forIndexPath: indexPath) as! RestaurantProfileCell
            cell.business = business
        // Configure the cell...
            

        return cell
        }
        else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCellWithIdentifier("mapCell", forIndexPath: indexPath) as! MapCell
            cell.business = business
            // Configure the cell...
            
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCellWithIdentifier("reviewCell", forIndexPath: indexPath) as! RestaurantReviewCell
            if business.reviews != nil {
                cell.review = business.reviews![indexPath.row - 2]
            }
            // Configure the cell...
            
            return cell
        }
    }

    override func scrollViewDidScroll(scrollView: UIScrollView) {
        let yPos: CGFloat = -scrollView.contentOffset.y
        
        if (yPos > 0) {
            var imgRect: CGRect = profileView.frame
            imgRect.origin.y = scrollView.contentOffset.y
            imgRect.size.height = kHeaderHeight+yPos
            profileView.frame = imgRect
            blurView.frame = imgRect
        }
    }

    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "finishRestaurantPickSegue" {
            let vc = segue.destinationViewController as! FriendsViewController
            vc.activityInProgress = self.activityInProgress
            
            
        }
    }

}
