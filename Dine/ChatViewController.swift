//
//  ChatViewController.swift
//  Dine
//
//  Created by you wu on 3/14/16.
//  Copyright © 2016 YYZ. All rights reserved.
//

import UIKit
import ALTextInputBar

class ChatViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var messages = [Message]()
    var heightCache = [CGFloat]()
    let dateFormatter = NSDateFormatter()
    let groupChatClassName = "GroupChat"
    let textInputBar = ALTextInputBar()
    
    private lazy var sizingCell: SelfMessageCell = {
        return self.tableView.dequeueReusableCellWithIdentifier("SelfMessageCell") as! SelfMessageCell
    }()
    
    func setupTextInput() {
        let leftButton = UIButton(frame: CGRectMake(0, 0, 44, 44))
        let rightButton = UIButton(frame: CGRectMake(0, 0, 44, 44))
        
        leftButton.setImage(UIImage(named: "plus"), forState: UIControlState.Normal)
        leftButton.addTarget(self, action: #selector(ChatViewController.plusButtonOnClick), forControlEvents: .TouchDown)
        rightButton.setTitle("Send", forState: .Normal)
        rightButton.setTitle("Send", forState: .Disabled)
        rightButton.setTitleColor(UIColor.flatBlueColorDark(), forState: .Normal)
        rightButton.setTitleColor(UIColor.flatGrayColor(), forState: .Disabled)

        rightButton.addTarget(self, action: #selector(ChatViewController.sendButtonOnClick), forControlEvents: .TouchDown)
        
        textInputBar.horizontalPadding = 5
        textInputBar.showTextViewBorder = true
        textInputBar.leftView = leftButton
        textInputBar.rightView = rightButton
        textInputBar.frame = CGRectMake(0, view.frame.size.height - textInputBar.defaultHeight, view.frame.size.width, textInputBar.defaultHeight)
        textInputBar.backgroundColor = UIColor(white: 0.95, alpha: 1)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.separatorColor = UIColor.clearColor()
        self.view.backgroundColor = UIColor(red: 237, green: 237, blue: 237, alpha: 1)
        tableView.registerNib(UINib(nibName: "MemberMessageCell", bundle: nil), forCellReuseIdentifier: "MemberMessageCell")
        tableView.registerNib(UINib(nibName: "SelfMessageCell", bundle: nil), forCellReuseIdentifier: "SelfMessageCell")
        tableView.estimatedRowHeight = 98
        tableView.rowHeight = UITableViewAutomaticDimension
        setupTextInput()
        fetchData()
    }
    
    func plusButtonOnClick() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) {
            (action) in
        }
        
        let cameraAction = UIAlertAction(title: "Take Picture", style: .Default) {
            (action)in
            let vc = UIImagePickerController()
            vc.delegate = self
            vc.allowsEditing = true
            vc.sourceType = UIImagePickerControllerSourceType.Camera
            self.presentViewController(vc, animated: true, completion: nil)
        }
        
        let libraryAction = UIAlertAction(title: "Photo Library", style: .Default) {
            (action) in
            let vc = UIImagePickerController()
            vc.delegate = self
            vc.allowsEditing = true
            vc.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            self.presentViewController(vc, animated: true, completion: nil)
            
        }
        
        alertController.addAction(cameraAction)
        alertController.addAction(libraryAction)
        alertController.addAction(cancelAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    
    }
    
    
    
    func sendButtonOnClick() {
        if let currentActivity = Activity.current_activity {
            if let content = textInputBar.text {
                let senderId = User.currentUser?.userId
                let screenName = User.currentUser?.screenName
                let avatarPFFile = User.currentUser?.avatarImagePFFile
                
                let message = Message(activityId: currentActivity.activityId, senderId: senderId, screenName: screenName, content: content, avatarPFFile: avatarPFFile, mediaPFFile: nil, mediaType: nil)
                message.saveToBackend({
                    self.fetchData()
                    }, failureHandler: { (error: NSError?) in
                        Log.error(error?.localizedDescription)
                })
                
            }
        
        
        }
        
    }
    
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        let editedImage = info[UIImagePickerControllerEditedImage] as! UIImage
        let resizedImage = resize(editedImage, newSize: CGSize(width: 100, height: 100))
        dismissViewControllerAnimated(true, completion: {
            // MARK: send picture
            let senderId = User.currentUser?.userId
            let screenName = User.currentUser?.screenName
            let avatarPFFile = User.currentUser?.avatarImagePFFile
            let media = getPFFileFromImage(resizedImage)
            let message = Message(activityId: Activity.current_activity?.activityId, senderId: senderId, screenName: screenName, content: "MediaRes", avatarPFFile: avatarPFFile, mediaPFFile: media, mediaType: "Photo")
            message.saveToBackend({ 
                self.fetchData()
                }, failureHandler: { (error: NSError?) in
                    Log.error(error?.localizedDescription)
            })
        })
    }
    
    
    func fetchData(){
        if let currentActivity = Activity.current_activity {
            if self.messages.count == 0 {
                let query = PFQuery(className: groupChatClassName)
                query.whereKey("activityId", equalTo: currentActivity.activityId!)
                query.limit = 1000
                query.orderByAscending("createdAt")
                query.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error:NSError?) in
                    if error == nil && objects!.count > 0 {
                        for object in objects!{
                            let message = Message(pfObject: object)
                            let date = message.createdAt
                            let previousIndex = self.messages.count - 1
                            self.dateFormatter.dateFormat = "hh:mm"
                            let dateString = self.dateFormatter.stringFromDate(date!)
                            message.createdAtString = dateString
                            if 0 <= previousIndex {
                                let previousDate = self.messages[previousIndex].createdAt
                                if date?.minutesFrom(previousDate!) < 1 {
                                    message.isRecentMessage = true
                                    
                                }
                            }
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
                let query = PFQuery(className: groupChatClassName)
                query.whereKey("activityId", equalTo: currentActivity.activityId!)
                query.whereKey("createdAt", greaterThan: offset)
                query.orderByAscending("createdAt")
                query.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error:NSError?) in
                    if error == nil && objects!.count > 0 {
                        var updatedIndexPaths = [NSIndexPath]()
                        for object in objects! {
                            let message = Message(pfObject: object)
                            let date = message.createdAt
                            let previousIndex = self.messages.count - 1
                            self.dateFormatter.dateFormat = "hh:mm"
                            let dateString = self.dateFormatter.stringFromDate(date!)
                            message.createdAtString = dateString
                            if 0 <= previousIndex {
                                let previousDate = self.messages[previousIndex].createdAt
                                if date?.minutesFrom(previousDate!) < 1 {
                                    message.isRecentMessage = true
                                    
                                }
                            }
                            self.messages.append(message)
                            let indexPath = NSIndexPath(forRow: self.messages.count - 1, inSection: 0)
                            updatedIndexPaths.append(indexPath)
                            self.heightCache.append(-1.0)
                        }
                        
                        
                        self.tableView.beginUpdates()
                        self.tableView.insertRowsAtIndexPaths(updatedIndexPaths, withRowAnimation: .Bottom)
                        self.tableView.endUpdates()
                        
                        let indexPath = NSIndexPath(forRow: self.messages.count - 1, inSection: 0)
                        // MARK: must be .Middle. Otherwise, the scrollView behaves weird
                        self.tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Middle, animated: true)
                        
                        
                    } else {
                        Log.error(error?.localizedDescription)
                    }
                }
            }
        
        } else {
            Log.error("Current activity not found")
        }
        
    }
    
    
    
    // This is how we observe the keyboard position
    override var inputAccessoryView: UIView? {
        get {
            return textInputBar
        }
    }
    
    // This is also required
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let index = indexPath.row
        if heightCache[index] == -1.0 {

            // MARK: margin and height of all views except UILabel
            var padding: CGFloat = 76.0
            if messages[index].isRecentMessage {
                padding -= 21.0
            }
            
            let message = messages[index]
            
            if message.mediaType == "Photo" {
                heightCache[index] = 160 + padding - 14
                return heightCache[index]
            }
            
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
            return heightCache[index]
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
        let index = indexPath.row
        let message = self.messages[index]
        if message.senderId == User.currentUser?.userId {
            let cell = tableView.dequeueReusableCellWithIdentifier("SelfMessageCell") as! SelfMessageCell
            cell.screenNameLabel.text = message.screenName
            cell.indexInTable = index
            if let content = message.content {
                cell.contentLabel.text = content
            } else {
                cell.contentLabel.text = " "
            }
            
            if let media = message.media {
                if message.mediaType == "Photo" {
                    cell.photoView.hidden = false
                    media.getDataInBackgroundWithBlock({
                        (result, error) in
                        if error == nil{
                            if index == cell.indexInTable {
                                cell.photoView.image = UIImage(data: result!)
                            } else {
                                Log.info("image comes too late, do not set it to avatar")
                            }
                        } else {
                            print(error)
                        }
                    })
                }
                
                cell.contentLabel.hidden = true
            
            } else {
                cell.contentLabel.hidden = false
                cell.photoView.hidden = false
            }
            
            if let media = message.media {
                if message.mediaType == "Photo" {
                    cell.photoView.hidden = false
                    media.getDataInBackgroundWithBlock({
                        (result, error) in
                        if error == nil{
                            if index == cell.indexInTable {
                                cell.photoView.image = UIImage(data: result!)
                            } else {
                                Log.info("image comes too late, do not set it to avatar")
                            }
                        } else {
                            print(error)
                        }
                    })
                }
                
                cell.contentLabel.hidden = true
                
            } else {
                cell.contentLabel.hidden = false
                cell.photoView.hidden = false
            }
            
            
            if let avatarPFFile = message.senderAvatarPFFile {
                avatarPFFile.getDataInBackgroundWithBlock({
                    (result, error) in
                    if error == nil{
                        if index == cell.indexInTable {
                            cell.avatarImageView.image = UIImage(data: result!)
                        } else {
                            Log.info("image comes too late, do not set it to avatar")
                        }
                    } else {
                        print(error)
                    }
                })
            }
            
            if cell.avatarImageView.userInteractionEnabled == false {
                cell.avatarImageView.userInteractionEnabled = true
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ChatViewController.profileTap(_:)))
                cell.avatarImageView.addGestureRecognizer(tapGesture)
            }


            cell.timeLabel.text = message.createdAtString

            if message.isRecentMessage {
                cell.timeLabelHeight.constant = 0.0
            } else {
                cell.timeLabelHeight.constant = 21.0
            }
            cell.updateConstraints()
            cell.layoutIfNeeded()
            return cell
            
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("MemberMessageCell") as! MemberMessageCell
            cell.screenNameLabel.text = message.screenName
            cell.indexInTable = index
            if let content = message.content {
                cell.contentLabel.text = content
            } else {
                cell.contentLabel.text = " "
            }

            
            
            if let avatarPFFile = message.senderAvatarPFFile {
                avatarPFFile.getDataInBackgroundWithBlock({
                    (result, error) in
                    if error == nil{
                        if index == cell.indexInTable {
                            cell.avatarImageView.image = UIImage(data: result!)
                        } else {
                            Log.info("image comes too late, do not set it to avatar")
                        }
                    } else {
                        print(error)
                    }
                })
            }
            if cell.avatarImageView.userInteractionEnabled == false {
                cell.avatarImageView.userInteractionEnabled = true
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ChatViewController.profileTap(_:)))
                cell.avatarImageView.addGestureRecognizer(tapGesture)
            }
            


            cell.timeLabel.text = message.createdAtString

            if message.isRecentMessage {
                cell.timeLabelHeight.constant = 0.0
            } else {
                cell.timeLabelHeight.constant = 21.0
            }
            cell.updateConstraints()
            cell.layoutIfNeeded()
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
