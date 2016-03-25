//
//  ActivityCreatorViewController.swift
//  Dine
//
//  Created by you wu on 3/24/16.
//  Copyright © 2016 YYZ. All rights reserved.
//

import UIKit

class ActivityCreatorViewController: UITableViewController, UITextFieldDelegate {

    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var restaurantField: UITextField!
    @IBOutlet weak var descriptionField: UITextField!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    var activityInProgress: Activity?

    override func viewDidLoad() {
        super.viewDidLoad()
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy HH:mm"
        let strDate = dateFormatter.stringFromDate(NSDate())
        timeLabel.text = strDate
        titleField.delegate = self
        descriptionField.delegate = self
        
        activityInProgress = Activity()

    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    @IBAction func onDatePicker(sender: AnyObject) {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy HH:mm"
        let strDate = dateFormatter.stringFromDate(datePicker.date)
        self.timeLabel.text = strDate
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func unwindToActivityCreator(segue: UIStoryboardSegue) {
        if let restaurantPicker = segue.sourceViewController as? RestaurantPickerViewController {
            
            restaurantField.text = restaurantPicker.selectedBusiness?.name
            if restaurantPicker.selectedBusiness != nil {
                self.activityInProgress?.setupRestaurant(restaurantPicker.selectedBusiness!)
            }
        }
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let friendVC = segue.destinationViewController as? FriendsViewController {
            friendVC.activityInProgress = self.activityInProgress

            self.activityInProgress?.setupDetail(self.titleField.text, time: datePicker.date, overview: descriptionField.text)
        }
    }


}
