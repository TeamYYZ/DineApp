//
//  PanelIcon.swift
//  Dine
//
//  Created by YiHuang on 4/23/16.
//  Copyright © 2016 YYZ. All rights reserved.
//

import UIKit
import ChameleonFramework

class PanelIcon: UIImageView {

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
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: 24).CGPath
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.mainScreen().scale
    }
    
    override func awakeFromNib() {
        // add the shadow to the base view
        self.backgroundColor = UIColor.clearColor()
        self.layer.shadowColor = UIColor.flatRedColor().CGColor
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.layer.shadowOpacity = 0.8
        self.layer.shadowRadius = 3.0
        
        // improve performance
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: 24).CGPath
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.mainScreen().scale
        
        borderView.frame = self.bounds
        borderView.layer.cornerRadius = 24
        borderView.layer.borderColor = UIColor.flatWhiteColor().CGColor
        borderView.layer.borderWidth = 1.0
        borderView.layer.masksToBounds = true
        self.addSubview(borderView)
        
        let otherSubContent = UIImageView()
        otherSubContent.image = UIImage(named: "plate")
        otherSubContent.frame = borderView.bounds
        borderView.addSubview(otherSubContent)
        

    }

}
