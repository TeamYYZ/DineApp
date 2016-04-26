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
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var businesses: [Business]!
    var searchTerm = String("Restaurants")
    var location: CLLocationCoordinate2D!
    
    var isMoreDataLoading = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //get user current location
        let defaults = NSUserDefaults.standardUserDefaults()
        if let lat = defaults.objectForKey("user_current_location_lat") as? CLLocationDegrees {
            if let lon = defaults.objectForKey("user_current_location_lon") as? CLLocationDegrees {
                location = CLLocationCoordinate2D(latitude: lat, longitude: lon)

            }
        }
        
        if location == nil {
            location = CLLocationCoordinate2D(latitude: 30.601433, longitude: -96.314464)
        }
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 120
        
        searchBar.delegate = self
        //feed in tableview yelp data
        // Example of Yelp search with more search options specified
        updateSearch()
        
    }
    
    func updateSearch() {
        let hud = MBProgressHUD.showLoadingHUDToView(self.view, animated: true)

        Business.searchWithTerm(searchTerm, location: location, sort: YelpSortMode.Distance.rawValue, radius: 0, categories:[], deals: false, offset: 0) { (businesses: [Business]!, error: NSError!) -> Void in
            hud.progress = 1.0
            hud.hide(true)
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

        return cell
    }

    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        var detailBusiness: Business?
        detailBusiness = businesses[indexPath.row]
        
        
        Business.getDetailWithId((detailBusiness?.businessID)!, completion: { (business: Business!, error: NSError!) -> Void in
                print(business)
            self.performSegueWithIdentifier("toRestaurantDetailSegue", sender: business)
        })
        return indexPath
    }


    
    @IBAction func unwindToRestaurantPicker(segue: UIStoryboardSegue) {
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toRestaurantDetailSegue" {
            let vc = segue.destinationViewController as! RestaurantDetailViewController

            vc.business = sender as! Business
        }

    }

}

