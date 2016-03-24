//
//  LoginViewController.swift
//  Dine
//
//  Created by you wu on 3/12/16.
//  Copyright © 2016 YYZ. All rights reserved.
//

import UIKit
import Parse

class LoginViewController: UIViewController {
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
//        ParseAPI.createActivity(NSDate(), yelpBusinessId: "test", overview: "test", location: CLLocationCoordinate2D(), restaurant: "test", successHandler: {(success: Bool, PFActivity: PFObject?) -> () in
//                print("success")
//            
//            
//            }, failureHandler: {()->() in
//                print("success")
//        
//        
//        
//        
//        })
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

            
        
        // Do any additional setup after loading the view.
    }
    
    
    func keyboardWillShow(notif: NSNotification) {
        let userInfo = notif.userInfo
        let keyBoardSize: CGSize = (userInfo![UIKeyboardFrameBeginUserInfoKey]?.CGRectValue.size)!
        var visibleRect: CGRect = self.containerView.frame
        //print(visibleRect)
        visibleRect.size.height -= keyBoardSize.height
        //print(visibleRect)
        var lastElementOrigin: CGPoint = signInButton.frame.origin
        let lastElementHeight: CGFloat = signInButton.frame.size.height
        //print(lastElementOrigin)
        lastElementOrigin.y += lastElementHeight
        //print(lastElementOrigin)

        
        if (!CGRectContainsPoint(visibleRect, lastElementOrigin)){
            print("Not in visibleRect")
            let scrollPoint: CGPoint = CGPointMake(0.0, lastElementOrigin.y - visibleRect.size.height + 12 /* margin to bottom*/)
            scrollView.setContentOffset(scrollPoint, animated: true)
        }
        
        print("self.view.frame after keyboard shown\(self.view.frame)")
        print("didShow")
    
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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
