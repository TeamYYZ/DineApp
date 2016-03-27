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
    var notifications = [UserNotification]()
    
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
        cell.senderLabel.text = notification.senderName
        return cell
    }
    
    func fetchNotifications() {
        if let user = User.currentUser {
            user.getNotifications({ (fetchedNotifications: [UserNotification]?) -> () in
                if let notifications = fetchedNotifications {
                    self.notifications = notifications
                    self.tableView.reloadData()
                }
            })
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        fetchNotifications()
        tableView.registerNib(UINib(nibName: "NotificationCell", bundle: nil), forCellReuseIdentifier: "NotificationCell")
        
        // Do any additional setup after loading the view.
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
