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
    
    @IBOutlet weak var redoBtn: UIButton!
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
    var locationTimer: NSTimer!
    var userlocationTimer: NSTimer!
    var memberLocations = [GMSMarker]()
    var directionPolyLines = [GMSPolyline]()
    
    
    var mapView: GMSMapView!
    
    func fetchCurrentUserInfo() {
        let hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        hud.mode = .AnnularDeterminate
        hud.color = UIColor.flatWhiteColor()
        hud.detailsLabelColor = UIColor.flatBlackColor()
        hud.activityIndicatorColor = UIColor.flatBlackColor()
        hud.dimBackground = true
        hud.detailsLabelText = "Loading..."
        hud.margin = 12.0
        
        
        // get User's undergoing activity
        if let currentUser = PFUser.currentUser() {
            print("current user detected: \(currentUser.username)")
            currentUser.fetchInBackgroundWithBlock({ (updatedUser: PFObject?, error: NSError?) in
                if updatedUser != nil && error == nil {
                    hud.progress = 0.2
                    User.currentUser = User(pfUser: currentUser)
                    if let currentActivityId = User.currentUser?.currentActivityId {
                        Log.info("Current user has an undergoing activity id = \(currentActivityId)")
                        hud.progress = 0.5
                        Activity.getCurrentActivity(currentActivityId, successHandler: { (activity: Activity) in
                            Activity.current_activity = activity
                            hud.progress = 1.0
                            NSNotificationCenter.defaultCenter().postNotificationName("userJoinedNotification", object: nil)
                            }, failureHandler: { (error: NSError?) in
                                Log.error(error?.localizedDescription)
                        })
                    } else {
                        hud.progress = 1.0
                        hud.hide(true)
                        Log.info("Current user does not have an undergoing activity")
                    }
                    
                } else {
                    hud.progress = 1.0
                    hud.hide(true)
                    Log.error("failed in fetchInBackgroundWithBlock \(error?.localizedDescription)")
                    
                }
            })
        }
        
    
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Log.info("Map View Did Load")
        Log.info(PFUser.currentUser()?.username)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MapViewController.userJoinedActivity), name: "userJoinedNotification", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MapViewController.userExitedActivity), name: "userExitedNotification", object: nil)
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        if Activity.current_activity != nil {
            Log.info("Activity.current_activity != nil")
            Log.info("\(Activity.current_activity!.activityId) \(Activity.current_activity!.title)")
        }
        
        setupGoogleMap()
        fetchCurrentUserInfo()

        activityPanelTag.backgroundColor = ColorTheme.sharedInstance.activityPanelTagColor
        activityNameLabel.textColor = ColorTheme.sharedInstance.activityPanelTextColor
  
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
        if self.locationTimer != nil {
            Log.info("removing member location tracking")
            self.locationTimer.invalidate()
        }
        if self.userlocationTimer != nil {
            Log.info("removing user location tracking")
            self.userlocationTimer.invalidate()
        }
        self.memberLocations.removeAll()
        Log.info("observer removed")
    }
    
    func setupMapButton(btn: UIButton) {
        btn.layer.cornerRadius = 20.0
        btn.layer.masksToBounds = false
        
        btn.layer.shadowOpacity = 0.5
        btn.layer.shadowRadius = 1
        btn.layer.shadowOffset = CGSizeMake(0.0, 1.0)
        
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
        mapView.padding = UIEdgeInsetsMake(0, 0, 0, 0);
        
        mapView.delegate = self
        self.view.insertSubview(mapView, atIndex: 0)
        
        self.activityPanelBottomPos.constant -= self.ActivityPanelViewHeight.constant
        self.view.layoutIfNeeded()
        
        
        self.pathBtn.alpha = 0
        self.navigationBtn.alpha = 0
        setupMapButton(self.pathBtn)
        setupMapButton(self.navigationBtn)
        setupMapButton(self.redoBtn)
    }
    
    func getMapBoundingBox() -> GMSCoordinateBounds {
        let visibleRegion = mapView.projection.visibleRegion()
        return GMSCoordinateBounds(region:visibleRegion)
    }
    
    func updateMapMarkers() {
        Log.info("updating map search")
        mapView.clear()
        //pass in current map sw and ne point location
        let bounds = getMapBoundingBox()
        let SW = CLLocation(latitude: bounds.southWest.latitude, longitude: bounds.southWest.longitude)
        let NE = CLLocation(latitude: bounds.northEast.latitude, longitude: bounds.northEast.longitude)
        //only get activites within certain range
        
        ParseAPI.getActivites(SW, locNE: NE) { (acts, error) in
            if error == nil {
                self.activities = acts
                for act in self.activities {
                    self.addMapMarker(act)
                }
            }else {
                Log.error("Unable to get activites")
            }
        }
        self.view.layoutIfNeeded()
    }
    
    
    
    func addMapMarker(act: Activity) {
        act.fetchGroupMember({ (groupMembers: [GroupMember]) in
            if Activity.current_activity != nil {
                self.updateMemberLocations()
            }
            let marker = GMSMarker()
            marker.position = act.location
            marker.title = act.title
            marker.snippet = act.overview
            marker.map = self.mapView
            
            //set image when adding marker
            let mapDetailView = MapDetailView(frame: CGRect(origin: CGPointZero, size: CGSize(width: 285, height: 75)))
            let annotation = MapAnnotation(activity: act)
            mapDetailView.annotation = annotation
            
            marker.userData = mapDetailView
            
            }, failureHandler: { (error: NSError?) -> () in
                Log.info(error?.localizedDescription)
        })
        
    }
    
    func updateMemberLocations() {
        
        if let members = Activity.current_activity!.group?.groupMembers{
            
            if members.isEmpty == false {
                var index = 0
                for member in members {
                    if member.userId != PFUser.currentUser()?.objectId && member.joined {
                        member.getLocation((Activity.current_activity?.activityId)!, successHandler: { (loc:PFGeoPoint) in
                            //add loc marker
                            let circleCenter = CLLocationCoordinate2D(latitude: loc.latitude, longitude: loc.longitude)
                            if self.memberLocations.isEmpty {
                                //store circles
                                let marker = GMSMarker(position: circleCenter)
                                self.memberLocations.append(marker)
                                if let avatarFile = member.avatar {
                                    avatarFile.getDataInBackgroundWithBlock({
                                        (result, error) in
                                        let iconView = UIImageView(image: UIImage(data: result!)!)
                                        iconView.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
                                        iconView.layer.cornerRadius = 15
                                        iconView.layer.borderWidth = 2
                                        iconView.layer.borderColor = UIColor.flatWhiteColor().CGColor
                                        iconView.clipsToBounds = true
                                        marker.iconView = iconView
                                        marker.map = self.mapView
                                    })
                                }
                                
                            }else {
                                //update circle locations
                                let marker = self.memberLocations[index]
                                marker.position = circleCenter
                            }
                            index += 1
                            }, failureHandler: { (error:NSError?) in
                                Log.error("Updating member user location failure")
                        })
                    }
                }
            }
        }
    }
    
    func updateUserLocation() {
        GroupMember.updateLocation((Activity.current_activity?.activityId)!, userId: (PFUser.currentUser()?.objectId)!, location: PFGeoPoint(location: self.mapView.myLocation), successHandler: {
            Log.info("Updating current user location succeed")
        }) { (error: NSError?) in
            Log.error("Updating current user location failure")
        }
        // start navigation
        if let destination = Activity.current_activity?.location {
            if let myLocation  = self.mapView.myLocation {
                GoogleDirectionsAPI.direction(myLocation.coordinate, destination: destination) { (routes: [Route]!, error: NSError!) in
                    self.startNavigation(routes[0].steps)
                    
                }
            }
        }
    }
    
    func drawPolyLines() {
        if directionPolyLines.isEmpty == false {
            for line in directionPolyLines {
                line.map = nil
            }
            directionPolyLines.removeAll()
        }
        //add polylines
        for step in steps {
            if let polyLine = step.polyLine {
                let path = GMSPath(fromEncodedPath: polyLine)
                let line = GMSPolyline(path: path)
                directionPolyLines.append(line)
                line.strokeWidth = 5
                line.strokeColor = UIColor(red: 0.0, green: 0.5, blue: 0.5, alpha: 0.5)
                line.map = mapView
                
            }
        }
    }
    
    @IBAction func togglePolyLines(sender: AnyObject) {
        showPath = !showPath
        if showPath {
            self.drawPolyLines()
        }else {
            //clear all polyline
            if directionPolyLines.isEmpty == false {
                for line in directionPolyLines {
                    line.map = nil
                }
                directionPolyLines.removeAll()
            }
        }
    }
    
    @IBAction func onRedoSearch(sender: AnyObject) {
        //update activities
        updateMapMarkers()
    }
    @IBAction func onExternalNavigate(sender: AnyObject) {
        let place = Activity.current_activity?.location
        
        if (UIApplication.sharedApplication().canOpenURL(NSURL(string:"comgooglemaps://")!)) {
            UIApplication.sharedApplication().openURL(NSURL(string:
                "comgooglemaps://?saddr=&daddr=\(place!.latitude),\(place!.longitude)&directionsmode=driving")!)
            
        } else {
            UIApplication.sharedApplication().openURL(NSURL(string: "http://maps.apple.com/?daddr=\(place!.latitude),\(place!.longitude)&dirflg=d&t=m")!)
        }
        
    }
    
    func startNavigation(steps: [Route.Step]) {
        self.steps = steps
        //adjust map bounds
        let bounds = getMapBoundingBox()
        
        self.mapView.animateWithCameraUpdate(GMSCameraUpdate.fitBounds(bounds.includingCoordinate(Activity.current_activity!.location), withPadding: 50.0))
        self.drawPolyLines()
        
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
                updateMapMarkers()
            }
            if Activity.current_activity != nil {
                //uploading user current location
                userlocationTimer = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: #selector(MapViewController.updateUserLocation), userInfo: nil, repeats: false)
                
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
        mapView.clear()
        self.addMapMarker(Activity.current_activity!)
        showPath = true
        self.updateUserLocation()
        //start tracking user location
        locationTimer = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: #selector(MapViewController.updateMemberLocations), userInfo: nil, repeats: true)
        
        activityNameLabel.text = Activity.current_activity?.title
        if activityPanelBottomPos.constant == -ActivityPanelViewHeight.constant {
            UIView.animateWithDuration(0.3) {
                self.mapView.padding = UIEdgeInsetsMake(0, 0, 48, 0);
                self.activityPanelBottomPos.constant += self.ActivityPanelViewHeight.constant
                self.view.layoutIfNeeded()
                self.navigationBtn.alpha = 1
                self.pathBtn.alpha = 1
                self.redoBtn.alpha = 0
            }
        }
        
    }
    
    func userExitedActivity() {
        Log.info("userExitedActivity")
        if activityPanelBottomPos.constant == 0 {
            UIView.animateWithDuration(0.2) {
                self.mapView.padding = UIEdgeInsetsMake(0, 0, 0, 0);
                
                self.activityPanelBottomPos.constant -= self.ActivityPanelViewHeight.constant
                self.view.layoutIfNeeded()
            }
        }
        
        if let activity = Activity.current_activity {
            Log.info("found current activity")
            activity.exitActivity({
                Log.info("clear User's current Activity successfully")
                if self.locationTimer != nil {
                    self.locationTimer.invalidate()
                }
                if self.userlocationTimer != nil {
                    self.userlocationTimer.invalidate()
                }
                self.memberLocations.removeAll()
                
                //animate map view camera
                let update = GMSCameraUpdate.setTarget(self.mapView.myLocation!.coordinate, zoom: 14.0)
                self.mapView.animateWithCameraUpdate(update)
                //remove polyline
                self.mapView.clear()
                //update map, show all requests in the area
                self.updateMapMarkers()
                
                MBProgressHUD.hideHUDForView(self.view, animated: true)
                
                }, failureHandler: { (error: NSError?) in
                    Log.error("failed to clear User's current Activity")
                    Log.error(error?.localizedDescription)
                    MBProgressHUD.hideHUDForView(self.view, animated: true)
                    
            })
            
        } else {
            Log.warning("No current activity. Shoud not reach here")
        }
        
        UIView.animateWithDuration(0.3) {
            self.pathBtn.alpha = 0
            self.navigationBtn.alpha = 0
            self.redoBtn.alpha = 1
        }
    }
    
    
    
    @IBAction func unwindToMapView(sender: UIStoryboardSegue) {
        Log.info("unwindToMapView invoked")
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        
        // MARK: check if it is unwinded from FriendsViewController
        // if so, it means this is gonna create a brand new activity
        if let vc = sender.sourceViewController as? FriendsViewController {
            let activity = vc.activityInProgress
            Log.info("From FriendsViewController")
            
            activity?.saveToBackend({ (activityId: String) -> () in
                Log.info("saved successfully")
                
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

