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
        
        
        let geofences = getTestData(userCoor:userCoor,radius:radius)
        
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
    
    static var _testGeofences: [Geofence]?
    static private func getTestData(userCoor:CLLocationCoordinate2D,radius:Double)->[Geofence]{
        if let geofences = _testGeofences{
            return geofences
        }
        
        //if nil init
        var geofences: [Geofence] = []
        //for is walking, actually is testing
        //code below will populate nearby 5 nearest geofence with distance from user point of 10 meter
        if ConfigManager.shared.isWalking{
            let maxCount = ConfigManager.shared.maxMonitoringCount
            for i in 0..<maxCount{
                let range = 10 * 0.00001 //10 meteer
                let rad = Double(i) * 360/Double(maxCount) * .pi / 180
                let x = cos(rad)*range+userCoor.latitude
                let y = sin(rad)*range+userCoor.longitude
                let newCoor = CLLocationCoordinate2D(latitude: x, longitude: y)
                geofences.append(Geofence(id: "\(i)", coordinate: newCoor, radius: radius, title:"Walking Point \(i)"))
            }
        }else{
            geofences.append(Geofence(id: "1", coordinate: CLLocationCoordinate2D(latitude: 3.122224, longitude: 101.674965), radius: radius, title:"Petronas Bangsar"))
            geofences.append(Geofence(id: "2", coordinate: CLLocationCoordinate2D(latitude: 3.117811, longitude: 101.677471), radius: radius, title:"Mid Valley Point A"))
            geofences.append(Geofence(id: "3", coordinate: CLLocationCoordinate2D(latitude: 3.11743470880481, longitude: 101.67611098392119), radius: radius, title:"Mid Valley Office",bssid:"9c:d6:43:2d:3c:48"))
        }
        
        _testGeofences = geofences
        
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
