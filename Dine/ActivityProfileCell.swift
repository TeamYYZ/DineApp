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
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var ownerLabel: UILabel!
    
    @IBOutlet weak var checkButton: UIButton!
    var isChecked = false
    var activity: Activity! {
        didSet{
            nameLabel.text = activity?.restaurant
            if let time = activity?.requestTime {
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "hh:mm a" //format style. Browse online to get a format that fits your needs.
                let timeString = dateFormatter.stringFromDate(time)
                dateFormatter.dateFormat = "MMM"
                let monthString = dateFormatter.stringFromDate(time)
                dateFormatter.dateFormat = "d"
                let dateString = dateFormatter.stringFromDate(time)
                timeLabel.text = timeString
                monthLabel.text = monthString
                dateLabel.text = dateString
                
            }
            activity?.owner.fetchIfNeededInBackgroundWithBlock({ (owner: PFObject?, error:NSError?) in
                if let screenName = owner!["screenName"] as? String{
                    self.ownerLabel.text = "created by "+screenName
                }

            })

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
