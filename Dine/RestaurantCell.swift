//
//  RestaurantCell.swift
//  Dine
//
//  Created by you wu on 3/24/16.
//  Copyright © 2016 YYZ. All rights reserved.
//

import UIKit

class RestaurantCell: UITableViewCell {
    @IBOutlet weak var checkButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!

    var business: Business! {
        didSet {
            nameLabel.text = business.name
            genreLabel.text = business.categories
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
