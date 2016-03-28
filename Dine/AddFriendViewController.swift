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
    
    var searchController: UISearchController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var cancelButton = UIBarButtonItem(
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
        

        
        let query = PFQuery(className:"_User")
        query.whereKey("username", equalTo: text)
        print(text)
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            
            if error == nil {
                print(objects!.count)
                if let objects = objects {
                    for object in objects {
                        let objectAsPFUser = object as! PFUser
                        let objectAsUser = User.init(pfUser: objectAsPFUser)
                        self.friends.append(objectAsUser)
                        self.tableView.reloadData()
                    }
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
        if let avatarImage = friend.avatarImage{
            cell.avatarImage.image = avatarImage
        }else{
            cell.avatarImage.image = UIImage(named: "User")
        }
        
        if let username = friend.username{
            cell.userName.text = username
        }
        
        cell.addButton.removeTarget(self, action: "AddFriend:", forControlEvents: .TouchDown)
        cell.addButton.addTarget(self, action: "AddFriend:", forControlEvents: .TouchDown)
        cell.addButton.tag = indexPath.row
        return cell
    }
    
    func AddFriend(sender: AnyObject){
        let cell = sender as! UIButton
        let destinationUser = self.friends[cell.tag]
        let notification = UserNotification(type: .FriendRequest, content: "Wants to be your friend", senderId: User.currentUser!.userId!, receiverId: destinationUser.userId!, associatedId: nil, senderName: User.currentUser!.screenName!, senderAvatarPFFile: User.currentUser?.avatarImagePFFile)
        
        
        notification.saveToBackend({ (ret: UserNotification) -> () in
            print(ret.receiverId)
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
