//
//  ActivityMemberCell.swift
//  Dine
//
//  Created by you wu on 4/3/16.
//  Copyright © 2016 YYZ. All rights reserved.
//

import UIKit

class ActivityMemberCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    var userId: String?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
