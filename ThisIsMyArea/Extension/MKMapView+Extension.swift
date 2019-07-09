//
//  MKMapView+Extension.swift
//  ThisIsMyArea
//
//  Created by Sean Tee on 08/07/2019.
//  Copyright © 2019 Sean. All rights reserved.
//

import Foundation
import MapKit
extension MKMapView {
    func zoomToUserLocation(coordinate:CLLocationCoordinate2D? = nil) {
        var userCoordinate:CLLocationCoordinate2D?
        if coordinate != nil{
            userCoordinate = coordinate
        }else{
            userCoordinate = userLocation.location?.coordinate
        }
        guard let coor = userCoordinate else { return }
        let meter = ConfigManager.shared.regionRadius * 2
        let region = MKCoordinateRegion(center:coor, latitudinalMeters: meter, longitudinalMeters: meter)
        setRegion(region, animated: true)
    }
    
}
