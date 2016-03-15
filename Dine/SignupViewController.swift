//
//  SignupViewController.swift
//  Dine
//
//  Created by you wu on 3/12/16.
//  Copyright © 2016 YYZ. All rights reserved.
//

import UIKit

class SignupViewController: UIViewController {
    let gradientLayer = CAGradientLayer()
    
    @IBOutlet weak var descriptionLabel1: UILabel!
    @IBOutlet weak var descriptionLabel2: UILabel!
    @IBOutlet weak var backButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        gradientLayer.frame = self.view.bounds
        gradientLayer.zPosition = -1
        let color1 = ColorTheme.sharedInstance.loginGradientFisrtColor.CGColor as CGColorRef
        let color2 = ColorTheme.sharedInstance.loginGradientSecondColor.CGColor as CGColorRef
        gradientLayer.colors = [color1, color2]
        gradientLayer.locations = [0.0, 1.0]
        self.view.layer.addSublayer(gradientLayer)
        
        descriptionLabel1.textColor = ColorTheme.sharedInstance.loginTextColor
        descriptionLabel2.textColor = ColorTheme.sharedInstance.loginTextColor
        
        backButton.titleLabel?.textColor = UIColor.flatYellowColor()
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onSignup(sender: AnyObject) {
        self.performSegueWithIdentifier("signupSegue", sender: sender)
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
