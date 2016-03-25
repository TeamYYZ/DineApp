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
            if let name = review["user"]!["name"] as? String{
                nameLabel.text = name
            }
            
            if let profileURL = review["user"]!["image_url"] as? String {
                profileView.setImageWithURL(NSURL(string: profileURL)! )
            }
            if let ratingURL = review["rating_image_url"] as? String {
                ratingView.setImageWithURL(NSURL(string: ratingURL)!)
            }
            if let excerpt = review["excerpt"] as? String {
                excerptLabel.text = excerpt
            }
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
