//
//  AddFriendViewController.swift
//  Dine
//
//  Created by Senyang Zhuang on 3/26/16.
//  Copyright © 2016 YYZ. All rights reserved.
//

import UIKit
import Parse

class AddFriendViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    var friends = [User]()
    var addStatus = [Bool]()
    
    var searchController: UISearchController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let cancelButton = UIBarButtonItem(
            title: "Cancel",
            style: .Plain,
            target: self,
            action: "cancelButtonOnClick"
        )
        self.navigationItem.leftBarButtonItem = cancelButton
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.estimatedRowHeight = 200
        
        
        
        // Adding a search bar
        searchController = UISearchController(searchResultsController: nil)
        tableView.tableHeaderView = searchController.searchBar
        searchController.dimsBackgroundDuringPresentation = false
        self.edgesForExtendedLayout = UIRectEdge.None
        
        // Customize the appearance of the search bar
        searchController.searchBar.placeholder = "Search new friends by Username"
        searchController.searchBar.autocapitalizationType = .None
        searchController.searchBar.autocorrectionType = .No
        searchController.searchBar.tintColor = UIColor(red: 100.0/255.0, green: 100.0/255.0, blue: 100.0/255.0, alpha: 1.0)
        searchController.searchBar.barTintColor = UIColor(red: 240.0/255.0, green: 240.0/255.0, blue: 240.0/255.0, alpha: 0.6)
        searchController.searchBar.delegate = self
        
        
    }
    

    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        if let text = searchBar.text{
            searchFriendsWithEmail(text)
        }
    }
    
    func searchFriendsWithEmail(text: String){
        friends.removeAll()
        addStatus.removeAll()
        let query = PFQuery(className:"_User")
        query.whereKey("username", equalTo: text)
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            
            if error == nil {
                if let objects = objects {
                    for object in objects {
                        let objectAsPFUser = object as! PFUser
                        let objectAsUser = User.init(pfUser: objectAsPFUser)
                        self.friends.append(objectAsUser)
                    }
                    self.addStatus = [Bool](count: self.friends.count, repeatedValue: false)
                    self.tableView.reloadData()

                    
                }
            } else {
                // Log details of the failure
                print("Error: \(error!) \(error!.userInfo)")
            }
        }

        
    }
    
    
    
    func cancelButtonOnClick(){
    
        self.dismissViewControllerAnimated(true, completion: nil)
    
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("NewFriendCell") as! SearchFriendCell
        let friend = friends[indexPath.row]
        let isSent = addStatus[indexPath.row]
        if let avatarImage = friend.avatarImage{
            cell.avatarImage.image = avatarImage
        }else{
            cell.avatarImage.image = UIImage(named: "User")
        }
        
        if let screenName = friend.screenName{
            cell.screenNameLabel.text = screenName
        } else {
            cell.screenNameLabel.text = "Unknown"
        }
        
        if let email = friend.username {
            cell.emailLabel.text = email
        } else {
            cell.emailLabel.text = "Unknown"
        }
        
        cell.addButton.removeTarget(self, action: "AddFriend:", forControlEvents: .TouchDown)
        if isSent {
            cell.addButton.disable()
        } else {
            cell.addButton.enable()
            cell.addButton.addTarget(self, action: "AddFriend:", forControlEvents: .TouchDown)
            cell.addButton.tag = indexPath.row
        }

        return cell
    }
    
    func AddFriend(sender: AnyObject){
        let button = sender as! YYZAcceptButton
        let index = button.tag
        let destinationUser = self.friends[index]
        let notification = UserNotification(type: .FriendRequest, content: "Wants to be your friend", senderId: User.currentUser!.userId!, receiverId: destinationUser.userId!, associatedId: nil, senderName: User.currentUser!.screenName!, senderAvatarPFFile: User.currentUser?.avatarImagePFFile)
        
        
        notification.saveToBackend({ () -> () in
            self.addStatus[index] = true
            button.disable()
            button.setTitle("Sent", forState: UIControlState.Disabled)
            print("success")
            }, failureHandler: { (error: NSError?) -> () in
                print("failure")
        })
        //Here should send a notification to ask for permission
        
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
