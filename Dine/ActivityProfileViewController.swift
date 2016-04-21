
//
//  ActivityProfileViewController.swift
//  Dine
//
//  Created by you wu on 3/14/16.
//  Copyright © 2016 YYZ. All rights reserved.
//

import UIKit
import MBProgressHUD

class ActivityProfileViewController: UITableViewController{
    let kHeaderHeight:CGFloat = 150.0
    var profileView = UIImageView()
    var smallProfileView: UIImageView!
    var blurView: UIVisualEffectView!
    
    var activity: Activity!
    var groupMembers = [GroupMember]()
    var memberAvatars = [UIImage]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = activity.title

        //check if user joined activity, if true set chatButton enable = true, else set enable = false
        let tableHeaderView = UIView(frame: CGRectMake(0, 0, CGRectGetWidth(self.view.frame), kHeaderHeight))
        
        profileView.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), kHeaderHeight)
        smallProfileView = UIImageView(image: UIImage(named: "map"))

        profileView.clipsToBounds = true
        profileView.contentMode = .ScaleAspectFill
        if let url = activity.profileURL {
            profileView.setImageWithURL(url)
            smallProfileView.setImageWithURL(url)
        }
        
        //blur image
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.ExtraLight)
        blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = profileView.frame
        blurView.alpha = 0.8
        
        smallProfileView.frame = CGRectMake(CGRectGetWidth(self.view.frame)/2.0-40.0, kHeaderHeight/2.0 - 60, 80, 80)
        smallProfileView.clipsToBounds = true
        smallProfileView.layer.cornerRadius = 10
        smallProfileView.contentMode = .ScaleAspectFill

        tableHeaderView.addSubview(profileView)
        tableHeaderView.addSubview(blurView)
        tableHeaderView.addSubview(smallProfileView)
        
        self.tableView.tableHeaderView = tableHeaderView
        fetchGroupMembers()

    }
    
    func fetchGroupMembers() {
        if let activity = activity {
            print("Try fetchGroupMembers")
            activity.fetchGroupMember({ (groupMembers: [GroupMember]) in
                self.groupMembers = groupMembers

                //add member avatars
                var index = 0
                let startX = CGFloat(CGRectGetWidth(self.view.frame)/2.0)-CGFloat(groupMembers.count)*45.0/2.0
                for member in groupMembers {
                    if let avatarFile = member.avatar{
                        avatarFile.getDataInBackgroundWithBlock({
                            (result, error) in
                            self.memberAvatars.insert(UIImage(data: result!)!, atIndex: index)
                            
                            let memberProfileView = UIImageView(image: UIImage(data: result!))
                            memberProfileView.frame = CGRectMake(startX + 50*CGFloat(index), (self.kHeaderHeight/2.0)+30, 40, 40)
                            memberProfileView.clipsToBounds = true
                            memberProfileView.layer.cornerRadius = 20
                            memberProfileView.layer.borderWidth = 2.0
                            memberProfileView.layer.borderColor = UIColor(white: 0.9, alpha: 1).CGColor
                            memberProfileView.contentMode = .ScaleAspectFill
                            self.tableView.tableHeaderView?.addSubview(memberProfileView)
                            index += 1
                            if (index == groupMembers.count) {
                                self.tableView.reloadData()
                            }
                        })
                        
                    }
                }
                print("fetchGroupMembers success \(self.groupMembers.count)")
                }, failureHandler: { (error: NSError?) -> () in
                print(error?.localizedDescription)
            })
        }
    
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("profileCell") as! ActivityProfileCell
                
                cell.activity = self.activity
            if Activity.current_activity == nil {
                cell.checkButton.setImage(UIImage(named: "Checked"), forState: .Normal)
                cell.checkButton.addTarget(self, action: #selector(ActivityProfileViewController.checkButtonClicked(_:)), forControlEvents: UIControlEvents.TouchDown)
            } else if Activity.current_activity!.activityId == self.activity!.activityId {
                cell.checkButton.setImage(UIImage(named: "Cancel"), forState: .Normal)
                cell.checkButton.addTarget(self, action: #selector(ActivityProfileViewController.checkButtonClicked(_:)), forControlEvents: UIControlEvents.TouchDown)
            } else{
                Log.error("should not reach here")
                cell.checkButton.setImage(nil, forState: .Normal)
            }
            cell.checkButton.adjustsImageWhenHighlighted = false
            return cell
            
        }else if (indexPath.section == 1){
            let cell = tableView.dequeueReusableCellWithIdentifier("DesCell", forIndexPath: indexPath) as! ActivityDesCell
            cell.desLabel.text = self.activity.overview
            return cell
        }else {
            let cell = tableView.dequeueReusableCellWithIdentifier("memberCell", forIndexPath: indexPath) as! ActivityMemberCell
            let member = groupMembers[indexPath.row]
            cell.profile = memberAvatars[indexPath.row]
            cell.userId = member.userId
            cell.nameLabel.text = member.screenName
            if member.joined {
                //update member location info
                member.getLocation(self.activity.activityId!, successHandler: { (loc:PFGeoPoint) in
                    let dest = PFGeoPoint(latitude: self.activity.location.latitude, longitude: self.activity.location.longitude)
                    cell.statusLabel.text = String(format: "%.1f", loc.distanceInMilesTo(dest))+" Miles Away"
                    }, failureHandler: { (error:NSError?) in
                        cell.statusLabel.text = "Accepted"
                        Log.error("Cannot get member location info")
                })
                cell.profileView.alpha = 0.9
            } else {
                cell.statusLabel.text = "Invited"
                cell.profileView.alpha = 0.5
            }
            return cell
        }
    }
    
   
    func checkButtonClicked (sender : UIButton!) {
        if Activity.current_activity == nil {
            sender.setImage(UIImage(named: "cancel"), forState: .Normal)
            sender.setImage(UIImage(named: "cancel"), forState: .Highlighted)
            Activity.current_activity = self.activity
            self.activity.joinActivity({
                NSNotificationCenter.defaultCenter().postNotificationName("userJoinedNotification", object: nil)
                }, failureHandler: { (error: NSError?) in
                    Log.error(error?.localizedDescription)
                    
            })

        }else {
            sender.setImage(UIImage(named: "checked"), forState: .Normal)
            sender.setImage(UIImage(named: "checked"), forState: .Highlighted)
            NSNotificationCenter.defaultCenter().postNotificationName("userExitedNotification", object: nil)
        }
        
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 95
        }
        return 45
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 3
    }
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (section == 0) {
            return 0
        }else {
            return 21.0
        }
    }

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (section == 2) {
            return "Group Members"
        }
        if (section == 1) {
            return "About"
        }
        return ""
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if (section == 2) {
            return groupMembers.count
        }else {
            return 1
        }
    }
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        let yPos: CGFloat = -scrollView.contentOffset.y
        
        if (yPos > 0) {
            var imgRect: CGRect = profileView.frame
            imgRect.origin.y = scrollView.contentOffset.y
            imgRect.size.height = kHeaderHeight + yPos
            profileView.frame = imgRect
            blurView.frame = imgRect

        }
        
    }
    
    /*
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toGroupChatSegue" {
            let vc = segue.destinationViewController as! ChatViewController
        }
    }
    */

}
