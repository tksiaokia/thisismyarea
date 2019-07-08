//
//  GeofenceViewModel.swift
//  ThisIsMyArea
//
//  Created by Sean Tee on 08/07/2019.
//  Copyright © 2019 Sean. All rights reserved.
//

import Foundation
import MapKit
class GeofenceViewModel{
    var geofence:Geofence
    init(geofence:Geofence) {
        self.geofence = geofence
    }
    
    var mapAnnotation:MKAnnotation{
        return GeofenceMKAnnotation(coordinate: geofence.coordinate,title:geofence.title )
    }
    
    var mapCircle:MKCircle{
        return MKCircle(center: geofence.coordinate, radius: geofence.radius)
    }
    
    var region:CLCircularRegion{
        let region = CLCircularRegion(center: geofence.coordinate, radius: geofence.radius, identifier: geofence.id)
        return region
    }
    
    static func initTestGeofence()->[Geofence]{
        var geofences: [Geofence] = []
        geofences.append(Geofence(id: "1", coordinate: CLLocationCoordinate2D(latitude: 3.122224, longitude: 101.674965), radius: 50, title:"Petronas Bangsar"))
        geofences.append(Geofence(id: "2", coordinate: CLLocationCoordinate2D(latitude: 3.117811, longitude: 101.677471), radius: 50, title:"Mid Valley"))
        return geofences
    }
    
    static func getGeofenceViewModel(by id:String,from list:[GeofenceViewModel])->GeofenceViewModel?{
        guard let matched = list.filter({
            $0.geofence.id == id
        }).first else { return nil }
        return matched
    }
    
    
}
