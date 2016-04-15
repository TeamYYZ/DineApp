//
//  MapViewController.swift
//  Dine
//
//  Created by you wu on 3/13/16.
//  Copyright © 2016 YYZ. All rights reserved.
//

import UIKit
import GoogleMaps
import MBProgressHUD

class MapViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate {
    @IBOutlet weak var navigationBtn: UIButton!
    @IBOutlet weak var pathBtn: UIButton!
    
    @IBOutlet weak var currentActivityPanelView: CurrentActivityBottomBar!
    
    @IBOutlet weak var ActivityPanelViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var activityPanelBottomPos: NSLayoutConstraint!
    
    @IBOutlet weak var activityPanelTag: UIView!
    
    @IBOutlet weak var activityNameLabel: UILabel!
    
    var locationManager = CLLocationManager()
    var activities = [Activity]()
    var steps : [Route.Step]!
    var currentStep = 0
    var searchUserLocation = true
    var showPath = false
    
    var mapView: GMSMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Log.info("Map View Did Load")
        Log.info(PFUser.currentUser()?.username)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MapViewController.userJoinedActivity), name: "userJoinedNotification", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MapViewController.userExitedActivity), name: "userExitedNotification", object: nil)
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        self.activityPanelBottomPos.constant -= self.ActivityPanelViewHeight.constant
        self.view.layoutIfNeeded()


        self.pathBtn.transform.tx = 100
        self.navigationBtn.transform.tx = 150

        // get User's undergoing activity
        if let currentActivityId = User.currentUser?.currentActivityId {
            Log.info(currentActivityId)
            Activity.getCurrentActivity(currentActivityId, successHandler: { (activity: Activity) in
                NSNotificationCenter.defaultCenter().postNotificationName("userJoinedNotification", object: nil)
                }, failureHandler: { (error: NSError?) in
                    Log.error(error?.localizedDescription)
            })
        }
        
        activityPanelTag.backgroundColor = ColorTheme.sharedInstance.activityPanelTagColor
        activityNameLabel.textColor = ColorTheme.sharedInstance.activityPanelTextColor
        
        setupGoogleMap()
        updateMapMarkers()
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
    }

    override func viewWillAppear(animated: Bool) {
        Log.info("observer added")
        super.viewWillAppear(animated)
        self.setNavigationBarItem()
        mapView.addObserver(self, forKeyPath: "myLocation", options: NSKeyValueObservingOptions.New, context: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        mapView.removeObserver(self, forKeyPath: "myLocation", context: nil)
        Log.info("observer removed")
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
        mapView.padding = UIEdgeInsetsMake(0, 0, 48, 0);

        mapView.delegate = self
        self.view.insertSubview(mapView, atIndex: 0)
        
    }
    
    func updateMapMarkers() {
        //pass in current map center point
        //only get activites within certain range
        
        ParseAPI.getActivites { (acts, error) in
            self.activities = acts
            for act in self.activities {
            act.fetchGroupMember({ (groupMembers: [GroupMember]) in
                self.addMapMarker(act)
            }, failureHandler: { (error: NSError?) -> () in
                Log.info(error?.localizedDescription)
        })
            }
        }
        self.view.layoutIfNeeded()
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
    
    @IBAction func onRedoSearch(sender: AnyObject) {
        //update activities
        updateMapMarkers()
    }
    
    func mapView(mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {

        let infoWindow = UIView(frame: CGRect(origin: CGPointZero, size: CGSize(width: 285, height: 75)))
        infoWindow.backgroundColor = UIColor.flatWhiteColor()
        infoWindow.layer.cornerRadius = 5
        infoWindow.clipsToBounds = true
        infoWindow.addSubview(marker.userData as! MapDetailView)

        return infoWindow

    }
    

    func mapView(mapView: GMSMapView, didTapInfoWindowOfMarker marker: GMSMarker) {
        let view = marker.userData as! MapDetailView
        let act = view.annotation.activity
        self.performSegueWithIdentifier("toActivityProfileSegue", sender: act)
    }
    
    
    //control camera update
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if let myLocation: CLLocation = change![NSKeyValueChangeNewKey] as? CLLocation {
            if searchUserLocation {
                    let update = GMSCameraUpdate.setTarget(myLocation.coordinate, zoom: 14.0)
                    mapView.moveCamera(update)
                    searchUserLocation = false
            }

        }
    }
    
    
    func userJoinedActivity() {
        MBProgressHUD.hideHUDForView(self.view, animated: true)
        Log.info("user joined activity")
        UIView.animateWithDuration(1, delay: 0.0, options:[UIViewAnimationOptions.Repeat, UIViewAnimationOptions.Autoreverse], animations: {
            self.activityPanelTag.backgroundColor = ColorTheme.sharedInstance.activityPanelTagColor
            self.activityPanelTag.backgroundColor = ColorTheme.sharedInstance.activityPanelTagAnimateColor
            }, completion: nil)
        activityNameLabel.text = Activity.current_activity?.title
        if activityPanelBottomPos.constant == -ActivityPanelViewHeight.constant {
            UIView.animateWithDuration(0.3) {
                self.activityPanelBottomPos.constant += self.ActivityPanelViewHeight.constant
                self.view.layoutIfNeeded()
                self.navigationBtn.transform.tx = 0
                self.pathBtn.transform.tx = 0
            }
        }

    }
    
    func userExitedActivity() {
        if activityPanelBottomPos.constant == 0 {
            UIView.animateWithDuration(0.2) {
                self.activityPanelBottomPos.constant -= self.ActivityPanelViewHeight.constant
                self.view.layoutIfNeeded()
            }
        }
        
        if let activity = Activity.current_activity {
            Log.info("found current activity")
            activity.exitActivity({
                Log.info("clear User's current Activity successfully")
                MBProgressHUD.hideHUDForView(self.view, animated: true)

                }, failureHandler: { (error: NSError?) in
                    Log.error("failed to clear User's current Activity")
                    Log.error(error?.localizedDescription)
                    MBProgressHUD.hideHUDForView(self.view, animated: true)

            })
            
        } else {
            Log.warning("No current activity. Shoud not reach here")
        }
        //update map, show all requests in the area
        updateMapMarkers()
        //remove polyline
        mapView.clear()
        
        self.pathBtn.transform.tx = 100
        self.navigationBtn.transform.tx = 150
    }
    
    
    func startNavigation(steps: [Route.Step]) {
        self.steps = steps
        self.updateMapMarkers()
        self.drawPolyLines()
    }
    
    @IBAction func unwindToMapView(sender: UIStoryboardSegue) {
        Log.info("unwindToMapView invoked")
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
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

            activity?.saveToBackend({ (activityId: String) -> () in
                Log.info("saved successfully")
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
                        if invitedUser == PFUser.currentUser()?.objectId {
                            continue
                        }
                        
                        Log.info("invitedUser \(invitedUser)")
                        Log.info(User.currentUser!.screenName!)
                        let notification = UserNotification(type: .Invitation, content: "Invite you to a activity", senderId: activity!.owner.objectId!, receiverId: invitedUser, associatedId: activity!.activityId, senderName: User.currentUser!.screenName!, senderAvatarPFFile: User.currentUser?.avatarImagePFFile)
                        notificationList.append(notification.getDict())
                    }
                    
                    UserNotification.broadcastInBackend(notificationList, successHandler: {
                        Log.info("notificationSuccess")
                        }, failureHandler: { (error: NSError?) in
                            Log.info(error?.localizedDescription)
                    })
                }
            
                
                Activity.current_activity = activity
                
                NSNotificationCenter.defaultCenter().postNotificationName("userJoinedNotification", object: nil)
                
                }, failureHandler: { (error: NSError?) -> () in
                    Log.info("something wrong...")
                    Log.info(error?.localizedDescription)
            })
            
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toActivityProfileSegue" {
            
            if let activityProfileViewController = segue.destinationViewController as? ActivityProfileViewController {
                if let act = Activity.current_activity {
                    Log.info("current_activity TRUE")
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
    
}

extension MapViewController : SlideMenuControllerDelegate {
    
    func leftWillOpen() {
        //Log.info("SlideMenuControllerDelegate: leftWillOpen")
    }
    
    func leftDidOpen() {
        //Log.info("SlideMenuControllerDelegate: leftDidOpen")
    }
    
    func leftWillClose() {
        //Log.info("SlideMenuControllerDelegate: leftWillClose")
    }
    
    func leftDidClose() {
        //Log.info("SlideMenuControllerDelegate: leftDidClose")
    }
    
    func rightWillOpen() {
        //Log.info("SlideMenuControllerDelegate: rightWillOpen")
    }
    
    func rightDidOpen() {
        //Log.info("SlideMenuControllerDelegate: rightDidOpen")
    }
    
    func rightWillClose() {
        //Log.info("SlideMenuControllerDelegate: rightWillClose")
    }
    
    func rightDidClose() {
        //Log.info("SlideMenuControllerDelegate: rightDidClose")
    }
}

