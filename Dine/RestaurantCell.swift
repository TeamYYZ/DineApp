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

    let checked = UIImage(named: "Checked")
    let cancel = UIImage(named: "CheckedFilled")
    var isChecked = false

    var business: Business! {
        didSet {
            nameLabel.text = business.name
            genreLabel.text = business.categories
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        checkButton.addTarget(self, action: "buttonClicked:", forControlEvents: UIControlEvents.TouchDown)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        selectionStyle = .None
        // Configure the view for the selected state
    }
    
    func buttonClicked (sender : UIButton!) {
        isChecked = !isChecked
        if (isChecked) {
            checkButton.setImage(cancel, forState: .Normal)
            checkButton.setImage(cancel, forState: .Highlighted)
            
        }else {
            checkButton.setImage(checked, forState: .Normal)
            checkButton.setImage(checked, forState: .Highlighted)

        }
        
    }


}
