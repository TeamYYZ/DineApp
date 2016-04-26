
//
//  ActivityProfileViewController.swift
//  Dine
//
//  Created by you wu on 3/14/16.
//  Copyright © 2016 YYZ. All rights reserved.
//

import UIKit
import MBProgressHUD

struct preview {
    var isPreview = false
    var activityId: String?
    var notificationIndex: Int?
    var mapVC: MapViewController?
}

@objc protocol ActivityProfileViewControllerDelegate {
    optional func activityView(activityView: ActivityProfileViewController, associatedNotificationIndex notificationIndex: Int)
}

class ActivityProfileViewController: UITableViewController{
    lazy var previewIndicator = preview()
    weak var delegate: ActivityProfileViewControllerDelegate?
    let kHeaderHeight:CGFloat = 150.0
    var profileView = UIImageView()
    var smallProfileView: UIImageView!
    var blurView: UIVisualEffectView!
    
    var activity: Activity?
    var groupMembers = [GroupMember]()
    var memberAvatars = [UIImage]()

    
    
    func setupActivityForVC() {
        if let activityForSetup = activity {
            self.title = activityForSetup.title
            
            //check if user joined activity, if true set chatButton enable = true, else set enable = false
            let tableHeaderView = UIView(frame: CGRectMake(0, 0, CGRectGetWidth(self.view.frame), kHeaderHeight))
            
            profileView.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), kHeaderHeight)
            smallProfileView = UIImageView(image: UIImage(named: "map"))
            
            profileView.clipsToBounds = true
            profileView.contentMode = .ScaleAspectFill
            if let url = activityForSetup.profileURL {
                profileView.setImageWithURL(url)
                smallProfileView.setImageWithURL(url)
            }
            
            //blur image
            let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.ExtraLight)
            blurView = UIVisualEffectView(effect: blurEffect)
            blurView.frame = profileView.frame
            blurView.alpha = 0.8
            
            smallProfileView.frame = CGRectMake(CGRectGetWidth(self.view.frame)/2.0-40.0, kHeaderHeight/2.0-30, 80, 80)
            smallProfileView.clipsToBounds = true
            smallProfileView.layer.cornerRadius = 10
            smallProfileView.contentMode = .ScaleAspectFill
            
            tableHeaderView.addSubview(profileView)
            tableHeaderView.addSubview(blurView)
            tableHeaderView.addSubview(smallProfileView)
            
            self.tableView.tableHeaderView = tableHeaderView
            fetchGroupMembers()
        
        
        } else {
            Log.error("No activity found")
        }

    
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
        setupActivityForVC()
        if previewIndicator.isPreview == true {
            guard let activityId = previewIndicator.activityId else {
                Log.error("no activityId")
                return
            }
            
            Activity.getActivityById(activityId, successHandler: { (fetchedActivity: Activity) in
                self.activity = fetchedActivity
                self.setupActivityForVC()
                }, failureHandler: { (error: NSError?) in
                   Log.error(error?.localizedDescription)
            })
        }
    }
    
    func fetchGroupMembers() {
        if let activity = self.activity {
            print("Try fetchGroupMembers")
            activity.fetchGroupMember({ (groupMembers: [GroupMember]) in
                self.groupMembers = groupMembers

//                var index = 0
//                let startX = CGFloat(CGRectGetWidth(self.view.frame)/2.0) - CGFloat(groupMembers.count) * 45.0 / 2.0
//
//                for member in groupMembers {
//                    if let avatarFile = member.avatar{
//                        avatarFile.getDataInBackgroundWithBlock({
//                            (result, error) in
//                            
//                            let memberProfileView = UIImageView(image: UIImage(data: result!))
//                            memberProfileView.frame = CGRectMake(startX + 50*CGFloat(index), (self.kHeaderHeight/2.0) + 30, 40, 40)
//                            memberProfileView.clipsToBounds = true
//                            memberProfileView.layer.cornerRadius = 20
//                            memberProfileView.layer.borderWidth = 2.0
//                            memberProfileView.layer.borderColor = UIColor(white: 0.3, alpha: 0.5).CGColor
//                            memberProfileView.contentMode = .ScaleAspectFill
//                            self.tableView.tableHeaderView?.addSubview(memberProfileView)
//                            index+=1
//                        })
//                        
//                    }
//                }
                self.tableView.reloadData()
                print("fetchGroupMembers success \(self.groupMembers.count)")
                }, failureHandler: { (error: NSError?) -> () in
                print(error?.localizedDescription)
            })
        }
    
    }
    
    
    func profileTap (sender: AnyObject) {
        
        let position: CGPoint =  sender.locationInView(self.tableView)
        let indexPath: NSIndexPath = self.tableView.indexPathForRowAtPoint(position)!
        performSegueWithIdentifier("toUserProfileFromAPVCSegue", sender: indexPath)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let guardedActivity = activity, guardedActivityId =  activity?.activityId else {
            Log.error("Activity not found")
            return UITableViewCell()
        }
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("profileCell") as! ActivityProfileCell
                
            cell.activity = guardedActivity
            cell.checkButton.layer.cornerRadius = 5
            cell.checkButton.layer.borderWidth = 1
            cell.checkButton.layer.borderColor = UIColor.flatGrayColor().CGColor
            
            cell.chatButton.layer.cornerRadius = 5
            cell.chatButton.layer.borderWidth = 1
            cell.chatButton.layer.borderColor = UIColor.flatGrayColor().CGColor
            
            if Activity.current_activity == nil {
                Log.info("Activity.current_activity == nil")
                cell.checkButton.setTitle("Going", forState: .Normal)
                cell.checkButton.setTitle("Going", forState: .Highlighted)
                cell.checkButton.addTarget(self, action: #selector(ActivityProfileViewController.checkButtonClicked(_:)), forControlEvents: UIControlEvents.TouchDown)
            } else if Activity.current_activity!.activityId == guardedActivityId {
                cell.checkButton.setTitle("Cancel", forState: .Normal)
                cell.checkButton.setTitle("Cancel", forState: .Highlighted)
                cell.checkButton.addTarget(self, action: #selector(ActivityProfileViewController.checkButtonClicked(_:)), forControlEvents: UIControlEvents.TouchDown)
            } else{
                Log.error("should not reach here")
                cell.checkButton.setImage(nil, forState: .Normal)
            }
            cell.checkButton.adjustsImageWhenHighlighted = false
            
            return cell
            
        }else if (indexPath.section == 1){
            let cell = tableView.dequeueReusableCellWithIdentifier("DesCell", forIndexPath: indexPath) as! ActivityDesCell
            cell.desLabel.text = self.activity?.overview
            return cell
        }else {
            let cell = tableView.dequeueReusableCellWithIdentifier("memberCell", forIndexPath: indexPath) as! ActivityMemberCell
            let member = groupMembers[indexPath.row]
            if let avatarFile = member.avatar{
                avatarFile.getDataInBackgroundWithBlock({
                    (result, error) in
                    cell.profile = UIImage(data: result!)!
                    })
            }
            if cell.profileView.userInteractionEnabled == false {
                cell.profileView.userInteractionEnabled = true
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ActivityProfileViewController.profileTap(_:)))
                cell.profileView.addGestureRecognizer(tapGesture)
            }
            cell.userId = member.userId
            cell.nameLabel.text = member.screenName
            if member.joined {
                //update member location info
                
                member.getLocation(guardedActivityId, successHandler: { (loc:PFGeoPoint) in
                    let dest = PFGeoPoint(latitude: guardedActivity.location.latitude, longitude: guardedActivity.location.longitude)
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
            sender.setTitle("Cancel", forState: .Normal)
            sender.setTitle("Cancel", forState: .Highlighted)
            Activity.current_activity = self.activity
            self.activity?.joinActivity({
                NSNotificationCenter.defaultCenter().postNotificationName("userJoinedNotification", object: nil)
                if self.previewIndicator.isPreview {
                    if let index = self.previewIndicator.notificationIndex {
                        self.delegate?.activityView?(self, associatedNotificationIndex: index)
                    }
                    self.navigationController?.popViewControllerAnimated(true)
                }
                
                }, failureHandler: { (error: NSError?) in
                    Log.error(error?.localizedDescription)
                    
            })

        } else {
            sender.setTitle("Going", forState: .Normal)
            sender.setTitle("Going", forState: .Highlighted)
            NSNotificationCenter.defaultCenter().postNotificationName("userExitedNotification", object: nil)
        }
        
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 130
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
            blurView?.frame = imgRect

        }
        
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toUserProfileFromAPVCSegue" {
            let vc = segue.destinationViewController as! UserProfileViewController
            let indexPath = sender as! NSIndexPath
            let id = self.groupMembers[indexPath.row].userId
            vc.uid = id
        }
    }
    

}
