//
//  SignupViewController.swift
//  Dine
//
//  Created by you wu on 3/12/16.
//  Copyright © 2016 YYZ. All rights reserved.
//

import UIKit

class EmailSignupViewController: SignUpViewController {

    
    @IBOutlet weak var mobileField: YYZTextField!

    @IBOutlet weak var emailField: YYZTextField!
    
    
    @IBOutlet weak var vericodeField: YYZTextField!
    
    @IBOutlet weak var nextButton: YYZButton!
    
    @IBOutlet weak var vericodeSendButton: YYZButton!
    
    var canSendVericode = true
    var canSendVericodeCount = 60
    var vericodeLimitTimer: NSTimer?
    
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
    
    func validateMobile(success: Bool) {
        if success && canSendVericode {
            vericodeSendButton.enabled = true
        } else {
            vericodeSendButton.enabled = false
        }
    }
    
    @IBAction func sendVericodeTap(sender: AnyObject) {
        guard var mobileNumber = mobileField.text else {return}
        let stringArray = mobileNumber.componentsSeparatedByCharactersInSet(
            NSCharacterSet.decimalDigitCharacterSet().invertedSet)
        mobileNumber = "1" + stringArray.joinWithSeparator("")
        
        ParseAPI.sendVericode(mobileNumber, successHandler: { (vericode) in
            Log.info("Got vericode: \(vericode)")
            self.vericodeField.vericode = vericode
        }) { (error: NSError?) in
                Log.error(error.debugDescription)
        }
        vericodeSendButton.enabled = false
        canSendVericode = false
        canSendVericodeCount = 60
        vericodeSendButton.titleLabel?.text = "60s"
        vericodeLimitTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(self.vericodeLimitTimerFire), userInfo: nil, repeats: true)
        
    }
    
    func vericodeLimitTimerFire() {
        canSendVericodeCount -= 1
        vericodeSendButton.titleLabel?.text = "\(canSendVericodeCount)s"
        if canSendVericodeCount == 0 {
            canSendVericode = true
            vericodeSendButton.enabled = true
            if let timer = self.vericodeLimitTimer where timer.valid {
                self.vericodeLimitTimer?.invalidate()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nextButton.enabled = false
        vericodeSendButton.enabled = false
        mobileField.fieldType = .Mobile
        mobileField.delegate = mobileField
        mobileField.textChangedCB = validateMobile
        vericodeField.fieldType = .Vericode
        vericodeField.textChangedCB = validatedValue
        emailField.fieldType = .Email
        
        
        
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
                let myUser = PFUser.currentUser()
                myUser?.username = emailField.text
                myUser?.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) in
                    if error == nil{
                        print("Yes")
                    }else{
                        print(error)
                    }
                 })
                
            }
        }
        
    }

}
