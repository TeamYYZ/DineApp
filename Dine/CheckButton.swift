//
//  CheckButton.swift
//  Dine
//
//  Created by you wu on 3/13/16.
//  Copyright © 2016 YYZ. All rights reserved.
//

import UIKit

class CheckButton: UIButton {
    var button : UIButton = UIButton(type: UIButtonType.Custom)
    let checked = UIImage(named: "Checked")
    let checkedFilled = UIImage(named: "CheckedFilled")
    var isChecked = false
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupButton()
    }
    
    override init(frame aRect: CGRect) {
        super.init(frame: aRect)
        setupButton()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        button.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2)
    }
    
    func setupButton() {
        button.setImage(checked, forState: .Normal)
        button.setImage(checkedFilled, forState: .Selected)
        button.setImage(checkedFilled, forState: .Highlighted)
        button.adjustsImageWhenHighlighted = false
        
        button.frame = CGRectMake(0, 0, 30, 30)
        button.addTarget(self, action: "buttonClicked:", forControlEvents: UIControlEvents.TouchUpInside)
        self.addSubview(button)

    }
    
    func buttonClicked (sender : UIButton!) {
        isChecked = !isChecked
        if isChecked {
            sender.setImage(checkedFilled, forState: .Normal)
            NSNotificationCenter.defaultCenter().postNotificationName("userJoinedNotification", object: nil)

        }else {
            sender.setImage(checked, forState: .Normal)
            NSNotificationCenter.defaultCenter().postNotificationName("userExitedNotification", object: nil)
        }
        
    }
    
}
