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



class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var arrivalTimeLabel: UILabel!
    @IBOutlet weak var exitActivityButton: UIButton!

    var location: CLLocation!
    var locationManager = CLLocationManager()
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        let status = CLLocationManager.authorizationStatus()
        
        if status == .AuthorizedWhenInUse {
            mapView.showsUserLocation = true
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
        self.viewDidLoad()
    }
    
    func userExitedActivity() {
        //update map, show all requests in the area

        toolBar.hidden = true
        arrivalTimeLabel.hidden = true
        self.viewDidLoad()
    }
    
    func userExitedActivity(sender: UIButton!) {
        userExitedActivity()
    }
    
    @IBAction func unwindToMapView(sender: UIStoryboardSegue) {
        
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
        if location == nil || locations.last!.distanceFromLocation(location) > CLLocationDistance(1.0){
            location = locations.last
            User.currentUser?.current_location = location
            goToLocation(location)
        }
    }

    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        if let annotation = annotation as? MapAnnotation {
            
            var view = mapView.dequeueReusableAnnotationViewWithIdentifier("id")
            if view == nil {
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "id")
            }
            
            view!.canShowCallout = true
            view!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure) as UIView
            let button = CheckButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
            view!.leftCalloutAccessoryView = button

            let mapDetailView = MapDetailView()
            mapDetailView.annotation = annotation
            view!.detailCalloutAccessoryView = mapDetailView
            return view
        }
        return nil
    }
    
    func mapView(mapView: MKMapView, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == annotationView.rightCalloutAccessoryView {
            
            self.performSegueWithIdentifier("toActivityProfileSegue", sender: self)
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func loadMap() {
        mapView.removeAnnotations(mapView.annotations)
        let info = MapAnnotation()
        mapView.addAnnotation(info)
    }
    
    func goToLocation(location: CLLocation) {
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
//        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
//        locationManager.distanceFilter = 200
        print(User.currentUser?.current_location)
        mapView.setRegion(region, animated: false)
    }

}
