//
//  YYZTextField.swift
//  Dine
//
//  Created by YiHuang on 3/15/16.
//  Copyright © 2016 YYZ. All rights reserved.
//

import UIKit

class YYZTextField: UITextField {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

    override func awakeFromNib() {
        self.borderStyle = .None
        self.setBottomBorder(color: ColorTheme.sharedInstance.loginTextColor)
        self.tintColor = ColorTheme.sharedInstance.loginTextColor
        self.textColor = ColorTheme.sharedInstance.loginTextColor
        if let placeholder = self.placeholder {
            self.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [NSForegroundColorAttributeName : ColorTheme.sharedInstance.loginTextColor])
        
        }

    }
}
