//
//  YYZButton.swift
//  Dine
//
//  Created by YiHuang on 3/15/16.
//  Copyright © 2016 YYZ. All rights reserved.
//

import UIKit

class YYZButton: UIButton {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    override func awakeFromNib() {
        super.awakeFromNib()
        self.applyPlainShadow()
        print(self.titleLabel?.text)
        self.titleLabel?.applySharpShadow(ColorTheme.sharedInstance.loginTextShadowColor)

    }
}
