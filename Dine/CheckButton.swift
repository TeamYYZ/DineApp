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
    var activity: Activity?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupButton()
    }
    
    override init(frame aRect: CGRect) {
        super.init(frame: aRect)
        setupButton()
    }

    
    func setupButton() {

        //Wait until 
        

    }
    
    func setButton(){

        if Activity.current_activity == nil {
            isChecked = false
            self.setImage(checked, forState: .Normal)
            self.addTarget(self, action: "buttonClicked:", forControlEvents: UIControlEvents.TouchDown)
        }else if Activity.current_activity!.activityId == self.activity!.activityId{
            isChecked = true
            self.setImage(cancel, forState: .Normal)
            self.addTarget(self, action: "buttonClicked:", forControlEvents: UIControlEvents.TouchDown)
        }else{
            
            self.setImage(nil, forState: .Normal)
        }
        self.adjustsImageWhenHighlighted = false
        
//        self.frame = CGRectMake(0, 0, 30, 30)
    
    }
    
    func buttonClicked (sender : UIButton!) {
        if Activity.current_activity == nil {
            isChecked = true
            self.setImage(cancel, forState: .Normal)
            self.setImage(cancel, forState: .Highlighted)
            Activity.current_activity = self.activity
//            Group.current_group = Activity.current_activity?.group
            NSNotificationCenter.defaultCenter().postNotificationName("userJoinedNotification", object: nil)

        }else {
            isChecked = false
            self.setImage(checked, forState: .Normal)
            self.setImage(checked, forState: .Highlighted)
            Activity.current_activity = nil
//            Group.current_group = nil
            NSNotificationCenter.defaultCenter().postNotificationName("userExitedNotification", object: nil)
        }
        
    }
    
}
