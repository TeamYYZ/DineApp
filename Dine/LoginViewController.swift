//
//  LoginViewController.swift
//  Dine
//
//  Created by you wu on 3/12/16.
//  Copyright © 2016 YYZ. All rights reserved.
//

import UIKit
import Parse
import ParseFacebookUtilsV4
import FBSDKCoreKit
import FBSDKLoginKit

class LoginViewController: UIViewController{
    let gradientLayer = CAGradientLayer()
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var containerView: UIView!
    
    
    @IBOutlet weak var appTitleLabel: UILabel!
    @IBOutlet weak var usernameField: YYZTextField!
    @IBOutlet weak var passwordField: YYZTextField!
    @IBOutlet weak var createNewAccountLabel: UIButton!
    @IBOutlet weak var signInButton: YYZButton!
    @IBOutlet weak var signUpButton: YYZButton!

    @IBOutlet weak var orLabel: UILabel!
    @IBOutlet weak var seperatorViewLeft: UIView!
    
    @IBOutlet weak var seperatorViewRight: UIView!
    
    @IBOutlet weak var fbIcon: UIImageView!
    
    
    
    @IBAction func hideKeyboardTap(sender: AnyObject) {
        self.view.endEditing(true)
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)
        

    }
    
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        gradientLayer.frame = self.view.bounds
        gradientLayer.zPosition = -1
        let color1 = ColorTheme.sharedInstance.loginGradientFisrtColor.CGColor as CGColorRef
        let color2 = ColorTheme.sharedInstance.loginGradientSecondColor.CGColor as CGColorRef
        gradientLayer.colors = [color1, color2]
        gradientLayer.locations = [0.0, 1.0]
        self.view.layer.addSublayer(gradientLayer)

        appTitleLabel.textColor = ColorTheme.sharedInstance.loginTextColor
        createNewAccountLabel.tintColor = ColorTheme.sharedInstance.loginTextColor
        seperatorViewLeft.backgroundColor = ColorTheme.sharedInstance.loginOptianLabelColor
        seperatorViewRight.backgroundColor = ColorTheme.sharedInstance.loginOptianLabelColor
        orLabel.textColor = ColorTheme.sharedInstance.loginOptianLabelColor
        
        fbIcon.image?.imageWithRenderingMode(.AlwaysTemplate)
        fbIcon.tintColor = ColorTheme.sharedInstance.loginTextColor
        createNewAccountLabel.addTarget(self, action: "LoginWithFacebook", forControlEvents: .TouchDown)
            
        
        // Do any additional setup after loading the view.
    }
    
    
    func keyboardWillShow(notif: NSNotification) {
        let userInfo = notif.userInfo
        let keyBoardSize: CGSize = (userInfo![UIKeyboardFrameBeginUserInfoKey]?.CGRectValue.size)!
        var visibleRect: CGRect = self.containerView.frame
        visibleRect.size.height -= keyBoardSize.height
        var lastElementOrigin: CGPoint = signInButton.frame.origin
        let lastElementHeight: CGFloat = signInButton.frame.size.height
        lastElementOrigin.y += lastElementHeight
        
        if (!CGRectContainsPoint(visibleRect, lastElementOrigin)){
            print("Not in visibleRect")
            let scrollPoint: CGPoint = CGPointMake(0.0, lastElementOrigin.y - visibleRect.size.height + 12 /* margin to bottom */)
            scrollView.setContentOffset(scrollPoint, animated: true)
        }
        
        print("self.view.frame after keyboard shown\(self.view.frame)")
        print("didShow")
    
    }
    
    func LoginWithFacebook() {
        print("Trying to login with FB")
        let permissions = ["public_profile"]
        PFFacebookUtils.logInInBackgroundWithReadPermissions(permissions) {
            (user: PFUser?, error: NSError?) -> Void in
            if let user = user {
                if user.isNew {
                    print("User signed up and logged in through Facebook!")
                    print(user)
                    self.performSegueWithIdentifier("signupSegue", sender: self)
                } else {
                    User.currentUser = User(pfUser: user)
                    print("User logged in through Facebook!")
                    self.performSegueWithIdentifier("loginSegue", sender: self)
                }
            } else {
                print("Uh oh. The user cancelled the Facebook login.")
            }
        }
    
    }
    
    func keyboardWillHide(notif: NSNotification) {
        //print("didHide")
        let scrollPoint: CGPoint = CGPointMake(0.0, 0.0)
        scrollView.setContentOffset(scrollPoint, animated: true)

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onLogin(sender: AnyObject) {
        // need to validate input first
        ParseAPI.signIn(usernameField.text!, password: passwordField.text!, successCallback: { () -> () in
            //print("Login Successfully")
            self.performSegueWithIdentifier("loginSegue", sender: sender)

            }) { (error: NSError?) -> () in
            print(error?.localizedDescription)
                let alertController = UIAlertController(title: "Please try again...", message: error?.localizedDescription, preferredStyle: .Alert)
                let tryAgainAlert = UIAlertAction(title: "Try Again", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                    self.passwordField.text = ""
                })
                alertController.addAction(tryAgainAlert)
                self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    @IBAction func unwindToLogin(sender: UIStoryboardSegue) {
        
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
    }


}
