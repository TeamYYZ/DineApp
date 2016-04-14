//
//  MapCell.swift
//  Dine
//
//  Created by you wu on 3/24/16.
//  Copyright © 2016 YYZ. All rights reserved.
//

import UIKit
import GoogleMaps

class MapCell: UITableViewCell,CLLocationManagerDelegate, GMSMapViewDelegate {
    var annotationTitle:String!

    @IBOutlet weak var view: UIView!
    var mapView: GMSMapView!

    var business: Business! {
        didSet{
            if business.address != nil {
                self.annotationTitle = business.address
            }

            if business.coordinate != nil {
                setupMap(business.coordinate!)
            }
        }
    }

    
    override func awakeFromNib() {
        super.awakeFromNib()
        print("awakeFromNib")

        // Initialization code
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        mapView.frame.size.width = self.frame.size.width
    }

    func setupMap(coords: CLLocationCoordinate2D) {
        print("setupMap")
        mapView = GMSMapView.mapWithFrame(self.view.frame, camera: GMSCameraPosition.cameraWithTarget(coords, zoom: 14.0))
        print(self.view.frame)
        mapView.myLocationEnabled = true
        
        mapView.delegate = self
        view.addSubview(mapView)

        
        let marker = GMSMarker()
        marker.position = coords
        marker.map = mapView
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
