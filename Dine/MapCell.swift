//
//  MapCell.swift
//  Dine
//
//  Created by you wu on 3/24/16.
//  Copyright © 2016 YYZ. All rights reserved.
//

import UIKit
import MapKit

class MapCell: UITableViewCell,CLLocationManagerDelegate, MKMapViewDelegate {
    var locationManager : CLLocationManager!
    @IBOutlet weak var mapView: MKMapView!
    var annotationTitle:String!
    
    var business: Business! {
        didSet{
            self.annotationTitle = business.address
            goToLocation(business.coordinate!)
            addAnnotationAtCoordinate(business.coordinate!)
        }
    }

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        mapView.delegate = self
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.distanceFilter = 200
        locationManager.requestWhenInUseAuthorization()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func goToLocation(location: CLLocationCoordinate2D) {
        let span = MKCoordinateSpanMake(0.01, 0.01)
        let region = MKCoordinateRegionMake(location, span)
        mapView.setRegion(region, animated: false)
    }
    
    
    func addAnnotationAtCoordinate(coordinate: CLLocationCoordinate2D) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = annotationTitle
        mapView.addAnnotation(annotation)
    }
}
