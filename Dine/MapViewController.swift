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
import GoogleMaps

class MapViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate {
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var arrivalTimeLabel: UILabel!
    @IBOutlet weak var exitActivityButton: UIButton!

    @IBOutlet weak var directionsLabel: UILabel!

    var location: CLLocation?
    var locationManager = CLLocationManager()
    var activities = [Activity]()
    
    dynamic var mapView: GMSMapView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupGoogleMap()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
//        let status = CLLocationManager.authorizationStatus()

//        if status == .AuthorizedWhenInUse {
//            //goToLocation(location)
//            locationManager.startUpdatingLocation()
//        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MapViewController.userJoinedActivity), name: "userJoinedNotification", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MapViewController.userExitedActivity as (MapViewController) -> () -> ()), name: "userExitedNotification", object: nil)
        
        menuButton.target = self.revealViewController()
        menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
        exitActivityButton.addTarget(self, action: #selector(MapViewController.userExitedActivity(_:)), forControlEvents: .TouchUpInside)
        toolBar.hidden = true
        arrivalTimeLabel.hidden = true
        //updateMap()

        
    }
    
    func setupGoogleMap() {
        let camera = GMSCameraPosition.cameraWithLatitude(-33.86,
                                                          longitude: 151.20, zoom: 6)
        var bound = self.view.bounds
        let navHeight = self.navigationController!.navigationBar.frame.size.height
        
        bound = CGRect(x: 0.0, y: navHeight, width: bound.width, height: bound.height - navHeight)
        print(bound)
        mapView = GMSMapView.mapWithFrame(bound, camera: camera)
        mapView.settings.compassButton = true
        mapView.settings.myLocationButton = true
        mapView.delegate = self
        self.view.insertSubview(mapView, atIndex:0)
        
        mapView.addObserver(self, forKeyPath: "myLocation", options: NSKeyValueObservingOptions.New, context: nil)

//        let marker = GMSMarker()
//        marker.position = CLLocationCoordinate2DMake(-33.86, 151.20)
//        marker.title = "Sydney"
//        marker.snippet = "Australia"
//        marker.map = mapView
    }

    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
            if let myLocation: CLLocation = change![NSKeyValueChangeNewKey] as? CLLocation {
                mapView.camera = GMSCameraPosition.cameraWithTarget(myLocation.coordinate, zoom: 14.0)
                //update direction info
                GoogleDirectionsAPI.direction(myLocation.coordinate, destination: CLLocationCoordinate2D(latitude: 30.6414995, longitude: -96.3086088)) { (routes: [Route]!, error: NSError!) in
                    
                    if let instruction = routes[0].steps[0].instruction {
                        let attrStr = try! NSAttributedString(
                            data: instruction.dataUsingEncoding(NSUnicodeStringEncoding, allowLossyConversion: true)!,
                            options: [ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType],
                            documentAttributes: nil)
                        self.directionsLabel.attributedText = attrStr
                    }
                }
        }
    }
    
    deinit {
        mapView.removeObserver(self, forKeyPath: "myLocation", context: nil)
    }
    
    func userJoinedActivity() {
        //update map, only show selected point and direction

        //always show pin view
        
        toolBar.hidden = false
        arrivalTimeLabel.hidden = false
//        self.viewDidLoad()
        
        //updateMap()
   
    }
    
    func userExitedActivity() {
        //update map, show all requests in the area

        toolBar.hidden = true
        arrivalTimeLabel.hidden = true
//        self.viewDidLoad()
        //updateMap()
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
                if let invitedUserList = activity?.group?.getUserIdList() {
                    for invitedUser in invitedUserList {
                        print(User.currentUser!.screenName!)
                        let notification = UserNotification(type: .Invitation, content: "Invite you to a activity", senderId: activity!.ownerId!, receiverId: invitedUser, associatedId: activity!.activityId, senderName: User.currentUser!.screenName!, senderAvatarPFFile: User.currentUser?.avatarImagePFFile)
                        
                        
                        notification.saveToBackend({ () -> () in
                            print("success")
                            }, failureHandler: { (error: NSError?) -> () in
                            print("failure")
                        })
                        
                    
                    
                    }
                }
                
                Activity.current_activity = activity
                self.userJoinedActivity()
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
            mapView.myLocationEnabled = true

        }
    }
    
//    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        //goToLocation(nil)
//
//        if let location: CLLocation = locations.last {
//        var eventDate: NSDate = location.timestamp
//        var howRecent: NSTimeInterval = eventDate.timeIntervalSinceNow
//        if abs(howRecent) < 15.0 {
//            // Update your marker on your map using location.coordinate.latitude
//            mapView.myLocation = location
//
//            //and location.coordinate.longitude);
//        }
//        }
    
        
//        print(locations.last!)
//        if locations.last!.distanceFromLocation(location!) > CLLocationDistance(1.0){
//            location = locations.last!
//            User.currentUser?.current_location = location
//            goToLocation(location!)
//        }
//    }

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
    
//    func updateMap() {
//        mapView.removeAnnotations(mapView.annotations)
//        if Activity.current_activity == nil{
//            for activity in activities{
//              let annotation = MapAnnotation(activity: activity)
//                
//              mapView.addAnnotation(annotation)
//            }
//        }else{
//            print("joined activity")
//            let annotation = MapAnnotation(activity: Activity.current_activity!)
//            mapView.addAnnotation(annotation)
//            //start navigation
//            
//        }
//        
//    }
    
    
//    // lock my region
//    func goToLocation(currlocation: CLLocation?) {
//        if let myLocation
//            = locationManager.location {
//            let center = CLLocationCoordinate2D(latitude: myLocation.coordinate.latitude, longitude: myLocation.coordinate.longitude)
//            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
////            let span = MKCoordinateSpanMake(0.1, 0.1)
////            let region = MKCoordinateRegionMake(myLocation.coordinate, span)
//            //mapView.setRegion(region, animated: false)
////            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
////            locationManager.distanceFilter = 200
//            //print(User.currentUser?.current_location)
//        }
//
//    }
    
    // This function is created for debug.

    


}
