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
    
    var isInvitationVC = false
    
    
    var checked = [String: User]()
    
    @IBOutlet weak var inviteButton: UIBarButtonItem!
    
    
    
    //var friendsIdList = User.currentUser?.friendList
    var friendsIdList = [String]()
    var friendsUserList = [User]()
    var friendsUserDict = [String : [User]]()
    var friendScreenNameInitial = [String]()
    let friendScreenNameInitialTable =  ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
    
    
    func refreshControlAction(refreshControl: UIRefreshControl) {
        fetchFriendList()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
        if isInvitationVC {
            inviteButton.enabled = false
            inviteButton.image = nil
            inviteButton.title = "Invite"
            inviteButton.tag = 0
        }else{
            
            inviteButton.enabled = true
            inviteButton.tag = 1
        }
        
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 120
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(FriendsViewController.refreshControlAction(_:)), forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl!, atIndex: 0)
        
        fetchFriendList()
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
                self.generateFriendDic()
                self.checked = [String: User]()
                self.refreshControl?.endRefreshing()
            }
        })
    }
    
    func generateFriendDic(){
        let query = PFUser.query()
        query?.whereKey("objectId", containedIn: friendsIdList)
        query?.findObjectsInBackgroundWithBlock({ (friendObjects:[PFObject]?, error: NSError?) -> Void in
            if error == nil && friendObjects != nil {
                self.friendsUserList = [User]()
                self.friendsUserDict = [String : [User]]()
                for friendObject in friendObjects! {
                    let friend = User(pfUser: friendObject as! PFUser)
                    Log.info(friend.username)
                    self.friendsUserList.append(friend)
                    let username = friend.screenName
                    let usernameKey = username!.substringToIndex(username!.startIndex.advancedBy(1)).uppercaseString
                    
                    if var usernameValues = self.friendsUserDict[usernameKey] {
                        usernameValues.append(friend)
                        self.friendsUserDict[usernameKey] = usernameValues
                    } else {
                        self.friendsUserDict[usernameKey] = [friend]
                        self.friendScreenNameInitial.append(usernameKey)
                        self.friendScreenNameInitial.sortInPlace()
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
        return self.friendScreenNameInitialTable
    }
    
    override func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
        guard let index = self.friendScreenNameInitial.indexOf(title) else {
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
        let screenNameInitial = self.friendScreenNameInitial[indexPath.section]
        let userListUnderGivenInitial = self.friendsUserDict[screenNameInitial]
        let user = userListUnderGivenInitial![indexPath.row]
        
        if isInvitationVC == true {
            if let _ = checked[user.userId!] {
                self.checked[user.userId!] = nil
            } else {
                self.checked[user.userId!] = user
            }
            
            if checked.count > 0 {
                inviteButton.enabled = true
            } else {
                inviteButton.enabled = false
            }
            
            tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            
        } else {
            performSegueWithIdentifier("toUserProfile", sender: indexPath)
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return friendsUserDict.count
    }
    
    override func  tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return friendScreenNameInitial[section]
    }
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let usernameKey = self.friendScreenNameInitial[section]
        if let usernameValues = self.friendsUserDict[usernameKey] {
            return usernameValues.count
        }
        return 0
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("friendCell", forIndexPath: indexPath) as! FriendCell
        let usernameKey = self.friendScreenNameInitial[indexPath.section]
        if let usernameValues = self.friendsUserDict[usernameKey] {
            let index = indexPath.row
            let user = usernameValues[index]

            if isInvitationVC == true {
                if let _ = checked[user.userId!] {
                    
                    cell.accessoryType = .Checkmark
                    cell.inviteLabel.text = "Invited"
                    cell.inviteLabel.textColor = UIColor.flatGrayColor()
                } else {
                    
                    cell.accessoryType = .None
                    cell.inviteLabel.text = "Invite"
                    cell.inviteLabel.textColor = UIColor.flatSkyBlueColor()
                }
                
            } else {
                cell.inviteLabel.hidden = true
            }
            
            
            
            if let file = user.avatarImagePFFile {
                file.getDataInBackgroundWithBlock({
                    (result, error) in
                    cell.avatarImage.image = UIImage(data: result!)
                })
            }else{
                cell.avatarImage.image = UIImage(named: "User")
            }
            
            cell.userNameLabel.text = user.screenName
            
            
            if cell.avatarImage.userInteractionEnabled == false {
                cell.avatarImage.userInteractionEnabled = true
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(FriendsViewController.profileTap(_:)))
                cell.avatarImage.addGestureRecognizer(tapGesture)
                cell.avatarImage.layer.cornerRadius = 10.0
            }
            
            
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        
        return cell
    }
    
    func profileTap (sender: AnyObject) {
        
        let position: CGPoint =  sender.locationInView(self.tableView)
        let indexPath: NSIndexPath = self.tableView.indexPathForRowAtPoint(position)!
        performSegueWithIdentifier("toUserProfile", sender: indexPath)
        
    }
    
    override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        let headerView = view as! UITableViewHeaderFooterView
        headerView.textLabel?.textColor = UIColor.orangeColor()
        headerView.textLabel?.font = UIFont(name: "Avenir", size: 14.0)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toUserProfile"{
            let indexPath = sender as! NSIndexPath
            let vc = segue.destinationViewController as! UserProfileViewController
            let section = indexPath.section
            let row = indexPath.row
            let title = self.friendScreenNameInitial[section]
            vc.uid = self.friendsUserDict[title]![row].userId
        }
        else {
            if let button = sender as? UIBarButtonItem {
                if button.tag == 0 {
                    var invitedIdList = [GroupMember]()
                    
                    for (_, user) in checked {
                        invitedIdList.append(GroupMember(user: user))
                        Log.info(user.username)
                    }
                    
                    activityInProgress?.setupGroup(invitedIdList)
                    self.performSegueWithIdentifier("toMapViewSegue", sender: self)
                }
            }
        }
        
    }
    
    
}
