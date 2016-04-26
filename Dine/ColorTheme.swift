//
//  ColorTheme.swift
//  Dine
//
//  Created by Yi Huang on 16/3/14.
//  Copyright © 2016年 YYZ. All rights reserved.
//

import Foundation
import UIKit
import ChameleonFramework

class ColorTheme {
    static var sharedInstance = ColorTheme()
    var loginGradientFisrtColor: UIColor
    var loginGradientSecondColor: UIColor
    var loginTextColor: UIColor
    var loginOptianLabelColor: UIColor
    var loginTextShadowColor: UIColor
    var YYZButtonDisableTextColor: UIColor
    var YYZButtonDisableBackgroundColor: UIColor

    var navigationBarBackgroundColor: UIColor
    var acceptButtonColor: UIColor
    var acceptButtonDisableColor: UIColor
    
    var chatRecipientMessageColor: UIColor
    var chatMyMessageColor: UIColor
    var chatRecipientBackgroudColor: UIColor
    var chatMyBackgroudColor: UIColor
    
    var menuBackgroundColor: UIColor
    var menuTextColor: UIColor
    var menuIconTintColor: UIColor
    var menuSelectedBackgroundColor: UIColor
    
    var profileSignOutLabelColor: UIColor
    
    var activityPanelTagColor: UIColor
    var activityPanelTagAnimateColor: UIColor

    var activityPanelTextColor: UIColor

    init() {
        navigationBarBackgroundColor = UIColor.flatWhiteColor()
        loginGradientFisrtColor = UIColor.flatWatermelonColor()
        loginGradientSecondColor = UIColor.flatRedColorDark()
        loginTextColor = ContrastColorOf(loginGradientFisrtColor, returnFlat: true)
        loginOptianLabelColor = UIColor.flatWhiteColorDark()
        loginTextShadowColor = UIColor.flatBlueColorDark()
        
        YYZButtonDisableTextColor = UIColor.flatGrayColor()
        YYZButtonDisableBackgroundColor = UIColor.flatGrayColorDark()
        
        acceptButtonColor = UIColor.flatGreenColorDark()
        acceptButtonDisableColor = UIColor.flatGrayColor()
        
        chatRecipientBackgroudColor = UIColor.flatGrayColor()
        chatMyBackgroudColor = UIColor.flatSkyBlueColor()
        
        chatRecipientMessageColor = ContrastColorOf(chatRecipientBackgroudColor, returnFlat: true)
        chatMyMessageColor = ContrastColorOf(chatMyBackgroudColor, returnFlat: true)
        
        menuBackgroundColor = UIColor.flatGrayColorDark()
        menuTextColor = ContrastColorOf(menuBackgroundColor, returnFlat: true)
        menuIconTintColor = menuTextColor
        menuSelectedBackgroundColor = UIColor.flatGrayColor()
        
        profileSignOutLabelColor = UIColor.flatRedColor()
        
        activityPanelTagColor = UIColor.flatBlueColor()
        activityPanelTextColor = UIColor.flatBlackColorDark()
        activityPanelTagAnimateColor = UIColor.flatRedColor()
    }



}