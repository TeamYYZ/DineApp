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
import JSSAlertView

class MapViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate {
    
    @IBOutlet weak var navigationBtn: UIButton!
    @IBOutlet weak var pathBtn: UIButton!
    @IBOutlet weak var redoBtn: UIButton!
    @IBOutlet weak var currentActivityPanelView: CurrentActivityBottomBar!
    @IBOutlet weak var activityPanelBottomPos: NSLayoutConstraint!
    @IBOutlet weak var newActivityBottomPos: NSLayoutConstraint!
    @IBOutlet weak var activityNameLabel: UILabel!
    @IBOutlet weak var activityRestuarantLabel: UILabel!
    
    @IBOutlet weak var panelIcon: PanelIcon!
    
    @IBOutlet weak var borderView: UIView!
    
    @IBOutlet weak var newActivityButton: NewActivityButton!
    
    static let NCObserverName = "MAPVIEWOBNAME"
    var locationManager = CLLocationManager()
    var activities = [Activity]()
    var steps : [Route.Step]? {
        didSet {
            pathBtn.hidden = false
        }
    }
    var isObservingMyLocation = false
    var currentStep = 0
    var searchUserLocation = true
    var didFindUserLocation = false
    var showPath = false
    var locationTimer: NSTimer?
    var mylocationTimer: NSTimer?
    var memberLocations = [String: GMSMarker]()
    var directionPolyLines = [GMSPolyline]()
    
    var mapView: GMSMapView!
    
    func fetchCurrentUserInfo() {
        let hud = MBProgressHUD.showLoadingHUDToView(self.view, animated: true)
        
        // get User's undergoing activity
        if let currentUser = PFUser.currentUser() {
            print("current user detected: \(currentUser.username)")
            currentUser.fetchInBackgroundWithBlock({ (updatedUser: PFObject?, error: NSError?) in
                if updatedUser != nil && error == nil {
                    hud.progress = 0.2
                    User.currentUser = User(pfUser: currentUser)
                    if let currentActivityId = User.currentUser?.currentActivityId {
                        Log.info("Current user has an undergoing activity id = \(currentActivityId)")
                        hud.progress    = 0.5
                        Activity.getCurrentActivity(currentActivityId, successHandler: { (activity: Activity) in
                            Activity.current_activity = activity
                            hud.progress = 1.0
                            NSNotificationCenter.defaultCenter().postNotificationName("userJoinedNotification", object: nil)
                            }, failureHandler: { (error: NSError?) in
                                hud.progress = 1.0
                                hud.hide(true)
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
  
    func pushToJoinActivity(notification: NSNotification) {
        guard let activityId = notification.userInfo?["activityId"] as? String else {
            return
        }
        
//        let alertview = JSSAlertView().show(self, title: "Invitation", text: "You received a dinning invitation from your friend", buttonText: "Detail", cancelButtonText: "Ignore")
//        alertview.addAction {
//            let storyBoard = UIStoryboard(name: "ActivityProfileViewController", bundle: NSBundle.mainBundle())
//            let activityVC = storyBoard.instantiateViewControllerWithIdentifier("ActivityProfileVC") as! ActivityProfileViewController
//            activityVC.previewIndicator.isPreview = true
//            activityVC.previewIndicator.activityId = activityId
//            activityVC.previewIndicator.mapVC = self
//            self.navigationController?.pushViewController(activityVC, animated: true)
//        }
//        
//        alertview.addCancelAction{
//            Log.info("Ignored")
//        }
        

    
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        Log.info("Map View Did Load")
        Log.info(PFUser.currentUser()?.username)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MapViewController.userJoinedActivity), name: "userJoinedNotification", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MapViewController.userExitedActivity), name: "userExitedNotification", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MapViewController.pushToJoinActivity(_:)), name: MapViewController.NCObserverName, object: nil)
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        if Activity.current_activity != nil {
            Log.info("Activity.current_activity != nil")
            Log.info("\(Activity.current_activity!.activityId) \(Activity.current_activity!.title)")
        }
        
        
        let navLabel = UILabel()
        navLabel.font = UIFont(name: "Deftone Stylus", size: 22.0)
        navLabel.text = " Dine "
        navLabel.shadowOffset = CGSize(width: 1.2, height: 1.2)
        navLabel.shadowColor = UIColor.flatGrayColor()
        
        navLabel.textColor = UIColor.flatRedColor()
        navLabel.sizeToFit()
        self.navigationItem.titleView = navLabel
        
        self.activityPanelBottomPos.constant = -100
        self.view.layoutIfNeeded()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(MapViewController.handleCurrentActivityPanelTap(_:)))
        self.borderView.addGestureRecognizer(tapGesture)
        
        pathBtn.hidden = true
        setupGoogleMap()
        fetchCurrentUserInfo()
        
        activityNameLabel.textColor = ColorTheme.sharedInstance.activityPanelTextColor
  
    }
    
    func handleCurrentActivityPanelTap(sender: UITapGestureRecognizer) {
        Log.info("Tapped on CAP")
        self.performSegueWithIdentifier("toActivityProfileSegue", sender: nil)
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
    }
    
    func setupTimers() {
        if let locationTimer = self.locationTimer {
            if !locationTimer.valid {
                self.locationTimer = NSTimer.scheduledTimerWithTimeInterval(8, target: self, selector: #selector(MapViewController.updateMemberLocations), userInfo: nil, repeats: true)
            }
        }
        if let mylocationTimer = self.mylocationTimer {
            if !mylocationTimer.valid {
                self.mylocationTimer = NSTimer.scheduledTimerWithTimeInterval(8, target: self, selector: #selector(MapViewController.updateUserLocation), userInfo: nil, repeats: true)
            }
        }
    
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavigationBarItem()
        setupTimers()
    }
    
    override func viewWillDisappear(animated: Bool) {
        if isObservingMyLocation {
            mapView.removeObserver(self, forKeyPath: "myLocation")
            isObservingMyLocation = false
        }
        if let locationTimer = self.locationTimer {
            Log.info("removing member location tracking")
            locationTimer.invalidate()
        }
        if let userlocationTimer = self.mylocationTimer {
            Log.info("removing user location tracking")
            userlocationTimer.invalidate()
        }
        
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
        mapView.myLocationEnabled = true
        mapView.padding = UIEdgeInsetsMake(64, 0, 64, 0);
        
        mapView.delegate = self
        self.view.insertSubview(mapView, atIndex: 0)
        
        self.pathBtn.alpha = 0
        self.navigationBtn.alpha = 0
        setupMapButton(self.pathBtn)
        setupMapButton(self.navigationBtn)
        setupMapButton(self.redoBtn)
        
        
        
        mapView.addObserver(self, forKeyPath: "myLocation", options: NSKeyValueObservingOptions.New, context: nil)
        isObservingMyLocation = true

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
            } else {
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
        guard let currentActivity = Activity.current_activity else {
            Log.error("no current activity found")
            return
        }
        
        // MARK: may lead to memory leak
        currentActivity.fetchGroupMember({ (members: [GroupMember]) in
            for member in members {
                if member.userId == PFUser.currentUser()?.objectId {break}
                guard let loc = member.location else {break}
                let circleCenter = CLLocationCoordinate2D(latitude: loc.latitude, longitude: loc.longitude)
                
                if let marker = self.memberLocations[member.userId] {
                    marker.position = circleCenter
                } else {
                    let marker = GMSMarker(position: circleCenter)
                    if let avatar = member.avatar {
                        avatar.getDataInBackgroundWithBlock({
                            (result: NSData?, error: NSError?) in
                            guard let imageData = result else {return}
                            let iconView = UIImageView()
                            iconView.image = UIImage(data: imageData)
                            iconView.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
                            iconView.layer.cornerRadius = 15
                            iconView.layer.borderWidth = 2
                            iconView.layer.borderColor = UIColor.flatWhiteColor().CGColor
                            iconView.clipsToBounds = true
                            marker.iconView = iconView
                            marker.map = self.mapView
                        })
                    }
                    self.memberLocations[member.userId] = marker
                }
            
            }
            
        }) { (error: NSError?) in
            Log.error(error?.localizedDescription)
        }
        
    }
    
    func updateUserLocation() {
        guard let currentActivity = Activity.current_activity else {
            Log.error("Current Activity not found")
            return
        }
        
        GroupMember.updateLocation(currentActivity.activityId, userId: (PFUser.currentUser()?.objectId)!, location: PFGeoPoint(location: self.mapView.myLocation), successHandler: {
            Log.info("Updating current user location succeed")
        }) { (error: NSError?) in
            Log.error("Updating current user location failure")
        }
    }
    
    func drawPolyLines() {
        if directionPolyLines.isEmpty == false {
            for line in directionPolyLines {
                line.map = nil
            }
            directionPolyLines.removeAll()
        }
        
        guard let stepsToDraw = steps else {
            Log.error("steps are not ready")
            return
        }
        
        //add polylines
        for step in stepsToDraw {
            if let polyLine = step.polyLine {
                let path = GMSPath(fromEncodedPath: polyLine)
                let line = GMSPolyline(path: path)
                directionPolyLines.append(line)
                line.strokeWidth = 5
                line.strokeColor = UIColor(red: 0.2302, green: 0.7771, blue: 0.3159, alpha: 1.0)
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
        guard let place = Activity.current_activity?.location else {
            Log.error("unable to NAV in external NAV App due to bad location")
            return
        }
        
        if (UIApplication.sharedApplication().canOpenURL(NSURL(string:"comgooglemaps://")!)) {
            UIApplication.sharedApplication().openURL(NSURL(string:
                "comgooglemaps://?saddr=&daddr=\(place.latitude),\(place.longitude)&directionsmode=driving")!)
            
        } else {
            UIApplication.sharedApplication().openURL(NSURL(string: "http://maps.apple.com/?daddr=\(place.latitude),\(place.longitude)&dirflg=d&t=m")!)
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
    
    func controlAllViewsOnMap(hidden: Bool) {
        UIView.animateWithDuration(0.1) {
            self.navigationBtn.hidden = hidden
            self.pathBtn.hidden = hidden
            self.redoBtn.hidden = hidden
            self.mapView.settings.myLocationButton = !hidden
        }
        
        if Activity.current_activity != nil {
            return
        }
        
        if hidden {
            UIView.animateWithDuration(0.1) {
                self.newActivityBottomPos.constant = -60
                self.newActivityButton.layoutIfNeeded()
            }
        } else {
            UIView.animateWithDuration(0.1) {
                self.newActivityBottomPos.constant = 12
                self.newActivityButton.layoutIfNeeded()
            }
        }


    }
    
    func mapView(mapView: GMSMapView, willMove gesture: Bool) {
        Log.error("will Move")
        controlAllViewsOnMap(true)
    }
    
    func mapView(mapView: GMSMapView, idleAtCameraPosition position: GMSCameraPosition) {
        Log.error("becomes idle")
        controlAllViewsOnMap(false)
    }
    
    func mapView(mapView: GMSMapView, didTapInfoWindowOfMarker marker: GMSMarker) {
        let view = marker.userData as! MapDetailView
        let act = view.annotation.activity
        self.performSegueWithIdentifier("toActivityProfileSegue", sender: act)
    }
    
    
    //control camera update
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        Log.info("observeValueForKeyPath called")
        if let myLocation: CLLocation = change![NSKeyValueChangeNewKey] as? CLLocation {
            if !didFindUserLocation {
                mapView.settings.myLocationButton = true
                let update = GMSCameraUpdate.setTarget(myLocation.coordinate, zoom: 14.0)
                mapView.moveCamera(update)
                didFindUserLocation = true
                updateMapMarkers()
                mapView.removeObserver(self, forKeyPath: "myLocation")
                isObservingMyLocation = false
            }
            
        }
    }
    
    
    func userJoinedActivity() {
        guard let currentActivity = Activity.current_activity else {
            MBProgressHUD.hideHUDForView(self.view, animated: true)
            return
        }
        
        if let destination = currentActivity.location {
            if let myLocation  = self.mapView.myLocation {
                GoogleDirectionsAPI.direction(myLocation.coordinate, destination: destination) { (fetchedRoutes: [Route]?, error: NSError?) in
                    if let routes = fetchedRoutes {
                        self.startNavigation(routes[0].steps)
                    }
                }
            }
        }
        
        //uploading my current location
        mylocationTimer = NSTimer.scheduledTimerWithTimeInterval(8, target: self, selector: #selector(MapViewController.updateUserLocation), userInfo: nil, repeats: true)
        
        
        MBProgressHUD.hideHUDForView(self.view, animated: true)
        Log.info("user joined activity")
        mapView.clear()
        self.addMapMarker(currentActivity)
        showPath = true
        self.updateUserLocation()
        
        //start tracking my location
        locationTimer = NSTimer.scheduledTimerWithTimeInterval(8, target: self, selector: #selector(MapViewController.updateMemberLocations), userInfo: nil, repeats: true)
        
        activityNameLabel.text = currentActivity.title
        activityRestuarantLabel.text = currentActivity.overview
        
        if activityPanelBottomPos.constant == -100 {
            UIView.animateWithDuration(0.3) {
                self.activityPanelBottomPos.constant = 12
                self.view.layoutIfNeeded()
                self.navigationBtn.alpha = 1
                self.pathBtn.alpha = 1
                self.redoBtn.alpha = 0
            }
        }
        
        if newActivityBottomPos.constant == 12 {
            UIView.animateWithDuration(0.3) {
                self.newActivityBottomPos.constant = -12 - 48
                self.view.layoutIfNeeded()
            }
        }
    }
    
    func userExitedActivity() {
        Log.info("userExitedActivity")
        if activityPanelBottomPos.constant == 12 {
            UIView.animateWithDuration(0.2) {
                self.activityPanelBottomPos.constant = -100
                self.view.layoutIfNeeded()
            }
        }
        
        if newActivityBottomPos.constant == -12 - 48 {
            UIView.animateWithDuration(0.3) {
                self.newActivityBottomPos.constant = 12
                self.view.layoutIfNeeded()
            }
        }
        
        if let activity = Activity.current_activity {
            Log.info("found current activity")
            activity.exitActivity({
                Log.info("clear User's current Activity successfully")
                if let locationTimer = self.locationTimer {
                    locationTimer.invalidate()
                }
                
                if let mylocationTimer = self.mylocationTimer {
                    mylocationTimer.invalidate()
                }
                
                self.memberLocations.removeAll()
                
                //animate map view camera
                if let myLocation = self.mapView.myLocation {
                    let update = GMSCameraUpdate.setTarget(myLocation.coordinate, zoom: 14.0)
                    self.mapView.animateWithCameraUpdate(update)
                }
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
                        
                        guard let screenName = User.currentUser!.screenName else {
                            Log.error("This is a buggy user due to no screenName")
                            return
                        }
                        
                        let notification = UserNotification(type: .Invitation, content: "\(screenName) invited you to an activity", senderId: activity!.owner.objectId!, receiverId: invitedUser, associatedId: activity!.activityId, senderName: screenName, senderAvatarPFFile: User.currentUser?.avatarImagePFFile)
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

