//
//  MapViewController.swift
//  Dine
//
//  Created by you wu on 3/13/16.
//  Copyright © 2016 YYZ. All rights reserved.
//

import UIKit
import MBProgressHUD
import MapKit
import CoreLocation

import JSSAlertView

class MapViewController: UIViewController {
    
    @IBOutlet weak var navigationBtn: UIButton!
    @IBOutlet weak var pathBtn: UIButton!
    @IBOutlet weak var redoBtn: UIButton!
    @IBOutlet weak var centerLocBtn: UIButton!
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
    var direction: MKPolyline? {
        didSet {
            pathBtn.hidden = false
        }
    }
    var FoundUserLocation = false
    var showPath = false
    var locationTimer: NSTimer?
    var mylocationTimer: NSTimer?
    var memberLocations = [String: MemberAnnotation]()
    
    var mapView: MKMapView!
    
  
    
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
                        self.updateAnnotations()
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
        fetchCurrentUserInfo()
        
        //setup apple map
        setupMap()
        
        activityNameLabel.textColor = ColorTheme.sharedInstance.activityPanelTextColor
  
    }
    
    @IBAction func onCenterLoc(sender: AnyObject) {
        mapView.setCenterCoordinate(mapView.userLocation.location!.coordinate, animated: true)
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
        btn.layer.cornerRadius = btn.bounds.width/2
        btn.layer.masksToBounds = false
        
        btn.layer.shadowOpacity = 0.5
        btn.layer.shadowRadius = 1
        btn.layer.shadowOffset = CGSizeMake(0.0, 1.0)
        
    }
    
    func setupMap() {
        let bound = self.view.bounds
        var bounds: CGRect!
        
        if let navHeight = self.navigationController?.navigationBar.bounds.height {
            bounds = CGRect(x: 0.0, y: navHeight, width: bound.width, height: bound.height - navHeight)
        }else {
            bounds = self.view.bounds
        }
        mapView = MKMapView(frame: bounds)
        mapView.mapType = MKMapType.Standard
        mapView.zoomEnabled = true
        mapView.scrollEnabled = true
        self.view.insertSubview(mapView, atIndex: 0)
        
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.setUserTrackingMode(MKUserTrackingMode.Follow, animated: true)
        
        self.pathBtn.alpha = 0
        self.navigationBtn.alpha = 0
        setupMapButton(self.pathBtn)
        setupMapButton(self.navigationBtn)
        setupMapButton(self.redoBtn)
        setupMapButton(self.centerLocBtn)
    }
    
    func updateAnnotations() {
        mapView.removeAnnotations(mapView.annotations)
        Log.info("updating map search")
        //calculate current map sw and ne point location
        let mRect = mapView.visibleMapRect
        let neMapPoint = MKMapPointMake(MKMapRectGetMaxX(mRect), mRect.origin.y)
        let swMapPoint = MKMapPointMake(mRect.origin.x, MKMapRectGetMaxY(mRect))
        let neCoord = MKCoordinateForMapPoint(neMapPoint)
        let swCoord = MKCoordinateForMapPoint(swMapPoint)
        let SW = CLLocation(latitude: swCoord.latitude, longitude: swCoord.longitude)
        let NE = CLLocation(latitude: neCoord.latitude, longitude: neCoord.longitude)
        
        ParseAPI.getActivites(SW, locNE: NE) { (acts, error) in
            if error == nil {
                self.activities = acts
                for act in self.activities {
                    self.addAnnotation(act)
                }
            } else {
                Log.error("Unable to get activites")
            }
        }
        self.view.layoutIfNeeded()
    }
    
    func addAnnotation(act: Activity) {
        act.fetchGroupMember({ (groupMembers: [GroupMember]) in
            if Activity.current_activity != nil {
                self.updateMemberLocations()
            }
            let info = MapAnnotation(activity: act)
            self.mapView.addAnnotation(info)
            
            }, failureHandler: { (error: NSError?) -> () in
                Log.info(error?.localizedDescription)
        })
    }
    
    
    func calculateSegmentDirections(source: CLLocationCoordinate2D, dest: CLLocationCoordinate2D) {
        
        let currentPlace: MKPlacemark = MKPlacemark(coordinate: source, addressDictionary: nil)
        let place: MKPlacemark = MKPlacemark(coordinate: dest, addressDictionary: nil)

        
        let request: MKDirectionsRequest = MKDirectionsRequest()
        request.source = (MKMapItem(placemark: currentPlace))
        request.destination = (MKMapItem(placemark: place))
        // 2
        request.requestsAlternateRoutes = true
        // 3
        request.transportType = .Automobile
        // 4
        let directions = MKDirections(request: request)
        directions.calculateDirectionsWithCompletionHandler ({
            (response: MKDirectionsResponse?, error: NSError?) in
            if let routeResponse = response?.routes {
                let quickestRouteForSegment: MKRoute =
                    routeResponse.sort({$0.expectedTravelTime <
                        $1.expectedTravelTime})[0]
                self.direction = quickestRouteForSegment.polyline
                self.mapView.addOverlay(quickestRouteForSegment.polyline, level: MKOverlayLevel.AboveRoads)
                //animate map view camera
                
            } else if let _ = error {
                let alert = UIAlertController(title: nil,
                    message: "Directions not available.", preferredStyle: .Alert)
                let okButton = UIAlertAction(title: "OK",
                style: .Cancel) { (alert) -> Void in
                    self.navigationController?.popViewControllerAnimated(true)
                }
                alert.addAction(okButton)
                self.presentViewController(alert, animated: true,
                    completion: nil)
            }
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
                if member.userId == PFUser.currentUser()?.objectId {continue}
                
                guard let loc = member.location else {continue}
                
                let circleCenter = CLLocationCoordinate2D(latitude: loc.latitude, longitude: loc.longitude)
                
                if let marker = self.memberLocations[member.userId] {
                    marker.coordinate = circleCenter
                } else {
                    let marker = MemberAnnotation(member: member)
                    if let avatar = member.avatar {
                        avatar.getDataInBackgroundWithBlock({
                            (result: NSData?, error: NSError?) in
                            guard let imageData = result else {return}
                            if let icon = UIImage(data: imageData) {
                            let resizedIcon = resize(icon, newSize: CGSize(width: 45, height: 45))
                            marker.icon = resizedIcon
                            }
                            self.memberLocations[member.userId] = marker
                            self.mapView.addAnnotation(marker)
                        })
                        
                    }
                    

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
        
        GroupMember.updateLocation(currentActivity.activityId, userId: (PFUser.currentUser()?.objectId)!, location: PFGeoPoint(location: self.locationManager.location), successHandler: {
            Log.info("Updating current user location succeed")
        }) { (error: NSError?) in
            Log.error("Updating current user location failure")
        }
    }
    
    @IBAction func togglePolyLines(sender: AnyObject) {
        showPath = !showPath
        if let path = self.direction {
        if showPath {
            self.mapView.addOverlay(path)
        }else {
            //clear all polyline
            self.mapView.removeOverlay(path)
        }
        }
        
    }
    
    @IBAction func onRedoSearch(sender: AnyObject) {
        //update activities
        updateAnnotations()
    }
    
    @IBAction func onExternalNavigate(sender: AnyObject) {
        guard let place = Activity.current_activity?.location else {
            Log.error("unable to NAV in external NAV App due to bad location")
            return
        }
        
        UIApplication.sharedApplication().openURL(NSURL(string: "http://maps.apple.com/?daddr=\(place.latitude),\(place.longitude)&dirflg=d&t=m")!)
        
        
    }
    
   
    
    func controlAllViewsOnMap(hidden: Bool) {
        UIView.animateWithDuration(0.7) {
            self.navigationBtn.hidden = hidden
            self.pathBtn.hidden = hidden
            self.redoBtn.hidden = hidden
            self.centerLocBtn.hidden = hidden
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
    
    
    
    func userJoinedActivity() {
        guard let currentActivity = Activity.current_activity else {
            MBProgressHUD.hideHUDForView(self.view, animated: true)
            return
        }
        
        if let destination = currentActivity.location {
            if let myLocation  = self.locationManager.location {
                calculateSegmentDirections(myLocation.coordinate, dest: destination)
            }
        }
        
        //uploading my current location
        mylocationTimer = NSTimer.scheduledTimerWithTimeInterval(8, target: self, selector: #selector(MapViewController.updateUserLocation), userInfo: nil, repeats: true)
        
        
        MBProgressHUD.hideHUDForView(self.view, animated: true)
        Log.info("user joined activity")
        mapView.removeAnnotations(mapView.annotations)
        self.addAnnotation(currentActivity)
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
                let span = MKCoordinateSpanMake(0.1, 0.1)
                let region = MKCoordinateRegionMake(self.locationManager.location!.coordinate, span)
                self.mapView.setRegion(region, animated: true)

                //remove direction polyline
                self.mapView.removeOverlays(self.mapView.overlays)
                //update map, show all requests in the area
                self.updateAnnotations()
                
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
        MBProgressHUD.showLoadingHUDToView(self.view, animated: true)
        
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
        }
        
        if segue.identifier == "toActivityCreatorSegue" {
            print("here???")
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setObject(locationManager.location?.coordinate.latitude, forKey: "user_current_location_lat")
            defaults.setObject(locationManager.location?.coordinate.longitude, forKey: "user_current_location_lon")
            
            defaults.synchronize()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
extension MapViewController: CLLocationManagerDelegate {
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.AuthorizedWhenInUse {
            Log.info("::::start Update Location")
            manager.startUpdatingLocation()
        }
    }
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if (!FoundUserLocation){
        if let location = locations.first {
            let span = MKCoordinateSpanMake(0.1, 0.1)
            let region = MKCoordinateRegionMake(location.coordinate, span)
            mapView.setRegion(region, animated: false)
        }
            FoundUserLocation = true
        }
    }

}
extension MapViewController: MKMapViewDelegate {
    
    func mapView(mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        Log.info("will Move")
        controlAllViewsOnMap(true)
    }
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        Log.info("becomes idle")
        controlAllViewsOnMap(false)
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? MapAnnotation {
            
            var view = mapView.dequeueReusableAnnotationViewWithIdentifier("id")
            if view == nil {
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "id")
            }
            
            view!.canShowCallout = true
            view!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure) as UIView
            let mapDetailView = MapDetailView(frame: CGRect(origin: CGPointZero, size: CGSize(width: 245, height: 75)))
            mapDetailView.annotation = annotation
            view!.detailCalloutAccessoryView = mapDetailView

            return view
        }
        
        if let annotation = annotation as? MemberAnnotation{
            let reuseID = "memberView"
            var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseID)
            if (annotationView == nil) {
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
            }else {
                annotationView!.annotation = annotation
            }
            //annotationView?.image = UIImage(named: "User")
            annotationView!.image = annotation.icon!
            annotationView!.layer.cornerRadius = 20
            annotationView!.layer.borderWidth = 3
            annotationView!.layer.borderColor = UIColor.flatWhiteColor().CGColor
            annotationView!.clipsToBounds = true
            return annotationView
        }
        return nil

    }
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if let annotation = view.annotation as? MapAnnotation {
            let act = annotation.activity
            self.performSegueWithIdentifier("toActivityProfileSegue", sender: act)
        }
    }
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        if(overlay.isKindOfClass(MKPolyline)) {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = UIColor(red: 0.2302, green: 0.7771, blue: 0.3159, alpha: 0.7)
            renderer.lineWidth = 5
            return renderer
        }
        return MKPolylineRenderer()
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

