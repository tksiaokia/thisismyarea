//
//  ViewController.swift
//  ThisIsMyArea
//
//  Created by Sean Tee on 08/07/2019.
//  Copyright © 2019 Sean. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import Reachability

class ViewController: UIViewController {
    
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var lblInfo: UILabel!
    
    
    var locationManager = CLLocationManager()
    var isReceiveFirstLocationUpdate:Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
        mapView.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(connectedWifiChanges(_:)), name: .connectedWifiChanges, object: nil)
        
        
    }
    @objc func connectedWifiChanges(_ notification:Notification){
        updateGeofenceStatus()
    }
    func updateGeofenceStatus(){
        //Connected Wifi is highest priority
        if let gfvm = GeofenceViewModel.connectedWifiGFVM{
            updateInfoMessage(msg: "Enter Wifi: "+gfvm.geofence.title)
        }else if let gfvm = GeofenceViewModel.enteredGeofence{
            updateInfoMessage(msg: "Enter : "+gfvm.geofence.title)
        }else{
            updateInfoMessage(msg: "No enter any fence")
        }
    }
    
    
    
    func add(_ geofence: Geofence) {
        let viewModel = GeofenceViewModel(geofence: geofence)
        GeofenceViewModel.monitoringGeoFences.append(viewModel)
        mapView.addAnnotation(viewModel.mapAnnotation)
        addRadiusOverlay(for: viewModel)
        startMonitoring(for: viewModel)
    }
    func remove(_ viewModel: GeofenceViewModel){
        if let index = GeofenceViewModel.monitoringGeoFences.firstIndex(where: { (vm) -> Bool in
            vm.geofence.id == viewModel.geofence.id
        }){
            GeofenceViewModel.monitoringGeoFences.remove(at: index)
        }
        mapView.removeAnnotation(viewModel.mapAnnotation)
        removeRadiusOverlay(for: viewModel)
        stopMonitoring(for: viewModel)
        
    }
    
    // MARK: Other mapview functions
    @IBAction func zoomToCurrentLocation(_ sender: Any) {
        mapView.zoomToUserLocation()
    }
    func addRadiusOverlay(for geofence: GeofenceViewModel) {
        mapView?.addOverlay(geofence.mapCircle)
    }
    func removeRadiusOverlay(for geofence: GeofenceViewModel) {
        mapView?.removeOverlay(geofence.mapCircle)
    }
    func startMonitoring(for geofence: GeofenceViewModel) {
        if !CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
            showAlert(withTitle:"Error", message: "Geofencing is not supported on this device!")
            return
        }
        
        if CLLocationManager.authorizationStatus() != .authorizedAlways && CLLocationManager.authorizationStatus() != .authorizedWhenInUse  {
            let message = """
      Please enable location services.
      """
            showAlert(withTitle:"Warning", message: message)
        }
        
        //Start Monitoring
        locationManager.startMonitoring(for: geofence.region)
        
    }
    func stopMonitoring(for geofence: GeofenceViewModel){
        locationManager.stopMonitoring(for: geofence.region)
    }
    
    func updateInfoMessage(msg:String){
        lblInfo.text = msg
    }
    
    func updateWhenReceiveFirstLocationUpdate(coordinate:CLLocationCoordinate2D){
        
        for geofence in GeofenceViewModel.monitoringGeoFences{
            if geofence.region.contains(coordinate){
                GeofenceViewModel.enteredGeofence = geofence
                updateGeofenceStatus()
                break
            }
        }
        //zoom to current location
        mapView.zoomToUserLocation(coordinate: coordinate)
        
        
    }
    
}
// MARK: - Location Manager Delegate
extension ViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        mapView.showsUserLocation = status == .authorizedAlways
        
    }
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print("Monitoring failed for region with identifier: \(region!.identifier)")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location Manager failed with the following error: \(error)")
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if region is CLCircularRegion {
            if let viewModel = GeofenceViewModel.getGeofenceViewModel(byID: region.identifier, from: GeofenceViewModel.monitoringGeoFences){
                GeofenceViewModel.enteredGeofence = viewModel
                updateGeofenceStatus()
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        if region is CLCircularRegion {
            if let viewModel = GeofenceViewModel.getGeofenceViewModel(byID: region.identifier, from: GeofenceViewModel.monitoringGeoFences){
                
                //if entered last time, then set to nil
                if let enteredGeofence = GeofenceViewModel.enteredGeofence,  enteredGeofence.geofence.id == viewModel.geofence.id{
                    GeofenceViewModel.enteredGeofence = nil
                }
                updateInfoMessage(msg: "Exit : "+viewModel.geofence.title)
            }
        }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if CLLocationManager.authorizationStatus() != .authorizedAlways && CLLocationManager.authorizationStatus() != .authorizedWhenInUse{
            return
        }
        
        if let coordinate = locations.last?.coordinate{
            
            
            //every time location update, find nearest geofence and re-monitor
            GeofenceViewModel.getGeofences(userCoor: coordinate) { (fences) in
                var listToRemote = [GeofenceViewModel]()
                var listToAdd = [Geofence]()
                
                //for new set, check existing monitoring ady have or not, then add it
                for newFence in fences{
                    //if not found, then add to listToAdd
                    if GeofenceViewModel.monitoringGeoFences.filter({ (old) -> Bool in
                        old.geofence.id == newFence.id
                    }).count == 0{
                        listToAdd.append(newFence)
                    }
                }
                //for old set, check if new set still consist of it, else remove it
                for oldFence in GeofenceViewModel.monitoringGeoFences{
                    if fences.filter({ (new) -> Bool in
                        new.id == oldFence.geofence.id
                    }).count == 0{
                        listToRemote.append(oldFence)
                    }
                }
                
                //now remove first
                listToRemote.forEach{ self.remove($0) }
             
                
                //then add again
                listToAdd.forEach{ self.add($0) }
                
                
                /*
                 * In Case
                 * If current position in ady inside region,
                 * update it because didEnter of monitoring wont trigger
                 * Only applicatable for first time
                 */
              
                if !self.isReceiveFirstLocationUpdate || ConfigManager.shared.isWalking{
                    self.isReceiveFirstLocationUpdate = true
                    self.updateWhenReceiveFirstLocationUpdate(coordinate: coordinate)
                }
                
            }
            
            
        }
    }
}

// MARK: - MapView Delegate
extension ViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "myAnnotationIdentifier"
        if annotation is GeofenceMKAnnotation {
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView
            if annotationView == nil {
                annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView?.canShowCallout = true
            } else {
                annotationView?.annotation = annotation
            }
            return annotationView
        }
        return nil
    }
    
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKCircle {
            let circleRenderer = MKCircleRenderer(overlay: overlay)
            circleRenderer.lineWidth = 1.0
            circleRenderer.strokeColor = .blue
            circleRenderer.fillColor = UIColor.blue.withAlphaComponent(0.4)
            return circleRenderer
        }
        return MKOverlayRenderer(overlay: overlay)
    }
    
    
    
}

