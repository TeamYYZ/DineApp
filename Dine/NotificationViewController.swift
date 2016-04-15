//
//  NotificationViewController.swift
//  Dine
//
//  Created by YiHuang on 3/26/16.
//  Copyright © 2016 YYZ. All rights reserved.
//

import UIKit

class NotificationViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
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
            cell.typeImageView.image = UIImage(named: "addFriend")
        case .Invitation:
            cell.typeLabel.text = "Activity Invitation"
            cell.typeImageView.image = UIImage(named: "dine")
        default:
            cell.typeLabel.text = "Unknown"
        }
        cell.senderLabel.text = notification.senderName
        cell.acceptButton.removeTarget(self, action: #selector(NotificationViewController.acceptRequest(_:)), forControlEvents: .TouchDown)
        cell.acceptButton.addTarget(self, action: #selector(NotificationViewController.acceptRequest(_:)), forControlEvents: .TouchDown)
        cell.acceptButton.tag = indexPath.row
        return cell
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        let notification = notifications[indexPath.row]
        notification.delete()
        notifications.removeAtIndex(indexPath.row)
        
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
        if let user = User.currentUser {
            user.getNotifications({ (fetchedNotifications: [UserNotification]?) -> () in
                if let notifications = fetchedNotifications {
                    self.notifications = notifications
                    self.tableView.reloadData()
                    self.refreshControl.endRefreshing()
                }
            })
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        self.edgesForExtendedLayout = UIRectEdge.None
        tableView.registerNib(UINib(nibName: "NotificationCell", bundle: nil), forCellReuseIdentifier: "NotificationCell")
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 62
        refreshControl.addTarget(self, action: #selector(NotificationViewController.refreshControlAction(_:)), forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)
        fetchNotifications()

        
        // Do any additional setup after loading the view.
    }

    func refreshControlAction(refreshControl: UIRefreshControl) {
        fetchNotifications()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
