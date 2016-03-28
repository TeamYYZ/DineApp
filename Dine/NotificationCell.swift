//
//  NotificationCell.swift
//  Dine
//
//  Created by YiHuang on 3/26/16.
//  Copyright © 2016 YYZ. All rights reserved.
//

import UIKit

class NotificationCell: UITableViewCell {

    @IBOutlet weak var typeImageView: UIImageView!
    
    @IBOutlet weak var senderLabel: UILabel!
    
    @IBOutlet weak var typeLabel: UILabel!
    
    @IBOutlet weak var acceptButton: YYZAcceptButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
