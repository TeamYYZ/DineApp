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
    let menuTextList = ["Home", "Friends", "Notifications", "Settings"]
    let menuImageList = ["MapMarker", "UserGroup", "Invite", "Settings"]
    var selectedIndex = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBarHidden = true
        
        tableView.backgroundColor = ColorTheme.sharedInstance.menuBackgroundColor
        
        
        // MARK: reg Nib
        tableView.registerNib(UINib(nibName: "MenuCell", bundle: nil), forCellReuseIdentifier: "MenuCell")
        
        // MARK: create VCs for menu
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

    
    func changeViewController(menu: LeftMenu) {
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
            let cell = tableView.cellForRowAtIndexPath(indexPath)
            cell?.backgroundColor = ColorTheme.sharedInstance.menuSelectedBackgroundColor
            selectedIndex = indexPath.row
            tableView.reloadData()
            self.changeViewController(menu)
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuTextList.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MenuCell", forIndexPath: indexPath) as! MenuCell
        let index = indexPath.row
        if index == selectedIndex {
            cell.backgroundColor = ColorTheme.sharedInstance.menuSelectedBackgroundColor
        } else {
            cell.backgroundColor = ColorTheme.sharedInstance.menuBackgroundColor
        }
        cell.menuTextLabel.textColor = ColorTheme.sharedInstance.menuTextColor
        cell.menuTextLabel.text = menuTextList[index]
        cell.iconImageView.image = UIImage(named: menuImageList[index])
        cell.iconImageView.image?.imageWithRenderingMode(.AlwaysTemplate)
        cell.iconImageView.tintColor = ColorTheme.sharedInstance.menuTextColor
        return cell
    
    }
    
    /*
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if (section == 0) {
            let headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 60))
            let header = SidebarMenuHeaderView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 60))
            header.view.backgroundColor = ColorTheme.sharedInstance.menuBackgroundColor
            header.usernameLabel.text = User.currentUser?.screenName
            header.usernameLabel.textColor = ColorTheme.sharedInstance.menuTextColor
            let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(SidebarMenuViewController.imageTapped(_:)))
            header.addGestureRecognizer(tapRecognizer)
            headerView.backgroundColor = header.backgroundColor
            headerView.addSubview(header)
            
            return headerView
        }
        return nil
    }
 */
    
//    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        if (section == 0) {
//            return 60
//        }
//        return 0
//    }
//    
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


