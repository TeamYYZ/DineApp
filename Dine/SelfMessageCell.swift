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
    
    @IBOutlet weak var timeLabelHeight: NSLayoutConstraint!
    
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var textView: UIView!
    
    @IBOutlet weak var photoView: UIImageView!
    
    
    var indexInTable = -1
        
    var maxSize: CGSize {
        get {
            // MARK: 116 = width of all views ocuppied except UILabel
            let maxWidth = CGRectGetWidth(self.bounds) - 116
            let maxHeight = CGFloat.max
            return CGSize(width: maxWidth, height: maxHeight)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        textView.layer.cornerRadius = 8.0
        contentLabel.textColor = ColorTheme.sharedInstance.chatMyMessageColor
        textView.backgroundColor = ColorTheme.sharedInstance.chatMyBackgroudColor
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
