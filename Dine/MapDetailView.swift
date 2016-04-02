//
//  MapDetailView.swift
//  Dine
//
//  Created by you wu on 3/13/16.
//  Copyright © 2016 YYZ. All rights reserved.
//

import UIKit

class MapDetailView: UIView {
    @IBOutlet var view: UIView!
    @IBOutlet weak var profileView: UIImageView!

    @IBOutlet weak var restaurantLabel: UILabel!
    @IBOutlet weak var membersLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    var annotation : MapAnnotation! {
        didSet {
            restaurantLabel.text = annotation!.restaurantName
            membersLabel.text = annotation!.members
            timeLabel.text = annotation!.time
            profileView.setImageWithURL(annotation.profileURL!)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetup()
    }

    func xibSetup() {
        view = loadViewFromNib()
        
        // use bounds not frame or it'll be offset
        view.frame = bounds
        
        // Make the view stretch with containing view
        view.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
        // Adding custom subview on top of our view (over any custom drawing > see note below)
        addSubview(view)
    
    }
    
    func loadViewFromNib() -> UIView {
        
        let bundle = NSBundle(forClass: self.dynamicType)
        let nib = UINib(nibName: "MapDetailView", bundle: bundle)
        let view = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
        
        return view
    }
    
}

