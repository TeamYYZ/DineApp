//
//  LoginViewController.swift
//  Dine
//
//  Created by you wu on 3/12/16.
//  Copyright © 2016 YYZ. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    let gradientLayer = CAGradientLayer()
    
    
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

        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func onLogin(sender: AnyObject) {
        // need to validate input first
        ParseAPI.signIn(usernameField.text!, password: passwordField.text!, successCallback: { () -> () in
            print("Login Successfully")
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
