//
//  SignupViewController.swift
//  Dine
//
//  Created by you wu on 3/12/16.
//  Copyright © 2016 YYZ. All rights reserved.
//

import UIKit

class EmailSignupViewController: SignUpViewController {

    

    @IBOutlet weak var emailField: YYZTextField!
    
    @IBOutlet weak var nextButton: YYZButton!
    
    @IBAction func cancelOnTap(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    @IBAction func nextOnTap(sender: AnyObject) {
        if emailField.isValidEmail() {
            emailField.rightViewMode = .Always
            self.performSegueWithIdentifier("signUpFinishEmailSegue", sender: nil)
            
        } else {
            print("invalidEmail")
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
        emailField.fieldType = .Email
        emailField.textChangedCB = validatedValue
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "signUpFinishEmailSegue" {
            if PFUser.currentUser() == nil{
                SignUpViewController.emailaddr = emailField.text
            }else{
                PFUser.currentUser()?.email = emailField.text
                
                
            }
        }
        
    }

}
