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
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var createNewAccountLabel: UIButton!
    @IBOutlet weak var signInButton: UIButton!
    
    @IBOutlet weak var orLabel: UILabel!
    @IBOutlet weak var signUpButton: UIButton!
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
        seperatorViewLeft.setBottomBorder()
        seperatorViewRight.setBottomBorder()
        orLabel.textColor = ColorTheme.sharedInstance.loginTextColor
        usernameField.setBottomBorder()
        passwordField.setBottomBorder()
        passwordField.tintColor = ColorTheme.sharedInstance.loginTextColor
        usernameField.tintColor = ColorTheme.sharedInstance.loginTextColor
        usernameField.textColor = ColorTheme.sharedInstance.loginTextColor
        usernameField.attributedPlaceholder = NSAttributedString(string: "Email address", attributes: [NSForegroundColorAttributeName : ColorTheme.sharedInstance.loginTextColor])
        passwordField.textColor = ColorTheme.sharedInstance.loginTextColor
        passwordField.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSForegroundColorAttributeName : ColorTheme.sharedInstance.loginTextColor])
        
        signInButton.applyPlainShadow()
        signUpButton.applyPlainShadow()
        fbIcon.image?.imageWithRenderingMode(.AlwaysTemplate)
        fbIcon.tintColor = ColorTheme.sharedInstance.loginTextColor

        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func onLogin(sender: AnyObject) {
        self.performSegueWithIdentifier("loginSegue", sender: sender)
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
