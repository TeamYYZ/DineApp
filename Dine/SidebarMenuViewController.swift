//
//  SidebarMenuViewController.swift
//  Dine
//
//  Created by you wu on 3/14/16.
//  Copyright © 2016 YYZ. All rights reserved.
//

import UIKit

enum LeftMenu: Int {
    case Main = 0
    case Friends
    case Notifications
    case ProfileSettings
}

protocol SideMenuProtocol : class {
    func changeViewController(menu: LeftMenu)
}

extension SlideMenuController {
    func setCloseWindowLevel() {
        if (SlideMenuOptions.hideStatusBar) {
            dispatch_async(dispatch_get_main_queue(), {
                if let window = UIApplication.sharedApplication().keyWindow {
                    window.windowLevel = UIWindowLevelNormal
                }
            })
        }
    }
}

class SidebarMenuViewController: UITableViewController, SideMenuProtocol {

    var mainViewController: UIViewController!
    var friendsViewController: UIViewController!
    var notificationsViewController: UIViewController!
    var profileSettingsController: UIViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let logoutButton = UIBarButtonItem(title: "Logout", style: .Plain, target: self, action: #selector(SidebarMenuViewController.onLogOut(_:)))
        self.setToolbarItems([logoutButton], animated: false)
        self.navigationController?.toolbarHidden = false
        self.navigationController?.navigationBarHidden = true
        

        //create menu
        let friendSB = UIStoryboard(name: "FriendList", bundle: nil)
        let friendVC = friendSB.instantiateViewControllerWithIdentifier("FriendsViewController") as! FriendsViewController
        self.friendsViewController = UINavigationController(rootViewController: friendVC)
        
        let notificationSB = UIStoryboard(name: "Notifications", bundle: nil)
        let notificationVC = notificationSB.instantiateViewControllerWithIdentifier("NotificationViewController") as! NotificationViewController
        self.notificationsViewController = UINavigationController(rootViewController: notificationVC)
        
        let profileSettingsSB = UIStoryboard(name: "ProfileSettings", bundle: nil)
        let profileSettingsVC = profileSettingsSB.instantiateViewControllerWithIdentifier("ProfileSettingsViewController") as! ProfileSettingsViewController
        self.profileSettingsController = UINavigationController(rootViewController: profileSettingsVC)

    }
 
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func onLogOut(sender: AnyObject) {
        PFUser.logOut()
        self.slideMenuController()?.setCloseWindowLevel()
        NSNotificationCenter.defaultCenter().postNotificationName("userDidLogoutNotification", object: nil)
    }
    
    func changeViewController(menu: LeftMenu) {
//        print("main view controller")
//        print(self.mainViewController)
        switch menu {
        case .Main:
            self.slideMenuController()?.changeMainViewController(self.mainViewController, close: true)
            
        case .Friends:
            self.slideMenuController()?.changeMainViewController(self.friendsViewController, close: true)
        case .Notifications:
            self.slideMenuController()?.changeMainViewController(self.notificationsViewController, close: true)
        case .ProfileSettings:
            self.slideMenuController()?.changeMainViewController(self.profileSettingsController, close: true)
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let menu = LeftMenu(rawValue: indexPath.item) {
            self.changeViewController(menu)
        }
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if (section == 0) {
            let headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 60))
            let header = SidebarMenuHeaderView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 60))
            header.usernameLabel.text = User.currentUser?.screenName
            let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(SidebarMenuViewController.imageTapped(_:)))
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
    
}


