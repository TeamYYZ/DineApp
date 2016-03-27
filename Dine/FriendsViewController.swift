//
//  FriendsViewController.swift
//  Dine
//
//  Created by you wu on 3/13/16.
//  Copyright © 2016 YYZ. All rights reserved.
//

import UIKit

class FriendsViewController: UITableViewController {
    @IBOutlet weak var menuButton: UIBarButtonItem!
    weak var activityInProgress: Activity?

    var inviteNotAdd = Bool()
    //    var kk: Int = 5


    var checked: [Bool]!
    @IBOutlet weak var inviteButton: UIBarButtonItem!
    
    var requests:[String] = ["July", "S", "Beth"]

    //var friendsIdList = User.currentUser?.friendList
    var friendsIdList = ["TcayLCwdsI", "rBtM0A2hb2"]
    var friendsUserList = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(inviteNotAdd)
        if inviteNotAdd{
            inviteButton.enabled = false
            inviteButton.image = nil
            inviteButton.title = "Invite"
            inviteButton.tag = 0
        }else{

            inviteButton.enabled = true
            inviteButton.tag = 1
        }
        menuButton.target = self.revealViewController()
        menuButton.action = Selector("revealToggle:")
        checked = [Bool](count: friendsIdList.count, repeatedValue: false)
        tableView.dataSource = self
        tableView.delegate = self
        for friendId in friendsIdList{
            let query = PFUser.query()
            query!.getObjectInBackgroundWithId(friendId) {
                (friend: PFObject?, error: NSError?) -> Void in
                if error == nil && friend != nil {
                    let friendAsPFUser = friend as! PFUser
                    let friendAsUser = User.init(pfUser: friendAsPFUser)
                    self.friendsUserList.append(friendAsUser)
                    self.tableView.reloadData()
                } else {
                    print("Fail to get the friendList")
                    print(error)
                }
            }
            
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if inviteNotAdd == true{
        checked[indexPath.row] = !checked[indexPath.row]
        var enableInviteButton = false
        for checkbox in checked {
            if checkbox {
                enableInviteButton = true
                break
            }
        }
        if enableInviteButton {
            inviteButton.enabled = true
        }else {
            inviteButton.enabled = false
        }
            tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        }
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {

        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return friendsUserList.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("friendCell", forIndexPath: indexPath) as! FriendCell
        if inviteNotAdd == true {
        if checked[indexPath.row] {
            
            cell.accessoryType = .Checkmark
            cell.inviteLabel.text = "Invited"
            cell.inviteLabel.textColor = UIColor.flatGrayColor()
        } else {
            
            cell.accessoryType = .None
            cell.inviteLabel.text = "Invite"
            cell.inviteLabel.textColor = UIColor.flatSkyBlueColor()
            }
        }else{
            cell.inviteLabel.hidden = true
        }
        let friend = self.friendsUserList[indexPath.row]
        if let userName = friend.username{
            cell.userNameLabel.text! = userName
        }
        if let avatarImage = friend.avatarImage{
            cell.avatarImage.image = avatarImage
        }
        return cell
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

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let button = sender as! UIBarButtonItem
            if button.tag == 0{
                var invitedIdList = [String]()
                for (index, value) in checked.enumerate() {
            if value {
                invitedIdList.append(friendsIdList[index])
            }
        }
            activityInProgress?.setupGroup(invitedIdList)
        }
            
        
    }
    

}
