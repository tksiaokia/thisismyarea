//
//  CLLocationCoordinate2D+Extension.swift
//  ThisIsMyArea
//
//  Created by Sean Tee on 09/07/2019.
//  Copyright © 2019 Sean. All rights reserved.
//

import Foundation
import MapKit
extension CLLocationCoordinate2D {
    //distance in meters, as explained in CLLoactionDistance definition
    func distance(from: CLLocationCoordinate2D) -> CLLocationDistance {
        let destination=CLLocation(latitude:from.latitude,longitude:from.longitude)
        return CLLocation(latitude: latitude, longitude: longitude).distance(from: destination)
    }
}
