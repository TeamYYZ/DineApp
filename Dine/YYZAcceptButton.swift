//
//  YYZAcceptButton.swift
//  Dine
//
//  Created by YiHuang on 3/27/16.
//  Copyright © 2016 YYZ. All rights reserved.
//

import UIKit

class YYZAcceptButton: UIButton {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupButton()
    }
    
    override init(frame aRect: CGRect) {
        super.init(frame: aRect)
        setupButton()
    }
    
    func enable() {
        self.enabled = true
        self.layer.backgroundColor = ColorTheme.sharedInstance.acceptButtonColor.CGColor
    }
    
    func disable() {
        self.enabled = false
        self.layer.backgroundColor = ColorTheme.sharedInstance.acceptButtonDisableColor.CGColor
    }
    
    func setupButton() {
        
        self.layer.cornerRadius = 4.0
        self.layer.borderWidth = 0.2
        self.layer.borderColor = UIColor(white: 0.7095, alpha: 1.0).CGColor
        self.layer.backgroundColor = ColorTheme.sharedInstance.acceptButtonColor.CGColor
        self.tintColor = ColorTheme.sharedInstance.loginTextColor
        
    }
}
