//
//  RestaurantPickerViewController.swift
//  Dine
//
//  Created by you wu on 3/14/16.
//  Copyright © 2016 YYZ. All rights reserved.
//

import UIKit
import MBProgressHUD

class RestaurantPickerViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate{
    @IBOutlet weak var nextButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var activityInProgress: Activity?
    var checked = false
    
    var businesses: [Business]!
    var selectedBusiness: Business?
    var detailBusiness: Business?
    var searchTerm = String("Restaurants")
    var location: CLLocationCoordinate2D!
    
    var isMoreDataLoading = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 120
        
        searchBar.delegate = self
        //feed in tableview yelp data
        // Example of Yelp search with more search options specified
        updateSearch()

        activityInProgress = Activity()
        
    }
    
    func updateSearch() {
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        Business.searchWithTerm(searchTerm, location: location, sort: YelpSortMode.Distance.rawValue, radius: 0, categories:[], deals: false, offset: 0) { (businesses: [Business]!, error: NSError!) -> Void in
            MBProgressHUD.hideHUDForView(self.view, animated: true)
            self.businesses = businesses
            self.tableView.reloadData()
        }
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        self.searchTerm = searchBar.text!
        updateSearch()
        searchBar.resignFirstResponder()
        
    }
    
    // MARK: - Table view data source

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if businesses != nil {
            return businesses.count
        }else {
            return 0
        }
    }


    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("restaurantCell", forIndexPath: indexPath) as! RestaurantCell
        cell.business = businesses[indexPath.row]
        cell.checkButton.tag = indexPath.row
        cell.checkButton.addTarget(self, action: "buttonChecked:", forControlEvents: .TouchUpInside)

        return cell
    }

    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        detailBusiness = businesses[indexPath.row]
        Business.getDetailWithId((detailBusiness?.businessID)!, completion: { (business: Business!, error: NSError!) -> Void in
            self.performSegueWithIdentifier("toRestaurantDetailSegue", sender: business)
        })
        return indexPath
    }

    func buttonChecked(sender: UIButton){
        //get selected business
        if let cell = sender.superview?.superview as? RestaurantCell {
            if cell.isChecked {
                selectedBusiness = businesses[sender.tag]
        
                //change bar button item
                nextButton.title = "Next"
                
                //delete other rows
                
            }else {
                //change bar button item
                nextButton.title = "Skip"
                
                //reload tableview
            }
        }
        
    }



    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func unwindToRestaurantPicker(segue: UIStoryboardSegue) {
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toRestaurantDetailSegue" {
            let vc = segue.destinationViewController as! RestaurantDetailViewController

            vc.activityInProgress = self.activityInProgress
            vc.business = sender as! Business
            
        }
        if segue.identifier == "nextSegue" {
            if selectedBusiness != nil {
            activityInProgress?.setupRestaurant(selectedBusiness!)
                
            }
        }
    }

}
