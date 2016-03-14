//
//  CheckButton.swift
//  Dine
//
//  Created by you wu on 3/13/16.
//  Copyright © 2016 YYZ. All rights reserved.
//

import UIKit

class CheckButton: UIButton {

    let checked = UIImage(named: "Checked")
    let cancel = UIImage(named: "Cancel")
    var isChecked = false
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupButton()
    }
    
    override init(frame aRect: CGRect) {
        super.init(frame: aRect)
        setupButton()
    }

    
    func setupButton() {
        self.setImage(checked, forState: .Normal)
        self.adjustsImageWhenHighlighted = false
        
        self.frame = CGRectMake(0, 0, 30, 30)
        self.addTarget(self, action: "buttonClicked:", forControlEvents: UIControlEvents.TouchDown)

    }
    
    func buttonClicked (sender : UIButton!) {
        isChecked = !isChecked
        if isChecked {
            sender.setImage(cancel, forState: .Normal)
            sender.setImage(cancel, forState: .Highlighted)
            NSNotificationCenter.defaultCenter().postNotificationName("userJoinedNotification", object: nil)

        }else {
            sender.setImage(checked, forState: .Normal)
            sender.setImage(checked, forState: .Highlighted)
            NSNotificationCenter.defaultCenter().postNotificationName("userExitedNotification", object: nil)
        }
        
    }
    
}
