//
//  AppDelegate.swift
//  Dine
//
//  Created by you wu on 3/9/16.
//  Copyright © 2016 YYZ. All rights reserved.
//

import UIKit
import ChameleonFramework
import ParseFacebookUtilsV4
import GoogleMaps

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
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
        
        slideMenuController = ContainerViewController(mainViewController: nvc, leftMenuViewController: nvcl)
        
        slideMenuController.automaticallyAdjustsScrollViewInsets = true
        slideMenuController.delegate = mainViewController
    }
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        self.createMenu()
        
        UINavigationBar.appearance().tintColor = ColorTheme.sharedInstance.loginTextColor
        UINavigationBar.appearance().barTintColor = ColorTheme.sharedInstance.navigationBarBackgroundColor
        
        self.window?.backgroundColor = UIColor(red: 236.0, green: 238.0, blue: 241.0, alpha: 1.0)
        
        //google map API
        
        GMSServices.provideAPIKey("AIzaSyCB-uEIYAecXTiyLBVBI0EiNg941XV8j-U")

        
        
        // Initialize Parse
        // Set applicationId and server based on the values in the Heroku settings.
        // clientKey is not used on Parse open source unless explicitly configured
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
        
        if let currentUser = PFUser.currentUser() {
            print("current user detected: \(currentUser.username)")
            currentUser.fetchIfNeededInBackgroundWithBlock({ (updatedUser: PFObject?, error: NSError?) in
                if updatedUser != nil && error == nil {
                    User.currentUser = User(pfUser: currentUser)
                    self.userDidLogin()
                } else {
                    print(error?.localizedDescription)
                
                }
            })
        } else {
            userDidLogout()
        
        }
        
        return true
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    func userDidLogin() {
        self.createMenu()
        self.window?.rootViewController = slideMenuController
        self.window?.makeKeyAndVisible()
    }
    
    func userDidLogout() {
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

