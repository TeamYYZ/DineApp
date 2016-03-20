//
//  BaseSignUpViewController.swift
//  Dine
//
//  Created by YiHuang on 3/19/16.
//  Copyright © 2016 YYZ. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController {
    let gradientLayer = CAGradientLayer()
    static var emailaddr: String?
    static var password: String?
    static var firstname: String?
    static var lastname: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        gradientLayer.frame = self.view.bounds
        gradientLayer.zPosition = -1
        let color1 = ColorTheme.sharedInstance.loginGradientFisrtColor.CGColor as CGColorRef
        let color2 = ColorTheme.sharedInstance.loginGradientSecondColor.CGColor as CGColorRef
        gradientLayer.colors = [color1, color2]
        gradientLayer.locations = [0.0, 1.0]
        self.view.layer.addSublayer(gradientLayer)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
