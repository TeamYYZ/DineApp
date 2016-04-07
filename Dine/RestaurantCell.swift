//
//  RestaurantCell.swift
//  Dine
//
//  Created by you wu on 3/24/16.
//  Copyright © 2016 YYZ. All rights reserved.
//

import UIKit

class RestaurantCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var profileView: UIImageView!
    @IBOutlet weak var ratingView: UIImageView!

    var business: Business! {
        didSet {
            nameLabel.text = business.name
            genreLabel.text = business.categories
            if let image = business.imageURL {
                profileView.setImageWithURL(image)
            }
            if let image = business.ratingImageURL {
                ratingView.setImageWithURL(image)
            }

        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        selectionStyle = .None
        // Configure the view for the selected state
    }

}
