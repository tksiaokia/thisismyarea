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
    
    //Assuming this funtion may have http request to fetch data
    //Or it need more processing in background first
    static func getGeofences(userCoor:CLLocationCoordinate2D,onComplete:@escaping (([Geofence])->Void)){
        guard let radius = ConfigManager.shared.regionRadius else { return onComplete([Geofence]()) }
        
        let geofences = getTestData(radius:radius)
        
        //run in background thread for better performance
        DispatchQueue.global().async {
            let sorted = calculateDistanceAndSort(list: geofences, userCoor: userCoor)
            
            //then return in main thread
            DispatchQueue.main.async {
                // filter only nearby location
                let filtered = sorted.filter{
                    $0.distanceFromUserCoor < ConfigManager.shared.nearestRadius
                }
                //only select up to max count
                onComplete(Array(filtered.prefix(ConfigManager.shared.maxMonitoringCount)))
            }
            
        }
    }
    
    static private func getTestData(radius:Double)->[Geofence]{
        
        var geofences: [Geofence] = []
        
        geofences.append(Geofence(id: "1", coordinate: CLLocationCoordinate2D(latitude: 3.122224, longitude: 101.674965), radius: radius, title:"Petronas Bangsar"))
        geofences.append(Geofence(id: "2", coordinate: CLLocationCoordinate2D(latitude: 3.117811, longitude: 101.677471), radius: radius, title:"Mid Valley Point A"))
        geofences.append(Geofence(id: "3", coordinate: CLLocationCoordinate2D(latitude: 3.11743470880481, longitude: 101.67611098392119), radius: radius, title:"Mid Valley Office",bssid:"9c:d6:43:2d:3c:48"))
        
        return geofences
    }
    
    static private func calculateDistanceAndSort(list:[Geofence],userCoor:CLLocationCoordinate2D)->[Geofence]{
        for fence in list{
            fence.distanceFromUserCoor = fence.coordinate.distance(from: userCoor)
        }
        //then sort them before return
        return list.sorted { (a, b) -> Bool in
            a.distanceFromUserCoor < b.distanceFromUserCoor
        }
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
