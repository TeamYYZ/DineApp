//
//  profileEditingController.swift
//  Dine
//
//  Created by Senyang Zhuang on 4/6/16.
//  Copyright © 2016 YYZ. All rights reserved.
//

import UIKit

@objc protocol profileEdittingControllerDelegate {
    optional func profileEditting(profileEditting: profileEditingController, didUpdateScreenName updatedScreenName: String?)
    optional func profileEditting(profileEditting: profileEditingController, didUpdateUsername updatedUserName: String?)
   
}


class profileEditingController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var contentField: UITextField!
    
    let user = User.currentUser!
    
    var isScreenNameEditting = Bool()
    
    weak var delegate: profileEdittingControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.contentField.delegate = self
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: self, action: "cancelButtonOnClick")
        navigationItem.leftBarButtonItem = cancelButton
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Plain, target: self, action: "doneButtonOnClick")
        navigationItem.rightBarButtonItem = doneButton
        
        contentField.clearButtonMode = UITextFieldViewMode.WhileEditing
        
        if isScreenNameEditting{
            self.contentField.text = User.currentUser?.screenName!
        }else{
            self.contentField.text = User.currentUser?.username!
        }
        // Do any additional setup after loading the view.
    }
    
    func doneButtonOnClick(){
       
        let text = contentField.text
        
        if isScreenNameEditting{
            if text != ""{
                self.user.updateScreenName(text, withCompletion: { (success: Bool, error: NSError?) in
                    if success == true && error == nil{
                        self.delegate?.profileEditting!(self, didUpdateScreenName: text)
                        self.dismissViewControllerAnimated(true, completion: nil)
                    }else{
                        print(error)
                    }
              })
            }else{
                let alert = UIAlertView(title: "Message", message: "Sorry, you can not use an empty screen name", delegate: self, cancelButtonTitle: "OK")
                alert.show()
            }
        }else{
            self.user.updateUsername(text, withCompletion: { (success: Bool, error: NSError?) in
                if success == true && error == nil{
                    self.delegate?.profileEditting!(self, didUpdateUsername: text)
                    self.dismissViewControllerAnimated(true, completion: nil)
                }else{
                    print(error)
                }
            })
        
        }
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func cancelButtonOnClick(){
        self.dismissViewControllerAnimated(true, completion: nil)
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
