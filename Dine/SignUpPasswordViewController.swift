//
//  SignUpPasswordViewController.swift
//  Dine
//
//  Created by YiHuang on 3/19/16.
//  Copyright © 2016 YYZ. All rights reserved.
//

import UIKit

class SignUpPasswordViewController: SignUpViewController {

    
    @IBOutlet weak var passwordField: YYZTextField!
    
    @IBOutlet weak var nextButton: YYZButton!
    
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
        passwordField.fieldType = .Password
        passwordField.textChangedCB = validatedValue
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "signUpFinishPasswordSegue" {
            if PFUser.currentUser() == nil{
                SignUpViewController.password = passwordField.text
            }else{
                PFUser.currentUser()?.password = passwordField.text
            }
        }
        
    }

}
