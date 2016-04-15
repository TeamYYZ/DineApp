//
//  YYZTextField.swift
//  Dine
//
//  Created by YiHuang on 3/15/16.
//  Copyright © 2016 YYZ. All rights reserved.
//

import UIKit

enum CustomTextFieldType {
    case Email, Password, Name
    
}

class YYZTextField: UITextField {
    lazy var validatedImageView = UIImageView(image: UIImage(named: "validated"))
    var textChangedCB: ((Bool)->())?
    var fieldType: CustomTextFieldType? {
        didSet {
            self.addTarget(self, action: #selector(YYZTextField.textFieldDidChange(_:)), forControlEvents: UIControlEvents.EditingChanged)
        }
    }
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    
    
    func isValidEmail() -> Bool {
        if let _ =  self.text?.rangeOfString("[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}", options: .RegularExpressionSearch, range: nil, locale: nil) {
            textChangedCB?(true)
            return true
            
        } else {
            textChangedCB?(false)
            return false
        }
        
    }
    
    func isValidPassword() -> Bool {
        if self.text?.characters.count >= 6 {
            textChangedCB?(true)
            return true
        } else {
            textChangedCB?(false)
            return false
        }
        
    }
    
    func isValidName() -> Bool {
        if self.text?.characters.count >= 1 {
            textChangedCB?(true)
            return true
        } else {
            textChangedCB?(false)
            return false
        }
    }
    
    override func rightViewRectForBounds(bounds: CGRect) -> CGRect {
        return CGRect(x: self.frame.size.width - 20, y: 10, width: 20.0, height: 20.0)
    }
    
    func textFieldDidChange(textField: UITextField) {
        if let fieldType = self.fieldType {
            switch fieldType {
            case .Email:
                if isValidEmail() {
                    
                    self.rightViewMode = .Always
                } else {
                    self.rightViewMode = .Never
                }
            case .Name:
                if isValidName() {
                    self.rightViewMode = .Always
                } else {
                    self.rightViewMode = .Never
                }
            case .Password:
                if isValidPassword() {
                    self.rightViewMode = .Always
                } else {
                    self.rightViewMode = .Never
                }
            }
        }

    }
    
    override func awakeFromNib() {
        self.borderStyle = .None
        self.setBottomBorder(color: ColorTheme.sharedInstance.loginTextColor)
        self.tintColor = ColorTheme.sharedInstance.loginTextColor
        self.textColor = ColorTheme.sharedInstance.loginTextColor
        if let placeholder = self.placeholder {
            self.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [NSForegroundColorAttributeName : ColorTheme.sharedInstance.loginTextColor])
        
        }
        
        self.autocapitalizationType = .None
        self.autocorrectionType = .No
        self.rightViewMode = .Never
        self.rightView = validatedImageView
    }
}
