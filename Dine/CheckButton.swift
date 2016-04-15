//
//  CheckButton.swift
//  Dine
//
//  Created by you wu on 3/13/16.
//  Copyright © 2016 YYZ. All rights reserved.
//

import UIKit
import MBProgressHUD

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

    }
}
