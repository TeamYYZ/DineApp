//
//  FriendCell.swift
//  Dine
//
//  Created by you wu on 3/23/16.
//  Copyright © 2016 YYZ. All rights reserved.
//

import UIKit

class FriendCell: UITableViewCell {
    @IBOutlet weak var inviteLabel: UILabel!

    @IBOutlet weak var avatarImage: UIImageView!
    
    @IBOutlet weak var userNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
