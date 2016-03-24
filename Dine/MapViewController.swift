//
//  MapViewController.swift
//  Dine
//
//  Created by you wu on 3/13/16.
//  Copyright © 2016 YYZ. All rights reserved.
//

import UIKit
import MapKit
import SWRevealViewController
import Parse



class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var arrivalTimeLabel: UILabel!
    @IBOutlet weak var exitActivityButton: UIButton!

    var location: CLLocation?
    var locationManager = CLLocationManager()
    var activities = [Activity]()
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        if self.activities.capacity == 0{
            createSomeActivities()
        }
        mapView.delegate = self
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        let status = CLLocationManager.authorizationStatus()
        
        if status == .AuthorizedWhenInUse {
            mapView.showsUserLocation = true
            print("WhenInUse")
            goToLocation(location)
            
            locationManager.startUpdatingLocation()
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "userJoinedActivity", name: "userJoinedNotification", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "userExitedActivity", name: "userExitedNotification", object: nil)
        
        menuButton.target = self.revealViewController()
        menuButton.action = Selector("revealToggle:")
        exitActivityButton.addTarget(self, action: Selector("userExitedActivity:"), forControlEvents: .TouchUpInside)
        toolBar.hidden = true
        arrivalTimeLabel.hidden = true
        loadMap()

    }
    
    


    func userJoinedActivity() {
        //update map, only show selected point and direction
        //always show pin view
        
        toolBar.hidden = false
        arrivalTimeLabel.hidden = false
//        self.viewDidLoad()
        
        loadMap()
   
    }
    
    func userExitedActivity() {
        //update map, show all requests in the area

        toolBar.hidden = true
        arrivalTimeLabel.hidden = true
//        self.viewDidLoad()
        loadMap()
    }
    
    func userExitedActivity(sender: UIButton!) {
        userExitedActivity()
    }
    
    @IBAction func unwindToMapView(sender: UIStoryboardSegue) {
        let vc = sender.sourceViewController as! FriendsViewController
        let activity = vc.activityInProgress
        
    }
    
 
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.AuthorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        goToLocation(nil)

//        print(locations.last!)
//        if locations.last!.distanceFromLocation(location!) > CLLocationDistance(1.0){
//            location = locations.last!
//            User.currentUser?.current_location = location
//            goToLocation(location!)
//        }
    }

    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        if let annotation = annotation as? MapAnnotation {

            var view = mapView.dequeueReusableAnnotationViewWithIdentifier("id")
            if view == nil {
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "id")
            }
            
            view!.canShowCallout = true
            view!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure) as UIView
            //let button = CheckButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
            //view!.leftCalloutAccessoryView = button
          
            let mapDetailView = MapDetailView()
            mapDetailView.annotation = annotation
            view!.detailCalloutAccessoryView = mapDetailView
            return view
        }
        return nil
    }
    
    func mapView(mapView: MKMapView, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == annotationView.rightCalloutAccessoryView {
            //print(annotationView.annotation?.title)
            self.performSegueWithIdentifier("toActivityProfileSegue", sender: annotationView.annotation)
           
        }
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let activityProfileViewController = segue.destinationViewController as? ActivityProfileViewController {
        let annotation = sender as! MapAnnotation
        activityProfileViewController.activity = annotation.activity
        }
                
    }
    


    
    func loadMap() {
        mapView.removeAnnotations(mapView.annotations)
        if Activity.current_activity == nil{
            for activity in activities{
              let annotation = MapAnnotation(activity: activity)
                
              mapView.addAnnotation(annotation)
            }
        }else{
            let annotation = MapAnnotation(activity: Activity.current_activity!)
            mapView.addAnnotation(annotation)
            
        }
        
    }
    
    
    // lock my region
    func goToLocation(currlocation: CLLocation?) {
        if let myLocation
            = locationManager.location {
            let center = CLLocationCoordinate2D(latitude: myLocation.coordinate.latitude, longitude: myLocation.coordinate.longitude)
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
//            let span = MKCoordinateSpanMake(0.1, 0.1)
//            let region = MKCoordinateRegionMake(myLocation.coordinate, span)
            //mapView.setRegion(region, animated: false)
//            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
//            locationManager.distanceFilter = 200
            //print(User.currentUser?.current_location)
            mapView.setRegion(region, animated: false)
        }

    }
    
    
    //This function is just designed for debug,lol
    func createSomeActivities(){

//        let loc1 = CLLocationCoordinate2D(latitude: 30.6014, longitude: -96.3144)
//        let group1 = Group(GID: "g1", owner_uid: "1", group_members: ["John","Sammy"], chat_id: "c1")
//
//        let act1 = Activity(AID: "1", request_poster_username: "Sammy", request_time: "11:30", yelp_business_id: "yelp_id", overview: "Example1", group: group1, location: loc1, restaurant: "Yaku")
//        self.activities.append(act1)
//
//
//        let loc2 = CLLocationCoordinate2D(latitude: 30.6014, longitude: -96.3154)
//        let group2 = Group(GID: "g2", owner_uid: "2", group_members: ["Jeremy","Edward"], chat_id: "c2")
//        let act2 = Activity(AID: "2", request_poster_username: "Jeremy", request_time: "11:45", yelp_business_id: "yelp_id", overview: "Example2", group: group2, location: loc2, restaurant: "What A Burger")
//        self.activities.append(act2)
//        
//        let group3 = Group(GID: "g3", owner_uid: "3", group_members: ["Michael","Green"], chat_id: "c3")
//        let loc3 = CLLocationCoordinate2D(latitude: 30.6024, longitude: -96.3154)
//
//        let act3 = Activity(AID: "3", request_poster_username: "Michael", request_time: "12:00", yelp_business_id: "yelp_id", overview: "Example3", group: group3, location: loc3, restaurant: "McDonald")
//        self.activities.append(act3)
//
//        let loc4 = CLLocationCoordinate2D(latitude: 30.6024, longitude: -96.3164)
//        let group4 = Group(GID: "g4", owner_uid: "4", group_members: ["Eric","Cathy"], chat_id: "c4")
//        let act4 = Activity(AID: "4", request_poster_username: "Eric", request_time: "12:15", yelp_business_id: "yelp_id", overview: "Example4", group: group4, location: loc4, restaurant: "Chef Cao")
//        self.activities.append(act4)
        print("Successfully Created 4 examples")
        
        
        
    
    }

}
