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
    static var connectedWifiGFVM:GeofenceViewModel?
    static var enteredGeofence:GeofenceViewModel?
    static var monitoringGeoFences:[GeofenceViewModel] = []
    
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
         geofences.append(Geofence(id: "3", coordinate: CLLocationCoordinate2D(latitude: 3.11743470880481, longitude: 101.67611098392119), radius: 50, title:"Mid Valley Office",bssid:"9c:d6:43:2d:3c:48"))
        return geofences
    }
    
    static func getGeofenceViewModel(byID id:String,from list:[GeofenceViewModel])->GeofenceViewModel?{
        guard let matched = list.filter({
            $0.geofence.id == id
        }).first else { return nil }
        return matched
    }
    static func getGeofenceViewModel(bySSID ssid:String,from list:[GeofenceViewModel])->GeofenceViewModel?{
        guard let matched = list.filter({
            $0.geofence.bssid == ssid
        }).first else { return nil }
        return matched
    }
    
    
}
