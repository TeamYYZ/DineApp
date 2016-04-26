//
//  UserProfileViewController.swift
//  Dine
//
//  Created by Senyang Zhuang on 4/14/16.
//  Copyright © 2016 YYZ. All rights reserved.
//

import UIKit

@objc protocol UserProfileViewControllerDelegate{

    optional func UserProfile(userprofile: UserProfileViewController, didAcceptRequest withNotificationIndex: Int)
            
    
}

class UserProfileViewController: UITableViewController {
    
    @IBOutlet weak var headerCell: UITableViewCell!
    
    @IBOutlet weak var descriptionCell: UITableViewCell!
    
    @IBOutlet weak var addButtonCell: UITableViewCell!

    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var screenNameLabel: UILabel!
    
    @IBOutlet weak var genderImageView: UIImageView!
    
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var addButton: YYZAcceptButton!
    
    var uid : String?
    
    var user : User?
    
    var isFriend = true
    
    var isAcceptButton = false
    
    var notificationIndex = Int()
    
    weak var delegate: UserProfileViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addButtonCell.selectionStyle = UITableViewCellSelectionStyle.None
        headerCell.selectionStyle = UITableViewCellSelectionStyle.None
        descriptionCell.selectionStyle = UITableViewCellSelectionStyle.None
        addButtonCell.backgroundColor = self.view.backgroundColor
        self.tableView.separatorColor = UIColor.clearColor()
        
        // FIXME: Senyang's bad move
        let line: UIImageView = UIImageView(frame: CGRectMake(20, 115, 280, 1))
        
        //line.layer.borderWidth = 0.1
        line.backgroundColor = self.view.backgroundColor
        self.view.addSubview(line)
        
        if isAcceptButton == true{
            self.addButton.setTitle("Accept", forState: .Normal)
        }
        
        addButton.addTarget(self, action: #selector(UserProfileViewController.addButtonOnTap(_:)), forControlEvents: .TouchDown)

       let query = PFUser.query()
        query?.getObjectInBackgroundWithId(self.uid!, block: { (object: PFObject?, error: NSError?) in
            if object != nil && error == nil{
                let pfUser = object as! PFUser
                self.user = User(pfUser: pfUser)
                let id = self.user?.userId
                print(User.currentUser?.username)
                print(User.currentUser?.friendList)
                if  let list = User.currentUser?.friendList{
                    var count = 0
                    for fid in list{
                        if fid == id{
                            break
                        }
                        count += 1
                    }
                    if count == list.capacity{
                        self.isFriend = false
                    }
                    self.loadData()
                }else{
                    self.isFriend = false
                    self.loadData()
                }
            }else{
                print(error)
            }
        })
    }
    
    func addButtonOnTap(sender: AnyObject){

        self.delegate?.UserProfile!(self, didAcceptRequest: self.notificationIndex)
        //self.dismissViewControllerAnimated(true, completion: nil)
        self.navigationController?.popViewControllerAnimated(true)

    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadData(){
        if let file = user?.pfUser!["avatar"]{
            file.getDataInBackgroundWithBlock({ (result, error) in
                if result != nil && error == nil{
                   self.profileImageView.image = UIImage(data: result!)
                }
            })
        } else {
            self.profileImageView.image = UIImage(named: "User")
        }
        self.profileImageView.layer.cornerRadius = 8.0
        self.profileImageView.layer.masksToBounds = true
        
        if self.profileImageView.userInteractionEnabled == false {
            self.profileImageView.userInteractionEnabled = true
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(UserProfileViewController.profileImageOnTap))
            self.profileImageView.addGestureRecognizer(tapGesture)
        }
        

        
        self.screenNameLabel.text = user?.screenName!
        
        self.usernameLabel.text = user?.username!
        
        if let description = user!.profileDescription{
            self.descriptionLabel.text = description
        }
        
        self.title = user?.screenName!
        self.tableView.reloadData()

    }
    
    func profileImageOnTap(){
    
        self.performSegueWithIdentifier("toDetailProfileImage", sender: self)
    
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections

        if self.isFriend == true {
            return 1
        } else {
            return 2
        }

    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 0 {
            return 2
        } else {
            return 1
        }
    }
    
   
    
    

    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }
    */

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
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "toDetailProfileImage"{
            let vc = segue.destinationViewController as! DetailProfileViewController
            vc.user = self.user
        }
    }
    
}