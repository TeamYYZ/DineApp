//
//  CurrentActivityBottomBar.swift
//  Dine
//
//  Created by YiHuang on 4/11/16.
//  Copyright © 2016 YYZ. All rights reserved.
//

import UIKit
import ChameleonFramework

class CurrentActivityBottomBar: UIView {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    let borderView = UIView()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // because storyboard has intrinsic width (4s for inferred size), when this view shows on bigger screen, we need to update bounds as well (Maybe it's a bug??)
        borderView.frame.size.width = self.frame.size.width
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: 10).CGPath
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.mainScreen().scale
    }

    override func awakeFromNib() {
        // add the shadow to the base view
        self.backgroundColor = UIColor.clearColor()
        self.layer.shadowColor = UIColor.flatMagentaColor().CGColor
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.layer.shadowOpacity = 0.7
        self.layer.shadowRadius = 2.0
        
        // improve performance
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: 10).CGPath
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.mainScreen().scale
        
        borderView.frame = self.bounds
        borderView.backgroundColor = UIColor.whiteColor()
        borderView.layer.cornerRadius = 10
        borderView.layer.borderColor = UIColor.flatWhiteColor().CGColor
        borderView.layer.borderWidth = 1.0
        borderView.layer.masksToBounds = true
        self.addSubview(borderView)
    }
}
