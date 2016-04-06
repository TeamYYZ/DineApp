//
//  SelfMessageCell.swift
//  Dine
//
//  Created by Senyang Zhuang on 3/30/16.
//  Copyright © 2016 YYZ. All rights reserved.
//

import UIKit

class SelfMessageCell: UITableViewCell {

    @IBOutlet weak var screenNameLabel: UILabel!
    
    
    @IBOutlet weak var contentLabel: UILabel!
    
    
    @IBOutlet weak var avatarImageView: UIImageView!
    
    
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var textView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.textView.layer.cornerRadius = 8.0
        self.contentLabel.textColor = ColorTheme.sharedInstance.chatMyMessageColor
        self.textView.backgroundColor = ColorTheme.sharedInstance.chatMyBackgroudColor
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
