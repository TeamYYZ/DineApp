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
    var heightCache = [CGFloat]()
    var groupChatId = "myChat"
    private lazy var sizingCell: SelfMessageCell = {
        return self.tableView.dequeueReusableCellWithIdentifier("SelfMessageCell") as! SelfMessageCell
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.separatorColor = UIColor.clearColor()
        self.view.backgroundColor = UIColor(red: 237, green: 237, blue: 237, alpha: 1)
        tableView.registerNib(UINib(nibName: "MemberMessageCell", bundle: nil), forCellReuseIdentifier: "MemberMessageCell")
        tableView.registerNib(UINib(nibName: "SelfMessageCell", bundle: nil), forCellReuseIdentifier: "SelfMessageCell")
        tableView.estimatedRowHeight = 98
        tableView.rowHeight = UITableViewAutomaticDimension
        replyItem.width = self.view.bounds.width - 80
        self.replyButton.action = #selector(ChatViewController.sendButtonOnClick)
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
                chat["avatarFile"] = file
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
        if self.messages.count == 0 {
            Log.info("count == 0??")
            let query = PFQuery(className: groupChatId)
            query.limit = 1000
            query.orderByAscending("createdAt")
            query.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error:NSError?) in
                if error == nil && objects!.count > 0 {
                    for object in objects!{
                        let message = Message(pfObject: object)
                        self.messages.append(message)
                    }
                    self.heightCache = [CGFloat](count: self.messages.count, repeatedValue: -1.0)
                    self.tableView.reloadData()
                    let indexPath = NSIndexPath(forRow: self.messages.count - 1, inSection: 0)
                    self.tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Bottom, animated: true)
                    
                } else{
                    print(error)
                }
            }
            return
        }
        
        if let offset = self.messages.last?.createdAt {
            let query = PFQuery(className: groupChatId)
            query.whereKey("createdAt", greaterThan: offset)
            query.orderByAscending("createdAt")
            query.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error:NSError?) in
                if error == nil && objects!.count > 0{
                    var updatedIndexPaths = [NSIndexPath]()
                    for object in objects! {
                        let message = Message(pfObject: object)
                        self.messages.append(message)
                        let indexPath = NSIndexPath(forRow: self.messages.count - 1, inSection: 0)
                        updatedIndexPaths.append(indexPath)
                        self.heightCache.append(-1.0)
                    }
                    

                    self.tableView.beginUpdates()
                    self.tableView.insertRowsAtIndexPaths(updatedIndexPaths, withRowAnimation: .Left)
                    self.tableView.endUpdates()
                    
                    UIView.animateWithDuration(0.8, animations: {
                        let indexPath = NSIndexPath(forRow: self.messages.count - 1, inSection: 0)
                        // MARK: must be .Middle. Otherwise, the scrollView behaves weird
                        self.tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Middle, animated: true)
                    })

                    
                } else {
                    Log.error(error?.localizedDescription)
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
    

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let index = indexPath.row
        if heightCache[index] == -1.0 {
            // MARK: margin and height of all views except UILabel
            let padding: CGFloat = 76.0
            let message = messages[index]
            if message.content == "" {
                message.content = " "
            }
            sizingCell.contentLabel.text = message.content
            sizingCell.contentLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
            sizingCell.bounds = CGRectMake(0.0, 0.0, CGRectGetWidth(self.tableView.bounds), CGRectGetHeight(sizingCell.bounds))
            sizingCell.setNeedsLayout()
            sizingCell.layoutIfNeeded()
            let textHeight = sizingCell.contentLabel.sizeThatFits(sizingCell.maxSize).height
            heightCache[index] = textHeight + padding
            return textHeight + padding
        } else {
            return heightCache[index]
        }
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
        Log.info("indexPath.row \(indexPath.row)")
        let message = self.messages[indexPath.row]
        if message.senderId == User.currentUser?.userId {
            let cell = tableView.dequeueReusableCellWithIdentifier("SelfMessageCell") as! SelfMessageCell
            cell.screenNameLabel.text = message.screenName

            if let content = message.content {
                cell.contentLabel.text = content
            } else {
                cell.contentLabel.text = " "
            }
            cell.avatarImageView.image = UIImage(named: "User")
            if let avatarPFFile = message.senderAvatarPFFile {
                avatarPFFile.getDataInBackgroundWithBlock({
                    (result, error) in
                    if error == nil{
                        cell.avatarImageView.image = UIImage(data: result!)
                    }else{
                        print(error)
                    }
                })
            }
            
            if cell.avatarImageView.userInteractionEnabled == false {
                cell.avatarImageView.userInteractionEnabled = true
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ChatViewController.profileTap(_:)))
                cell.avatarImageView.addGestureRecognizer(tapGesture)
                cell.avatarImageView.layer.cornerRadius = 10.0
            }
            
            let previousIndex = indexPath.row - 1
            let date = message.createdAt
//            let dateFormatter = NSDateFormatter()
//            dateFormatter.dateFormat = "hh:mm"
//            let dateString = dateFormatter.stringFromDate(date!)
            
//            if 0 <= previousIndex {
//                let previousDate = self.messages[previousIndex].createdAt
//                if date?.minutesFrom(previousDate!) < 1 {
//                    //print(date?.minutesFrom(previousDate!))
//                    cell.timeLabel.text = ""
//                    cell.timeLabelHeight.constant = 0.0
//                } else {
//                    cell.timeLabel.text = dateString
//                    cell.timeLabelHeight.constant = 21.0
//                    
//                }
//            } else {
//                cell.timeLabel.text = dateString
//                cell.timeLabelHeight.constant = 21.0
//                
//            }
//            cell.selectionStyle = UITableViewCellSelectionStyle.None
            return cell
            
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("MemberMessageCell") as! MemberMessageCell
            cell.screenNameLabel.text = message.screenName
            
            if let content = message.content {
                cell.contentLabel.text = content
            } else {
                cell.contentLabel.text = " "
            }
            
            cell.avatarImageView.image = UIImage(named: "User")
            if let avatarPFFile = message.senderAvatarPFFile {
                avatarPFFile.getDataInBackgroundWithBlock({
                    (result, error) in
                    if error == nil{
                        cell.avatarImageView.image = UIImage(data: result!)
                    }else{
                        print(error)
                    }
                })
            }
            if cell.avatarImageView.userInteractionEnabled == false {
                cell.avatarImageView.userInteractionEnabled = true
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ChatViewController.profileTap(_:)))
                cell.avatarImageView.addGestureRecognizer(tapGesture)
                cell.avatarImageView.layer.cornerRadius = 10.0
            }
            let previousIndex = indexPath.row - 1
            let date = message.createdAt
//            let dateFormatter = NSDateFormatter()
//            dateFormatter.dateFormat = "hh:mm"
//            let dateString = dateFormatter.stringFromDate(date!)
//            if 0 <= previousIndex {
//                let previousDate = self.messages[previousIndex].createdAt
//                if date?.minutesFrom(previousDate!) < 2 {
//                    cell.timeLabel.text = ""
//                    cell.timeLabelHeight.constant = 0.0
//                } else {
//                    cell.timeLabel.text = dateString
//                    cell.timeLabelHeight.constant = 21.0
//                }
//            } else {
//                cell.timeLabel.text = dateString
//                cell.timeLabelHeight.constant = 21.0
//            }
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            return cell
        }
    }
    
    func profileTap (sender: AnyObject) {
        
        let position: CGPoint =  sender.locationInView(self.tableView)
        let indexPath: NSIndexPath = self.tableView.indexPathForRowAtPoint(position)!
        performSegueWithIdentifier("toUserProfile", sender: indexPath)
        
    }
    
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
