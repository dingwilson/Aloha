//
//  HeatMapViewController.swift
//  Aloha
//
//  Created by Wilson Ding on 2/26/17.
//  Copyright © 2017 Wilson Ding. All rights reserved.
//

import UIKit
import MapKit

class HeatMapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate{
    
    @IBOutlet weak var mapView: MKMapView!
    
    let mapSpan = 0.001
    
    var locationManager: CLLocationManager! = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getLocation()
    }
    
    func getLocation() {
        locationManager.delegate = self
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        if CLLocationManager.locationServicesEnabled() {
            switch(CLLocationManager.authorizationStatus()) {
            case .notDetermined, .restricted, .denied: // No access to location services
                locationManager.requestAlwaysAuthorization()
            case .authorizedAlways, .authorizedWhenInUse: // Access to location services
                locationManager.requestLocation()
                
                // Display location on map
                self.mapView.delegate = self
                mapView.showsUserLocation = true
            }
        } else { // Location services not enabled
            locationManager.requestAlwaysAuthorization()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        
        let center = location!.coordinate
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: mapSpan, longitudeDelta: mapSpan))
        
        self.mapView.setRegion(region, animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("locationManager Error: \(error)")
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let location = CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
    }
}
