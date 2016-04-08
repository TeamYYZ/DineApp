//
//  MapViewController.swift
//  Dine
//
//  Created by you wu on 3/13/16.
//  Copyright © 2016 YYZ. All rights reserved.
//

import UIKit
import GoogleMaps

class MapViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate {
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var arrivalTimeLabel: UILabel!
    @IBOutlet weak var exitActivityButton: UIButton!
    
    @IBOutlet weak var directionsLabel: UILabel!
    @IBOutlet weak var directionsView: UIView!
    
    var locationManager = CLLocationManager()
    var activities = [Activity]()
    var steps : [Route.Step]!
    var currentStep = 0
    var cameraMoveWithUser = true
    var inNavigation = false
    
    var mapView: GMSMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(PFUser.currentUser()?.username)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MapViewController.userJoinedActivity), name: "userJoinedNotification", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MapViewController.userExitedActivity as (MapViewController) -> () -> ()), name: "userExitedNotification", object: nil)
        
        toolBar.hidden = true
        arrivalTimeLabel.hidden = true
        directionsView.hidden = true
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        exitActivityButton.addTarget(self, action: #selector(MapViewController.userExitedActivity(_:)), forControlEvents: .TouchUpInside)
        
        setupGoogleMap()
        updateMapMarkers()
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
    }

    override func viewWillAppear(animated: Bool) {
        print("observer added")
        super.viewWillAppear(animated)
        self.setNavigationBarItem()
        mapView.addObserver(self, forKeyPath: "myLocation", options: NSKeyValueObservingOptions.New, context: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        mapView.removeObserver(self, forKeyPath: "myLocation", context: nil)
        print("observer removed")
    }
    
    func setupGoogleMap() {
        let bound = self.view.bounds
        var bounds: CGRect!
        
        if let navHeight = self.navigationController?.navigationBar.bounds.height {
            bounds = CGRect(x: 0.0, y: navHeight, width: bound.width, height: bound.height - navHeight)
        }else {
            bounds = self.view.bounds
        }
        
        mapView = GMSMapView.init(frame: bounds)
        mapView.settings.compassButton = true
        mapView.settings.myLocationButton = true
        mapView.myLocationEnabled = true
        
        mapView.delegate = self
        self.view.insertSubview(mapView, belowSubview: directionsView)
    }
    
    func updateMapMarkers() {
        ParseAPI.getActivites { (acts, error) in
            self.activities = acts
            for act in self.activities {
                self.addMapMarker(act)
            }
        }
    }
    
    func addMapMarker(act: Activity) {
        let marker = GMSMarker()
        marker.position = act.location
        marker.title = act.title
        marker.snippet = act.overview
        marker.map = mapView
        
        //set image when adding marker
        let mapDetailView = MapDetailView(frame: CGRect(origin: CGPointZero, size: CGSize(width: 285, height: 75)))
        let annotation = MapAnnotation(activity: act)
        mapDetailView.annotation = annotation
        
        marker.userData = mapDetailView
    }
    
    func drawPolyLines() {
        //add polylines
        for step in steps {
            if let polyLine = step.polyLine {
                let path = GMSPath(fromEncodedPath: polyLine)
                let line = GMSPolyline(path: path)
                line.strokeWidth = 5
                line.strokeColor = UIColor(red: 0.0, green: 0.5, blue: 0.5, alpha: 0.5)
                line.map = mapView
            }
        }
    }
    
    func updateMapCamera() {
        let start = steps[currentStep].startLoc!.coordinate
        let end = steps[currentStep].endLoc!.coordinate
        let bounds = GMSCoordinateBounds(coordinate: start, coordinate: end)
        let update = GMSCameraUpdate.fitBounds(bounds, withPadding: 50.0)
        mapView.moveCamera(update)
        
        mapView.animateToBearing(GoogleDirectionsAPI.getBearingBetweenTwoPoints(steps[currentStep].startLoc!, point2: steps[currentStep].endLoc!) )
    }
    
    func mapView(mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {

        let infoWindow = UIView(frame: CGRect(origin: CGPointZero, size: CGSize(width: 285, height: 75)))
        infoWindow.backgroundColor = UIColor.flatWhiteColor()
        infoWindow.layer.cornerRadius = 5
        infoWindow.clipsToBounds = true
        infoWindow.addSubview(marker.userData as! MapDetailView)

        return infoWindow

    }
    
    func mapView(mapView: GMSMapView, didTapMarker marker: GMSMarker) -> Bool {
        cameraMoveWithUser = false
        return false
    }
    
    func mapView(mapView: GMSMapView, didTapAtCoordinate coordinate: CLLocationCoordinate2D) {
        cameraMoveWithUser = true
    }
    func mapView(mapView: GMSMapView, didTapInfoWindowOfMarker marker: GMSMarker) {
        let view = marker.userData as! MapDetailView
        let act = view.annotation.activity
        self.performSegueWithIdentifier("toActivityProfileSegue", sender: act)
    }
    
    
    //control camera update
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if let myLocation: CLLocation = change![NSKeyValueChangeNewKey] as? CLLocation {
            if cameraMoveWithUser {
                    let update = GMSCameraUpdate.setTarget(myLocation.coordinate, zoom: 14.0)
                    mapView.moveCamera(update)
                //}
            }else if (inNavigation){
                //start navigation
                
            let dist = myLocation.distanceFromLocation(steps[currentStep].endLoc!)
            if dist < 50 {
                updateMapCamera()
                print("update direction.....")
                currentStep += 1
            }
            if let instruction = steps[currentStep].instruction {
                let attrStr = try! NSAttributedString(
                    data: instruction.dataUsingEncoding(NSUnicodeStringEncoding, allowLossyConversion: true)!,
                    options: [ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType],
                    documentAttributes: nil)
                self.directionsLabel.attributedText = attrStr
            }
            }

        }
    }
    
    
    func userJoinedActivity() {
        //update map, only show selected point and direction
        
        //always show pin view
        print("user joined activity")
        toolBar.hidden = false
        arrivalTimeLabel.hidden = false
        directionsView.hidden = false
        //updateMap()
        

    }
    
    func userExitedActivity() {
        //update map, show all requests in the area
        
        toolBar.hidden = true
        arrivalTimeLabel.hidden = true
        directionsView.hidden = true

        updateMapMarkers()
        //remove polyline
        mapView.clear()
        cameraMoveWithUser = true
        inNavigation = false
        mapView.animateToViewingAngle(0)
        //updateMap()
    }
    
    func userExitedActivity(sender: UIButton!) {
        userExitedActivity()
    }
    
    func startNavigation(steps: [Route.Step]) {
        self.steps = steps
        self.updateMapMarkers()
        self.drawPolyLines()
        self.cameraMoveWithUser = false
        self.inNavigation = true
        self.updateMapCamera()
        self.mapView.animateToViewingAngle(45)
    }
    
    @IBAction func unwindToMapView(sender: UIStoryboardSegue) {
        if let vc = sender.sourceViewController as? ActivityProfileViewController {
            let activity = vc.activity
            if let destination = activity?.location {
                if let myLocation  = self.mapView.myLocation {
                    GoogleDirectionsAPI.direction(myLocation.coordinate, destination: destination) { (routes: [Route]!, error: NSError!) in
                        self.startNavigation(routes[0].steps)

                    }
                }
            }
        }
        
        
        if let vc = sender.sourceViewController as? FriendsViewController {
            let activity = vc.activityInProgress
            //save to Parse
            // show Progress to prevent accessing null activityId
            activity?.saveToBackend({ (activityId: String) -> () in
                print("saved successfully")
                //update direction info
                if let destination = activity?.location {
                    if let myLocation  = self.mapView.myLocation {
                        GoogleDirectionsAPI.direction(myLocation.coordinate, destination: destination) { (routes: [Route]!, error: NSError!) in
                            self.startNavigation(routes[0].steps)
                        }
                    }
                }
                
                
                if let invitedUserList = activity?.group?.getUserIdList() {
                    var notificationList = [NSDictionary]()
                    for invitedUser in invitedUserList {
                        print("invitedUser \(invitedUser)")
                        print(User.currentUser!.screenName!)
                        let notification = UserNotification(type: .Invitation, content: "Invite you to a activity", senderId: activity!.owner.objectId!, receiverId: invitedUser, associatedId: activity!.activityId, senderName: User.currentUser!.screenName!, senderAvatarPFFile: User.currentUser?.avatarImagePFFile)
                        print("Dict print")
                        print(notification.getDict())
                        notificationList.append(notification.getDict())
                    }
                    
                    UserNotification.broadcastInBackend(notificationList, successHandler: {
                        print("notificationSuccess")
                        }, failureHandler: { (error: NSError?) in
                            print(error?.localizedDescription)
                    })
                }
                
                Activity.current_activity = activity
                
                NSNotificationCenter.defaultCenter().postNotificationName("userJoinedNotification", object: nil)
                
                }, failureHandler: { (error: NSError?) -> () in
                    print("something wrong...")
                    print(error?.localizedDescription)
            })
            
        }
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let activityProfileViewController = segue.destinationViewController as? ActivityProfileViewController {
            if let act = Activity.current_activity {
                print("current_activity TRUE")
                activityProfileViewController.activity = act
            }else {
                let act = sender as! Activity
                activityProfileViewController.activity = act
            }
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
    
}

extension MapViewController : SlideMenuControllerDelegate {
    
    func leftWillOpen() {
        print("SlideMenuControllerDelegate: leftWillOpen")
    }
    
    func leftDidOpen() {
        print("SlideMenuControllerDelegate: leftDidOpen")
    }
    
    func leftWillClose() {
        print("SlideMenuControllerDelegate: leftWillClose")
    }
    
    func leftDidClose() {
        print("SlideMenuControllerDelegate: leftDidClose")
    }
    
    func rightWillOpen() {
        print("SlideMenuControllerDelegate: rightWillOpen")
    }
    
    func rightDidOpen() {
        print("SlideMenuControllerDelegate: rightDidOpen")
    }
    
    func rightWillClose() {
        print("SlideMenuControllerDelegate: rightWillClose")
    }
    
    func rightDidClose() {
        print("SlideMenuControllerDelegate: rightDidClose")
    }
}

