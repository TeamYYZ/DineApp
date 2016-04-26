//
//  NotificationViewController.swift
//  Dine
//
//  Created by YiHuang on 3/26/16.
//  Copyright © 2016 YYZ. All rights reserved.
//

import UIKit

class NotificationViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UserProfileViewControllerDelegate, ActivityProfileViewControllerDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    static let NCObserverName = "NOTIFICATIONVIEWOBNAME"
    weak var mapVC: MapViewController?
    
    let refreshControl = UIRefreshControl()
    var notifications = [UserNotification]()
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavigationBarItem()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("NotificationCell", forIndexPath: indexPath) as! NotificationCell
        let notification = notifications[indexPath.row]
        switch notification.type {
        case .FriendRequest:
            cell.typeLabel.text = "Friend Request"
        case .Invitation:
            cell.typeLabel.text = "Activity Invitation"
        default:
            cell.typeLabel.text = "Unknown"
        }

        if let file = notification.senderAvatarPFFile {
            file.getDataInBackgroundWithBlock({
                (result, error) in
                if let data = result where error == nil {
                    cell.typeImageView.image = UIImage(data: data)
                } else {
                    Log.error(error?.localizedDescription)
                }
            })
        } else {
            cell.typeImageView.image = UIImage(named: "User")
        }
        
        cell.senderLabel.text = notification.senderName
        cell.acceptButton.removeTarget(self, action: #selector(NotificationViewController.acceptRequest(_:)), forControlEvents: .TouchDown)
        cell.acceptButton.addTarget(self, action: #selector(NotificationViewController.acceptRequest(_:)), forControlEvents: .TouchDown)
        cell.acceptButton.tag = indexPath.row
        
        if cell.typeImageView.userInteractionEnabled == false {
            cell.typeImageView.userInteractionEnabled = true
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(NotificationViewController.profileTap(_:)))
            cell.typeImageView.addGestureRecognizer(tapGesture)
            cell.typeImageView.layer.cornerRadius = 10.0
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        return cell
    }
    
    func profileTap (sender: AnyObject) {
        
        let position: CGPoint =  sender.locationInView(self.tableView)
        let indexPath: NSIndexPath = self.tableView.indexPathForRowAtPoint(position)!
        performSegueWithIdentifier("toUserProfile", sender: indexPath)
        
    }
    
    func UserProfile(userprofile: UserProfileViewController, didAcceptRequest withNotificationIndex: Int) {
        self.acceptRequestWithNotificationIndex(withNotificationIndex)
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let notification = notifications[indexPath.row]
        Log.info("notification.type \(notification.type)")
        if notification.type == .Invitation {
            let storyBoard = UIStoryboard(name: "ActivityProfileViewController", bundle: NSBundle.mainBundle())
            let activityVC = storyBoard.instantiateViewControllerWithIdentifier("ActivityProfileVC") as! ActivityProfileViewController
            activityVC.previewIndicator.isPreview = true
            activityVC.previewIndicator.activityId = notification.associatedId
            activityVC.previewIndicator.mapVC = mapVC
            activityVC.previewIndicator.notificationIndex = indexPath.row
            activityVC.delegate = self
            self.navigationController?.pushViewController(activityVC, animated: true)
        }

    }
    

    func activityView(activityView: ActivityProfileViewController, associatedNotificationIndex notificationIndex: Int) {
        let notification = notifications[notificationIndex]
        notification.delete()
        notifications.removeAtIndex(notificationIndex)
        tableView.reloadData()
    }

    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        let notification = notifications[indexPath.row]
        notification.delete()
        notifications.removeAtIndex(indexPath.row)
        tableView.reloadData()
    }
    
    
    func acceptRequestWithNotificationIndex(sender: AnyObject){
        let index = sender as! Int
        let notification = notifications[index]
        notification.acceptRequest({ (type: NotificationType) in
            if type == .Invitation {
                Log.info("join activity successfully")
                NSNotificationCenter.defaultCenter().postNotificationName("userJoinedNotification", object: nil)
            }
        }) { (error: NSError?) in
            Log.info(error?.localizedDescription)
        }
        notifications.removeAtIndex(index)
        tableView.reloadData()
    }
    
    func acceptRequest(sender: AnyObject){
        let index = sender.tag
        let notification = notifications[index]
        notification.acceptRequest({ (type: NotificationType) in
            if type == .Invitation {
                Log.info("join activity successfully")
                NSNotificationCenter.defaultCenter().postNotificationName("userJoinedNotification", object: nil)
            }
        }) { (error: NSError?) in
            Log.info(error?.localizedDescription)
        }
        notifications.removeAtIndex(index)
        tableView.reloadData()
    }
    
    
    func fetchNotifications() {
        notifications = [UserNotification]()
        if let user = User.currentUser {
            user.getNotifications({ (fetchedNotifications: [UserNotification]?) -> () in
                if let notifications = fetchedNotifications {
                    self.notifications = notifications
                    Log.info("time to end refresshing here")
                    self.refreshControl.endRefreshing()
                    self.tableView.reloadData()
                    return
                }
                
                Log.info("time to end refresshing here")
                self.refreshControl.endRefreshing()
                self.tableView.reloadData()

            })

        }
    }
    
//
//    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        tableView.deselectRowAtIndexPath(indexPath, animated: false)
//    }
    
    
    func pushToPullNewMessages() {
        fetchNotifications()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
        
        tableView.delegate = self
        tableView.dataSource = self
        self.edgesForExtendedLayout = UIRectEdge.None
        tableView.registerNib(UINib(nibName: "NotificationCell", bundle: nil), forCellReuseIdentifier: "NotificationCell")
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 62
        refreshControl.addTarget(self, action: #selector(NotificationViewController.refreshControlAction(_:)), forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)
        fetchNotifications()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(NotificationViewController.pushToPullNewMessages), name: NotificationViewController.NCObserverName, object: nil)


        
        // Do any additional setup after loading the view.
    }

    func refreshControlAction(refreshControl: UIRefreshControl) {
        fetchNotifications()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "toUserProfile"{
            let indexPath = sender as! NSIndexPath
            let notification = self.notifications[indexPath.row]
            let id = notification.senderId
            let vc = segue.destinationViewController as! UserProfileViewController
            vc.uid = id
            vc.delegate = self
            vc.notificationIndex = indexPath.row
            if notification.type == .FriendRequest{
                vc.isAcceptButton = true
            }
        }
        
    }
    

}
