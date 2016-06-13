//
//  YYZTextField.swift
//  Dine
//
//  Created by YiHuang on 3/15/16.
//  Copyright © 2016 YYZ. All rights reserved.
//

import UIKit

enum CustomTextFieldType {
    case Email, Password, Name, Mobile, Vericode
    
}

class YYZTextField: UITextField, UITextFieldDelegate {
    lazy var validatedImageView = UIImageView(image: UIImage(named: "validated"))
    var vericode: String?
    var textChangedCB: ((Bool)->())?
    var bottomBorder: UIView?
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
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        guard let t = textField.text else {return true}
        if string != "" {
            if textField.text?.characters.count == 3 && textField.text?[t.startIndex] != "("  {
                textField.text = "(" + textField.text! + ") "
            } else if textField.text?.characters.count == 9 {
                textField.text = textField.text! + "-"
            }
        } else {
            if let end = textField.text?.endIndex {
                if textField.text?.characters.count < 2 {return true}
                if textField.text?[end.predecessor().predecessor()] == "-" {
                    textField.text?.removeAtIndex(end.predecessor().predecessor())
                } else if textField.text?[end.predecessor().predecessor()] == " " {
                    let _range = end.predecessor().predecessor().predecessor()..<end.predecessor()
                    textField.text?.removeRange(_range)
                    if t[t.startIndex] == "(" {
                        textField.text?.removeAtIndex(t.startIndex)
                    }
                }
            }
        
        }
        return true
    }
    
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
    
    func isCorrectVericode() -> Bool {
        print(self.text)
        print(self.vericode)
        if self.text != nil && self.vericode != nil && self.text == self.vericode {
            textChangedCB?(true)
            print("correct vericode")
            return true
        } else {
            textChangedCB?(false)
            return false
        }
    }
    
    func isMobile() -> Bool {
        if let _ =  self.text?.rangeOfString("\\(?\\d{3}\\)?\\s\\d{3}-\\d{4}", options: .RegularExpressionSearch, range: nil, locale: nil) {
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
            case .Mobile:
                if isMobile() {
                    self.rightViewMode = .Always
                } else {
                    self.rightViewMode = .Never
                }
            case .Vericode:
                if isCorrectVericode() {
                    self.rightViewMode = .Always
                } else {
                    self.rightViewMode = .Never
                }
            }
        }

    }
    
    override func awakeFromNib() {
        self.borderStyle = .None
        self.bottomBorder = self.setBottomBorder(color: ColorTheme.sharedInstance.loginTextColor)
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.bottomBorder?.frame = CGRectMake(0.0, self.frame.size.height - 1, self.frame.size.width, 1.0)

    }
}
