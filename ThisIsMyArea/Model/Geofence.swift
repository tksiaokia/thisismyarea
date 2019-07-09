//
//  Geofence.swift
//  ThisIsMyArea
//
//  Created by Sean Tee on 08/07/2019.
//  Copyright © 2019 Sean. All rights reserved.
//

import Foundation
import MapKit
import CoreLocation
class Geofence{
     var id: String
    var coordinate: CLLocationCoordinate2D
    var radius: CLLocationDistance
    var title:String
    var bssid:String?
    
    //run time value
    var distanceFromUserCoor:Double = -1

    //BSSID is nullable
    init(id: String,coordinate: CLLocationCoordinate2D, radius: CLLocationDistance,title:String,bssid:String? = nil){
        self.id = id
        self.coordinate = coordinate
        self.radius = radius
        self.title = title
        self.bssid = bssid
    }

}
