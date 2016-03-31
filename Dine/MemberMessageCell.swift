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
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
