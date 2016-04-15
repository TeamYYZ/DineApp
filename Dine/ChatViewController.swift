//
//  ChatViewController.swift
//  Dine
//
//  Created by you wu on 3/14/16.
//  Copyright © 2016 YYZ. All rights reserved.
//

import UIKit

class ChatViewController: UITableViewController {
    @IBOutlet weak var replyItem: UIBarButtonItem!
    @IBOutlet weak var replyButton: UIBarButtonItem!
    @IBOutlet var replyBar: UIToolbar!
    @IBOutlet weak var replyField: UITextField!
    var messages = [Message]()
    var groupChatId = "myChat"
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.separatorColor = UIColor.clearColor()
        self.view.backgroundColor = UIColor(red: 237, green: 237, blue: 237, alpha: 1)
        tableView.registerNib(UINib(nibName: "MemberMessageCell", bundle: nil), forCellReuseIdentifier: "MemberMessageCell")
        tableView.registerNib(UINib(nibName: "SelfMessageCell", bundle: nil), forCellReuseIdentifier: "SelfMessageCell")
        tableView.estimatedRowHeight = 200
        tableView.rowHeight = UITableViewAutomaticDimension
        replyItem.width = self.view.bounds.width - 80
        self.replyButton.action = "sendButtonOnClick"
        fetchData()
    }
    
    func sendButtonOnClick(){
        if let content = self.replyField.text{
            let senderId = User.currentUser?.userId
            //let file = User.currentUser?.avatarImagePFFile
            let screenName = User.currentUser?.screenName

            let message = Message(senderId: senderId!, screenName: screenName!, content: content)
            let chat = PFObject(className:  groupChatId)
            chat["content"] = message.content
            chat["senderId"] = message.senderId
            chat["screenName"] = message.screenName
            if let file = User.currentUser?.avatarImagePFFile{
                chat["file"] = file
            }
            self.replyField.text = nil
            chat.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) in
                if success == true && error == nil{
                    self.fetchData()
                }else{
                    print(error)
                }
            })
           
            
        }
        
    
    }
    
    func fetchData(){
        if self.messages.count == 0{
           let query = PFQuery(className: groupChatId)
            query.orderByAscending("createdAt")
            query.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error:NSError?) in
                if error == nil && objects!.count > 0{
                    for object in objects!{
                        let senderId = object["senderId"] as! String
                        let content = object["content"] as! String
                        let screenName = object["screenName"] as! String
                        let createdAt = object.createdAt! as NSDate
                        //let file = object["file"] as! PFFile
                        let message = Message(senderId: senderId, screenName: screenName, content: content, createdAt: createdAt)
                        if let file = object["file"] as? PFFile{
                           file.getDataInBackgroundWithBlock({
                                (result, error) in
                                if error == nil{
                                    message.senderAvatarImage = UIImage(data: result!)
                                    self.messages.append(message)

                                    self.tableView.reloadData()
                                }else{
                                   
                                    print(error)
                                }
                            })
                        }else{
                            self.messages.append(message)
                            self.tableView.reloadData()
                        
                        }
                        
                        
                    }
                    //self.tableView.reloadData()
                    let indexPath = NSIndexPath(forRow: self.messages.count - 1, inSection: 0)
                    self.tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Bottom, animated: true)

                }else{
                    print(error)
                }
            }
        }
        
        if let offset = self.messages.last?.createdAt{
            let query = PFQuery(className: groupChatId)
            query.whereKey("createdAt", greaterThan: offset)
            query.orderByAscending("createdAt")
            query.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error:NSError?) in
                if error == nil && objects!.count > 0{
                   // print(objects!.count)
                    for object in objects!{
                        let senderId = object["senderId"] as! String
                        let content = object["content"] as! String
                        let screenName = object["screenName"] as! String
                        //let file = object["file"] as! PFFile
                        let createdAt = object.createdAt! as NSDate
                        let message = Message(senderId: senderId, screenName: screenName, content: content, createdAt: createdAt)
                        if let file = object["file"] as? PFFile{
                            file.getDataInBackgroundWithBlock({
                                (result, error) in
                                if error == nil{
                                    message.senderAvatarImage = UIImage(data: result!)
                                    self.messages.append(message)
                                    self.tableView.reloadData()
                                }else{
                                    
                                    print(error)
                                }
                            })
                        }else{
                            self.messages.append(message)
                            
                            self.tableView.reloadData()
                        
                        }
                        
                        
                    }
                    //self.tableView.reloadData()
                    let indexPath = NSIndexPath(forRow: self.messages.count - 1, inSection: 0)
                    self.tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Bottom, animated: true)

                }else{
                    print(error)
                }
            }
        }
    }
    
    
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    override var inputAccessoryView: UIView{
        get{
            return self.replyBar
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.messages.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let message = self.messages[indexPath.row]
        if message.senderId == User.currentUser?.userId {
            let cell = tableView.dequeueReusableCellWithIdentifier("SelfMessageCell") as! SelfMessageCell
            cell.screenNameLabel.text = message.screenName
            cell.contentLabel.text = message.content
            if let image = message.senderAvatarImage{
                cell.avatarImageView.image = image
            }else{
                cell.avatarImageView.image = UIImage(named: "User")
            }
            
            if cell.avatarImageView.userInteractionEnabled == false {
                cell.avatarImageView.userInteractionEnabled = true
                let tapGesture = UITapGestureRecognizer(target: self, action: "profileTap:")
                cell.avatarImageView.addGestureRecognizer(tapGesture)
                cell.avatarImageView.layer.cornerRadius = 10.0
            }
            
            let previousIndex = indexPath.row - 1
            let date = message.createdAt
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "hh:mm"
            let dateString = dateFormatter.stringFromDate(date!)

            if 0 <= previousIndex {
                let previousDate = self.messages[previousIndex].createdAt
                if date?.minutesFrom(previousDate!) < 1 {
                    //print(date?.minutesFrom(previousDate!))
                    cell.timeLabel.text = ""
                    cell.timeLabelHeight.constant = 0.0
                } else {
                    cell.timeLabel.text = dateString
                    cell.timeLabelHeight.constant = 21.0
                    
                }
            } else {
                cell.timeLabel.text = dateString
                cell.timeLabelHeight.constant = 21.0
                
            }

            cell.selectionStyle = UITableViewCellSelectionStyle.None
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("MemberMessageCell") as! MemberMessageCell
            cell.screenNameLabel.text = message.screenName

            cell.contentLabel.text = message.content
            
            if let image = message.senderAvatarImage{
                
                cell.avatarImageView.image = image
                
            }else{
            
                cell.avatarImageView.image = UIImage(named: "User")
            }
            
            if cell.avatarImageView.userInteractionEnabled == false {
                cell.avatarImageView.userInteractionEnabled = true
                let tapGesture = UITapGestureRecognizer(target: self, action: "profileTap:")
                cell.avatarImageView.addGestureRecognizer(tapGesture)
                cell.avatarImageView.layer.cornerRadius = 10.0
            }
            
            //cell.avatarImageView.image = UIImage(named: "User")
            let previousIndex = indexPath.row - 1
            let date = message.createdAt
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "hh:mm"
            let dateString = dateFormatter.stringFromDate(date!)
            
            if 0 <= previousIndex {
                let previousDate = self.messages[previousIndex].createdAt
                if date?.minutesFrom(previousDate!) < 2 {
                    cell.timeLabel.text = ""
                    cell.timeLabelHeight.constant = 0.0
                } else {
                    cell.timeLabel.text = dateString
                    cell.timeLabelHeight.constant = 21.0

                }
            } else {
                cell.timeLabel.text = dateString
                cell.timeLabelHeight.constant = 21.0

            }
            
            cell.selectionStyle = UITableViewCellSelectionStyle.None

            return cell
        }
    }
    
    func profileTap (sender: AnyObject) {
        
        let position: CGPoint =  sender.locationInView(self.tableView)
        let indexPath: NSIndexPath = self.tableView.indexPathForRowAtPoint(position)!
        performSegueWithIdentifier("toUserProfile", sender: indexPath)
        
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
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "toUserProfile"{
            let indexPath = sender as! NSIndexPath
            let id = self.messages[indexPath.row].senderId
            let vc = segue.destinationViewController as! UserProfileViewController
            vc.uid = id
        
        }
    }
    

}
