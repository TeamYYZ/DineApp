//
//  SearchFriendCell.swift
//  Dine
//
//  Created by Senyang Zhuang on 3/26/16.
//  Copyright © 2016 YYZ. All rights reserved.
//

import UIKit

class SearchFriendCell: UITableViewCell {

    @IBOutlet weak var avatarImage: UIImageView!
    
    @IBOutlet weak var screenNameLabel: UILabel!
    
    @IBOutlet weak var emailLabel: UILabel!
    
    @IBOutlet weak var addButton: YYZAcceptButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
