//
//  RestaurantReviewCell.swift
//  Dine
//
//  Created by you wu on 3/24/16.
//  Copyright © 2016 YYZ. All rights reserved.
//

import UIKit

class RestaurantReviewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profileView: UIImageView!
    @IBOutlet weak var ratingView: UIImageView!
    @IBOutlet weak var excerptLabel: UILabel!
    
    var review: NSDictionary! {
        didSet {
            nameLabel.text = review["user"]!["name"] as? String
            let profileURL = review["user"]!["image_url"] as? String
            print(profileURL)
            profileView.setImageWithURL(NSURL(string: profileURL!)! )
            ratingView.setImageWithURL(NSURL(string: review["rating_image_url"] as! String)!)
            excerptLabel.text = review["excerpt"] as? String
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
