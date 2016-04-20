//
//  MemberMessageCell.swift
//  Dine
//
//  Created by Senyang Zhuang on 3/30/16.
//  Copyright © 2016 YYZ. All rights reserved.
//

import UIKit

class MemberMessageCell: UITableViewCell {

    @IBOutlet weak var screenNameLabel: UILabel!
    
    @IBOutlet weak var contentLabel: UILabel!
    
    @IBOutlet weak var avatarImageView: UIImageView!
    
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var timeLabelHeight: NSLayoutConstraint!
    
    
    @IBOutlet weak var textView: UIView!
    
    @IBOutlet weak var photoView: UIImageView!
    
    var indexInTable = -1
    
    override func awakeFromNib() {
        super.awakeFromNib()
        textView.layer.cornerRadius = 8.0
        textView.backgroundColor = ColorTheme.sharedInstance.chatRecipientBackgroudColor
        contentLabel.textColor = ColorTheme.sharedInstance.chatRecipientMessageColor
        avatarImageView.layer.cornerRadius = 10.0
        avatarImageView.clipsToBounds = true
        photoView.layer.cornerRadius = 10.0
        photoView.clipsToBounds = true
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
