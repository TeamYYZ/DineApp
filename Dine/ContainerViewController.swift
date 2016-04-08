//
//  ContainerViewController.swift
//  Dine
//
//  Created by you wu on 4/1/16.
//  Copyright © 2016 YYZ. All rights reserved.
//

import UIKit

class ContainerViewController: SlideMenuController {
    
    
    override func isTagetViewController() -> Bool {
        if let vc = UIApplication.topViewController() {
            if vc is MapViewController ||
                vc is FriendsViewController ||
                vc is NotificationViewController || vc is ProfileSettingsViewController
            {
                return true
            }
        }
        return false
    }
    
    override func track(trackAction: TrackAction) {
        switch trackAction {
        case .LeftTapOpen:
            print("TrackAction: left tap open.")
        case .LeftTapClose:
            print("TrackAction: left tap close.")
        case .LeftFlickOpen:
            print("TrackAction: left flick open.")
        case .LeftFlickClose:
            print("TrackAction: left flick close.")
        case .RightTapOpen:
            print("TrackAction: right tap open.")
        case .RightTapClose:
            print("TrackAction: right tap close.")
        case .RightFlickOpen:
            print("TrackAction: right flick open.")
        case .RightFlickClose:
            print("TrackAction: right flick close.")
        }
    }


}
