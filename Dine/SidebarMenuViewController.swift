//
//  SidebarMenuViewController.swift
//  Dine
//
//  Created by you wu on 3/14/16.
//  Copyright © 2016 YYZ. All rights reserved.
//

import UIKit
import Parse

class SidebarMenuViewController: UITableViewController {
    @IBOutlet weak var spaceItem: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        let width = self.view.bounds.width
        print(width)
        spaceItem.width = width * 3.0/5.0 - 40
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onLogOut(sender: AnyObject) {
        PFUser.logOut()
        NSNotificationCenter.defaultCenter().postNotificationName("userDidLogoutNotification", object: nil)
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if (section == 0) {
            let headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 60))
            let header = SidebarMenuHeaderView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 60))
            header.usernameLabel.text = User.currentUser?.screenName
            let tapRecognizer = UITapGestureRecognizer(target: self, action: Selector("imageTapped:"))
            header.addGestureRecognizer(tapRecognizer)
            headerView.addSubview(header)
            
            return headerView
        }
        return nil
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (section == 0) {
            return 60
        }
        return 0
    }
    
    func imageTapped(img: AnyObject){
        self.performSegueWithIdentifier("toUserProfileSegue", sender: self)
    }

    @IBAction func unwindToSidebar(sender: UIStoryboardSegue) {
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        if segue.identifier == "FirendListViewControllerSegue"{
            let vc = segue.destinationViewController as! FriendsViewController
            vc.inviteNotAdd = false
        }
    }
    

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}


