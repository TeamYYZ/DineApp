//
//  SignUpNameViewController.swift
//  Dine
//
//  Created by YiHuang on 3/19/16.
//  Copyright © 2016 YYZ. All rights reserved.
//

import UIKit

class SignUpNameViewController: SignUpViewController {

    @IBOutlet weak var yourNameField: YYZTextField!
    
    
    @IBOutlet weak var nextButton: YYZButton!
    
    @IBAction func submitOnTap(sender: AnyObject) {
        if PFUser.currentUser() == nil{
        ParseAPI.signUp(SignUpViewController.emailaddr!, password: SignUpViewController.password!, screenName: yourNameField.text!, successCallback: { () -> () in
            NSNotificationCenter.defaultCenter().postNotificationName("userDidLoginNotification", object: nil)

            
            }) { (error: NSError?) -> () in
                print("Sign Up faliure")
            }
        }else{
            PFUser.currentUser()?.username = yourNameField.text!
            NSNotificationCenter.defaultCenter().postNotificationName("userDidLoginNotification", object: nil)
        }
    }
    
    
    func validatedValue(success: Bool) {
        if success {
            nextButton.enabled = true
        } else {
            nextButton.enabled = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nextButton.enabled = false
        yourNameField.fieldType = .Name
        yourNameField.textChangedCB = validatedValue
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
