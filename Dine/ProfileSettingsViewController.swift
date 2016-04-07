//
//  ProfileSettingsViewController.swift
//  Dine
//
//  Created by Senyang Zhuang on 4/6/16.
//  Copyright © 2016 YYZ. All rights reserved.
//

import UIKit

class ProfileSettingsViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, profileEdittingControllerDelegate, DescriptionEditViewControllerDelegate {


    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var screenNameLabel: UILabel!
    
    @IBOutlet weak var emailAddressLabel: UILabel!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    let user = User.currentUser!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        loadData()
        
    }
    
    func loadData(){
        
        if let file = user.pfUser!["avatar"]{
            file.getDataInBackgroundWithBlock({
                (result, error) in
                self.profileImageView.image = UIImage(data: result!)
            })
        }else{
            self.profileImageView.image = UIImage(named: "User")
        }
        
        self.profileImageView.layer.cornerRadius = 8.0
        
        self.screenNameLabel.text = user.screenName!
        
        self.emailAddressLabel.text = user.username!
        
        if let description = user.profileDescription{
            self.descriptionLabel.text = description
        }
        
        self.title = "My Profile"
       
    
        
    
        
    
    }
    
    func profileEditting(profileEditting: profileEditingController, didUpdateScreenName updatedScreenName: String?){

        self.screenNameLabel.text = updatedScreenName
    
    }
    
    func profileEditting(profileEditting: profileEditingController, didUpdateUsername updatedUserName: String?) {
        self.emailAddressLabel.text = updatedUserName
    }
    
    func descriptionEditting(descriptionEditting: DescriptionEditViewController, didUpdateDescription updatedDescription: String?) {
        self.descriptionLabel.text = updatedDescription
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let row = indexPath.row
        if row == 0 {
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
    }
    
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
 
        let editedImage = info[UIImagePickerControllerEditedImage] as! UIImage
        let resizedImage = resize(editedImage, newSize: CGSize(width: 100, height: 100))
        dismissViewControllerAnimated(true, completion: {
            self.user.updateProfilePhoto(resizedImage, withCompletion: { (success: Bool, error: NSError?) -> Void in
                if success {
                    self.loadData()
                } else {
                    print(error)
                }
            })
        })
    }
    
    
    func resize(image: UIImage, newSize: CGSize) -> UIImage {
        let resizeImageView = UIImageView(frame: CGRectMake(0, 0, newSize.width, newSize.height))
        resizeImageView.contentMode = UIViewContentMode.ScaleAspectFill
        resizeImageView.image = image
        
        UIGraphicsBeginImageContext(resizeImageView.frame.size)
        resizeImageView.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

     //MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
      return 4
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavigationBarItem()
        
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
        if segue.identifier == "screenNameEditSegue"{
            let vc = segue.destinationViewController as! UINavigationController
            let evc = vc.topViewController as! profileEditingController
            evc.delegate = self
            evc.isScreenNameEditting = true
    
            
        }else if segue.identifier == "usernameEditSegue"{
            let vc = segue.destinationViewController as! UINavigationController
            let evc = vc.topViewController as! profileEditingController
            evc.isScreenNameEditting = false
            evc.delegate = self
       
        }else if segue.identifier == "descriptionEditSegue"{
        
            let vc = segue.destinationViewController as! UINavigationController
            let evc = vc.topViewController as! DescriptionEditViewController
            evc.delegate = self
            
            
        
        }
        
    }
    

}
