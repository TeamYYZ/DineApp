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

        print(PFUser.currentUser()?.username)
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
        updateMap()

    }
    
    


    func userJoinedActivity() {
        //update map, only show selected point and direction
        //always show pin view
        
        toolBar.hidden = false
        arrivalTimeLabel.hidden = false
//        self.viewDidLoad()
        
        updateMap()
   
    }
    
    func userExitedActivity() {
        //update map, show all requests in the area

        toolBar.hidden = true
        arrivalTimeLabel.hidden = true
//        self.viewDidLoad()
        updateMap()
    }
    
    func userExitedActivity(sender: UIButton!) {
        userExitedActivity()
    }
    
    @IBAction func unwindToMapView(sender: UIStoryboardSegue) {
        if let vc = sender.sourceViewController as? FriendsViewController {

        let activity = vc.activityInProgress
            //save to Parse
            activity?.saveToBackend({ () -> () in
                print("save successfully")
                Activity.current_activity = activity
                self.updateMap()
                }, failureHandler: { () -> () in
                print("something wrong...")
            })
            
        }
        
    }
    
 
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.AuthorizedWhenInUse {
            mapView.showsUserLocation = true
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

        if annotation.isKindOfClass(MKUserLocation) {
            return nil
        }
        
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
        
        if let navVC = segue.destinationViewController as? UINavigationController {
            if let _ = navVC.topViewController as? ActivityCreatorViewController {
                let defaults = NSUserDefaults.standardUserDefaults()
                defaults.setObject(locationManager.location?.coordinate.latitude, forKey: "user_current_location_lat")
                defaults.setObject(locationManager.location?.coordinate.longitude, forKey: "user_current_location_lon")
                
                defaults.synchronize()
                
            }
        }
                
    }
    
    func updateMap() {
        mapView.removeAnnotations(mapView.annotations)
        if Activity.current_activity == nil{
            for activity in activities{
              let annotation = MapAnnotation(activity: activity)
                
              mapView.addAnnotation(annotation)
            }
        }else{
            print("joined activity")
            let annotation = MapAnnotation(activity: Activity.current_activity!)
            mapView.addAnnotation(annotation)
            //start navigation
            
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
    
    // This function is created for debug.

    


}
