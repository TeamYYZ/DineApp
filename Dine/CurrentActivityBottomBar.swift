//
//  CurrentActivityBottomBar.swift
//  Dine
//
//  Created by YiHuang on 4/11/16.
//  Copyright © 2016 YYZ. All rights reserved.
//

import UIKit

class CurrentActivityBottomBar: UIView {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

    override func awakeFromNib() {
        self.setTopBorder(color: UIColor.flatWhiteColorDark())
    }
}
