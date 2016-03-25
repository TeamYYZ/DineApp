//
//  RestaurantProfileCell.swift
//  Dine
//
//  Created by you wu on 3/24/16.
//  Copyright © 2016 YYZ. All rights reserved.
//

import UIKit

class RestaurantProfileCell: UITableViewCell {

    @IBOutlet weak var checkButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ratingView: UIImageView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var openhourLabel: UILabel!
    
    var business: Business! {
        didSet {
            if business.name != nil {
            nameLabel.text = business.name
            }
            if business.ratingImageURL != nil {
               ratingView.setImageWithURL(business.ratingImageURL!)
            }
            if business.categories != nil {
                categoryLabel.text = business.categories
            }
            openhourLabel.text = "Open Now"
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
