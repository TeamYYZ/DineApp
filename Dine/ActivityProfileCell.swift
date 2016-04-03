//
//  ActivityProfileCell.swift
//  Dine
//
//  Created by you wu on 3/14/16.
//  Copyright © 2016 YYZ. All rights reserved.
//

import UIKit

class ActivityProfileCell: UITableViewCell {
    @IBOutlet weak var chatButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var ownerLabel: UILabel!
    
    @IBOutlet weak var checkButton: CheckButton!

    var activity: Activity! {
        didSet{
            nameLabel.text = activity.restaurant
            if let time = activity.requestTime {
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "hh:mm" //format style. Browse online to get a format that fits your needs.
                let dateString = dateFormatter.stringFromDate(time)
                timeLabel.text = dateString
            }
            if let screenName = activity.owner["screenName"] as? String{
                ownerLabel.text = "created by "+screenName
            }
            checkButton.activity = activity
            checkButton.setButton()

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
