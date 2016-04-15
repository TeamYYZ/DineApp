//
//  DescriptionEditViewController.swift
//  Dine
//
//  Created by Senyang Zhuang on 4/6/16.
//  Copyright © 2016 YYZ. All rights reserved.
//

import UIKit


@objc protocol DescriptionEditViewControllerDelegate {
    optional func descriptionEditting(descriptionEditting: DescriptionEditViewController, didUpdateDescription updatedDescription: String?)
    
}

class DescriptionEditViewController: UITableViewController, UITextViewDelegate{
    
    @IBOutlet weak var contentTextView: UITextView!

    @IBOutlet weak var countDownLabel: UILabel!
    
    weak var delegate: DescriptionEditViewControllerDelegate?
    
    let user = User.currentUser!
    
    var  placeholderLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.contentTextView.delegate = self
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(DescriptionEditViewController.cancelButtonOnClick))
        navigationItem.leftBarButtonItem = cancelButton
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(DescriptionEditViewController.doneButtonOnClick))
        navigationItem.rightBarButtonItem = doneButton
        self.contentTextView.text = user.profileDescription
       
        placeholderLabel.text = "Let's Dine"
        placeholderLabel.font = UIFont.italicSystemFontOfSize(contentTextView.font!.pointSize)
        placeholderLabel.sizeToFit()
        contentTextView.addSubview(placeholderLabel)
        placeholderLabel.frame.origin = CGPointMake(5, contentTextView.font!.pointSize / 2)
        placeholderLabel.textColor = UIColor(white: 0, alpha: 0.3)
        placeholderLabel.hidden = !contentTextView.text.isEmpty
        
        if !self.contentTextView.text.isEmpty{
            let textLength = contentTextView.text.characters.count
            let leftChar = String(30 - textLength)
            self.countDownLabel.text = leftChar
        }
        
        
    }
    
    
    func textViewDidChange(textView: UITextView) {
        placeholderLabel.hidden = !textView.text.isEmpty

        if !textView.text.isEmpty{
            let textLength = textView.text.characters.count
            let leftChar = String(30 - textLength)
            self.countDownLabel.text = leftChar
            if leftChar == "0"{
                
            }
        }
        
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {

        if self.countDownLabel.text == "0" && range.length <= 0{
            return false
        }
        else{
            return true
        }
        
    }
    
    
    
    
    
   
    

    
    
    
    func cancelButtonOnClick(){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func doneButtonOnClick(){
        let text = self.contentTextView.text
        self.user.updateDescription(text, withCompletion: { (success: Bool, error: NSError?) in
            if success == true && error == nil{
                self.delegate?.descriptionEditting!(self, didUpdateDescription: text)
                self.dismissViewControllerAnimated(true, completion: nil)
            }else{
                print(error)
            }
        })
    
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
        return 1
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
