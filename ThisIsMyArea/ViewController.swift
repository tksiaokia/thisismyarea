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
    
    func addTestGeofences(){
        GeofenceViewModel.initTestGeofence().forEach { add($0) }
    }
    
    func add(_ geofence: Geofence) {
        let viewModel = GeofenceViewModel(geofence: geofence)
        GeofenceViewModel.monitoringGeoFences.append(viewModel)
        mapView.addAnnotation(viewModel.mapAnnotation)
        addRadiusOverlay(for: viewModel)
        startMonitoring(for: viewModel)
    }
    
    // MARK: Other mapview functions
    @IBAction func zoomToCurrentLocation(_ sender: Any) {
        mapView.zoomToUserLocation()
    }
    func addRadiusOverlay(for geofence: GeofenceViewModel) {
        mapView?.addOverlay(geofence.mapCircle)
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
    
    func updateInfoMessage(msg:String){
        lblInfo.text = msg
    }
    
}
// MARK: - Location Manager Delegate
extension ViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        mapView.showsUserLocation = status == .authorizedAlways
        if CLLocationManager.authorizationStatus() == .authorizedAlways || CLLocationManager.authorizationStatus() == .authorizedWhenInUse   {
            addTestGeofences()
        }
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
            //  handleEvent(for: region)
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
        
        if !isReceiveFirstLocationUpdate{
            isReceiveFirstLocationUpdate = true
            
            /*In Case
             If current position in ady inside region,
             update it because didEnter of monitoring wont trigger
             */
            if let coordinate = locations.last?.coordinate{
                for geofence in GeofenceViewModel.monitoringGeoFences{
                    if geofence.region.contains(coordinate){
                        GeofenceViewModel.enteredGeofence = geofence
                        updateGeofenceStatus()
                        break
                    }
                }
            }
            
            //zoom to current location
            mapView.zoomToUserLocation()
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

