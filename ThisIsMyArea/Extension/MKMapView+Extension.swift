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
    func zoomToUserLocation() {
        guard let coordinate = userLocation.location?.coordinate else { return }
        let region = MKCoordinateRegion(center:coordinate, latitudinalMeters: 200, longitudinalMeters: 200)
        setRegion(region, animated: true)
    }
    
}
