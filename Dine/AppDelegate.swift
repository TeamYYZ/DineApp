
//  AppDelegate.swift
//  Dine
//
//  Created by you wu on 3/9/16.
//  Copyright © 2016 YYZ. All rights reserved.
//

import UIKit
import ChameleonFramework
import ParseFacebookUtilsV4
import JSSAlertView


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var latestPendingNotificationOfActivityId: String?
    
    let mainSB = UIStoryboard(name: "Main", bundle: nil)
    var slideMenuController: ContainerViewController!
    
    private func createMenu() {
        let sidebarSB = UIStoryboard(name: "Sidebar", bundle: nil)
        let mainfuncSB = UIStoryboard(name: "Main", bundle: nil)
        let mainViewController = mainfuncSB.instantiateViewControllerWithIdentifier("MapViewController") as! MapViewController
        let leftViewController =
            sidebarSB.instantiateViewControllerWithIdentifier("SidebarMenuViewController") as! SidebarMenuViewController
        
        let nvc: UINavigationController = UINavigationController(rootViewController: mainViewController)
        leftViewController.mainViewController = nvc
        let nvcl: UINavigationController = UINavigationController(rootViewController: leftViewController)
        
        SlideMenuOptions.animationDuration = 0.2
        SlideMenuOptions.leftViewWidth = 200
        SlideMenuOptions.shadowOffset = CGSize(width: 2, height: 0)
        SlideMenuOptions.shadowOpacity = 0.4
        SlideMenuOptions.shadowRadius = 2
        SlideMenuOptions.simultaneousGestureRecognizers = false
        
        slideMenuController = ContainerViewController(mainViewController: nvc, leftMenuViewController: nvcl)
        
        slideMenuController.automaticallyAdjustsScrollViewInsets = true
        slideMenuController.delegate = mainViewController
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let installation = PFInstallation.currentInstallation()
        installation.setDeviceTokenFromData(deviceToken)
        installation.channels = ["chat", "notification"]
        installation.saveInBackground()
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        if error.code == 3010 {
            Log.error("Push notifications are not supported in the iOS Simulator.")
        } else {
            Log.error("application:didFailToRegisterForRemoteNotificationsWithError: \(error.localizedDescription)")
        }
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        if true || application.applicationState == .Active {
            Log.info("got notification when active")
            print(userInfo)
            if let notificationType = userInfo["t"] as? String {
                if "2" == notificationType {
                    NSNotificationCenter.defaultCenter().postNotificationName(ChatViewController.NCObserverName, object: nil)
                } else if "1" == notificationType {
                    if let associatedId = userInfo["a"] as? String {
                        if let topVC = UIApplication.topViewController() {
                            JSSAlertView().info(topVC, title: "Invitation", text: "You received a dinning invitation from your friend.", buttonText: "Okay")
                        }
                    }
                    
                    NSNotificationCenter.defaultCenter().postNotificationName(NotificationViewController.NCObserverName, object: nil)

                } else if "3" == notificationType {
                    if let topVC = UIApplication.topViewController() {
                        if let aps = userInfo["aps"] as? NSDictionary, alertText = aps["alert"] as? String {
                            JSSAlertView().info(topVC, title: "Friend Request", text: alertText + "                       ", buttonText: "Got it")
                            
                        }

                    }
                    
                    NSNotificationCenter.defaultCenter().postNotificationName(NotificationViewController.NCObserverName, object: nil)

                
                }
            }
        
        }
        
        if application.applicationState == .Inactive {
            
        
        }

    }
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        let barStyle = UIBarButtonItem.appearance()
        barStyle.setBackButtonTitlePositionAdjustment(UIOffsetMake(-100, -60), forBarMetrics:UIBarMetrics.Default)

        UIApplication.sharedApplication().statusBarStyle = .Default
        
        let types: UIUserNotificationType = [.Alert, .Badge, .Sound]
        let settings = UIUserNotificationSettings(forTypes: types, categories: nil)
        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()
        

        self.createMenu()
        
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: ColorTheme.sharedInstance.menuBackgroundColor]
        UINavigationBar.appearance().tintColor = ColorTheme.sharedInstance.menuBackgroundColor
        UINavigationBar.appearance().barTintColor = ColorTheme.sharedInstance.navigationBarBackgroundColor
        
        self.window?.backgroundColor = FlatWhite()
        
        

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AppDelegate.userDidLogout), name: "userDidLogoutNotification", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AppDelegate.userDidLogin), name: "userDidLoginNotification", object: nil)
        
        Parse.initializeWithConfiguration(
            ParseClientConfiguration(block: { (configuration:ParseMutableClientConfiguration) -> Void in
                configuration.applicationId = "DineApp"
                configuration.clientKey = "thisIsYYZsMasterKey"
                configuration.server = "https://still-plains-53736.herokuapp.com/parse"
            })
        )
        
        PFFacebookUtils.initializeFacebookWithApplicationLaunchOptions(launchOptions)
        
        if let _ = PFUser.currentUser() {
            userDidLogin()
            if let notification = launchOptions?[UIApplicationLaunchOptionsRemoteNotificationKey] as? [String: AnyObject] {
                let aps = notification["aps"] as! [String: AnyObject]
                let associatedId = notification["a"] as? String
                let senderId = notification["s"] as? String
                
                
                let storyBoard = UIStoryboard(name: "ActivityProfileViewController", bundle: NSBundle.mainBundle())
                let activityVC = storyBoard.instantiateViewControllerWithIdentifier("ActivityProfileVC") as! ActivityProfileViewController
                activityVC.previewIndicator.isPreview = true
                activityVC.previewIndicator.activityId = associatedId
                (self.window?.rootViewController as? ContainerViewController)?.mainViewController?.navigationController?.pushViewController(activityVC, animated: true)

                //                slideMenuController.mainViewController?.navigationController?.pushViewController(activityVC, animated: true)
                
            }
            
            
        } else {
            userDidLogout()
        }
        
        
        return true
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    func userDidLogin() {
        let installation = PFInstallation.currentInstallation()
        guard let _ = PFUser.currentUser(), userId = PFUser.currentUser()?.objectId  else {
            Log.error("objectId not exists or currentUser not exists")
            return
        }
        
        Log.info("userDidLogin \(userId)")

        installation["userId"] = userId
        installation.saveInBackground()
        
        self.createMenu()
        self.window?.rootViewController = slideMenuController
        self.window?.makeKeyAndVisible()
    }
    
    func userDidLogout() {
        let installation = PFInstallation.currentInstallation()
        installation.removeObjectForKey("userId")
        installation.saveInBackground()
        
        User.currentUser = nil
        Activity.current_activity = nil
        
        let signSB = UIStoryboard(name: "SignInSignOut", bundle: nil)
        let vc = signSB.instantiateViewControllerWithIdentifier("LoginViewController")
        window?.rootViewController = vc
        self.window?.makeKeyAndVisible()

    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        FBSDKAppEvents.activateApp()
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

