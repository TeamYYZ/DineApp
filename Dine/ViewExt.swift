//
//  ViewBorder.swift
//  Dine
//
//  Created by Yi Huang on 16/3/14.
//  Copyright © 2016年 YYZ. All rights reserved.
//


import UIKit
import ChameleonFramework

extension UIView {
    func setBottomBorder(color color: UIColor) {
        let BottomBorder = CALayer()
        BottomBorder.frame = CGRectMake(0.0, self.frame.size.height - 1, self.frame.size.width, 1.0)
        BottomBorder.backgroundColor = color.CGColor
        self.layer.addSublayer(BottomBorder)
    }
    
    func applyPlainShadow() {
        layer.shadowColor = UIColor.blackColor().CGColor
        layer.shadowOffset = CGSize(width: 1.3, height: 1.3)
        layer.shadowOpacity = 0.4
        layer.shadowRadius = 1
    }
    
    func applySharpShadow(color: UIColor) {
        layer.shadowColor = color.CGColor
        layer.shadowOffset = CGSize(width: 1.3, height: 1.3)
        layer.shadowOpacity = 0.5
        layer.shadowRadius = 0.2
    }
}
