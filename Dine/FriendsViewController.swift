//
//  FriendsViewController.swift
//  Dine
//
//  Created by you wu on 3/13/16.
//  Copyright © 2016 YYZ. All rights reserved.
//

import UIKit

class FriendsViewController: UITableViewController {
    
    weak var activityInProgress: Activity?

    var inviteNotAdd = Bool()
    //    var kk: Int = 5


    var checked: [Bool]!
    @IBOutlet weak var inviteButton: UIBarButtonItem!
    


    //var friendsIdList = User.currentUser?.friendList
    var friendsIdList = [String]()
    var friendsUserList = [User]()
    var friendsUserDic = [String : [User]]()
    var friendUsernameTitles = [String]()
    let friendUsernameIndexTitles =  ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if inviteNotAdd{
            inviteButton.enabled = false
            inviteButton.image = nil
            inviteButton.title = "Invite"
            inviteButton.tag = 0
        }else{

            inviteButton.enabled = true
            inviteButton.tag = 1
        }
        fetchFriendList()

        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 120


    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if activityInProgress == nil {
            self.setNavigationBarItem()
        }
    }
    
    func fetchFriendList() {
        User.currentUser?.getFriendsList({ (friendList: [String]?) -> () in
            if let fetchedfriendList = friendList {
                self.friendsIdList = fetchedfriendList
                print(self.friendUsernameTitles)
                self.generateFriendDic()
                self.checked = [Bool](count: self.friendsIdList.count, repeatedValue: false)
            }
        })
    }
    
    func generateFriendDic(){
        let query = PFUser.query()
        query?.whereKey("objectId", containedIn: friendsIdList)
        query?.findObjectsInBackgroundWithBlock({ (friends:[PFObject]?, error: NSError?) -> Void in
        if error == nil && friends != nil {
            self.friendsUserList = [User]()
            for friend in friends! {
                let friendAsPFUser = friend as! PFUser
                let friendAsUser = User(pfUser: friendAsPFUser)
                self.friendsUserList.append(friendAsUser)
                let username = friendAsUser.screenName
                let usernameKey = username!.substringToIndex(username!.startIndex.advancedBy(1)).uppercaseString
                if var usernameValues = self.friendsUserDic[usernameKey] {
                    usernameValues.append(friendAsUser)
                    self.friendsUserDic[usernameKey] = usernameValues
                } else {
                    self.friendsUserDic[usernameKey] = [friendAsUser]
                    self.friendUsernameTitles.append(usernameKey)
                    self.friendUsernameTitles.sortInPlace()
                }
            
            }

            self.tableView.reloadData()
            
        } else {
            print("Fail to get the friendList")
            print(error)
        }
        })

        
    }
    
    override func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        return self.friendUsernameIndexTitles
    }
    
    override func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
        guard let index = self.friendUsernameTitles.indexOf(title) else {
            return -1
        }
        return index
        

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

        return friendsUserDic.count
    }
    
    override func  tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return friendUsernameTitles[section]
    }
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        let usernameKey = self.friendUsernameTitles[section]
        if let usernameValues = self.friendsUserDic[usernameKey] {
            return usernameValues.count
        }
        return 0
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("friendCell", forIndexPath: indexPath) as! FriendCell
        let usernameKey = self.friendUsernameTitles[indexPath.section]
        if let usernameValues = self.friendsUserDic[usernameKey]{
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

                cell.userNameLabel.text = usernameValues[indexPath.row].screenName
    
                if let avatarImage = usernameValues[indexPath.row].avatarImage{
                    cell.avatarImage.image = avatarImage
                }
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        let headerView = view as! UITableViewHeaderFooterView
        headerView.textLabel?.textColor = UIColor.orangeColor()
        headerView.textLabel?.font = UIFont(name: "Avenir", size: 14.0)
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
        if let button = sender as? UIBarButtonItem {
            if button.tag == 0{
                var invitedIdList = [GroupMember]()
                for (index, value) in checked.enumerate() {
                    if value {
                        invitedIdList.append(GroupMember(user: friendsUserList[index]))
                    }
                }
                activityInProgress?.setupGroup(invitedIdList)
                self.performSegueWithIdentifier("toMapViewSegue", sender: self)
            }
        }
        
    }
    

}
