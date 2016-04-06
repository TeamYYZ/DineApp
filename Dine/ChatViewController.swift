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
            //chat["file"] = message.senderAvatarPFFile
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
           print(groupChatId)
           let query = PFQuery(className: groupChatId)
            query.orderByAscending("createdAt")
            query.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error:NSError?) in
                print(error)
                print(objects!.count)
                if error == nil && objects!.count > 0{
                    print(objects!.count)
                    for object in objects!{
                        let senderId = object["senderId"] as! String
                        let content = object["content"] as! String
                        let screenName = object["screenName"] as! String
                        //                        let file = object["file"] as! PFFile
                        let createdAt = object.createdAt! as NSDate
                        let message = Message(senderId: senderId, screenName: screenName, content: content, createdAt: createdAt)
                        self.messages.append(message)

                    }
                    self.tableView.reloadData()
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
                    print(objects!.count)
                    for object in objects!{
                        let senderId = object["senderId"] as! String
                        let content = object["content"] as! String
                        let screenName = object["screenName"] as! String
//                        let file = object["file"] as! PFFile
                        let createdAt = object.createdAt! as NSDate
                        let message = Message(senderId: senderId, screenName: screenName, content: content, createdAt: createdAt)
                        self.messages.append(message)

                    }
                    self.tableView.reloadData()
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
           message.senderAvatarPFFile?.getDataInBackgroundWithBlock({
                (result, error) in
            if error == nil{
                cell.avatarImageView.image = UIImage(data: result!)
            }else{
                print(error)
            }})
        cell.contentLabel.text = message.content
        cell.avatarImageView.image = UIImage(named: "User")
        let date = message.createdAt
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "hh:mm"
        let dateString = dateFormatter.stringFromDate(date!)
        cell.timeLabel.text = dateString
            cell.selectionStyle = UITableViewCellSelectionStyle.None
        return cell
        }else {
            let cell = tableView.dequeueReusableCellWithIdentifier("MemberMessageCell") as! MemberMessageCell
            cell.screenNameLabel.text = message.screenName
            message.senderAvatarPFFile?.getDataInBackgroundWithBlock({
                (result, error) in
                if error == nil{
                    cell.avatarImageView.image = UIImage(data: result!)
                }else{
                    print(error)
                }})
            cell.contentLabel.text = message.content
             cell.avatarImageView.image = UIImage(named: "User")
            let date = message.createdAt
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "hh:mm"
            let dateString = dateFormatter.stringFromDate(date!)
            cell.timeLabel.text = dateString
            cell.selectionStyle = UITableViewCellSelectionStyle.None

            return cell
        }
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
