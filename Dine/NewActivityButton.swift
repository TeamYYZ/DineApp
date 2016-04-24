//
//  NewActivityButton.swift
//  Dine
//
//  Created by YiHuang on 4/24/16.
//  Copyright © 2016 YYZ. All rights reserved.
//

import UIKit

class NewActivityButton: UIButton {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    override func awakeFromNib() {
        // add the shadow to the base view
        layer.cornerRadius = 10
        layer.masksToBounds = true
    }

}
