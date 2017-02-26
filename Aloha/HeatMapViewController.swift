//
//  HeatMapViewController.swift
//  Aloha
//
//  Created by Wilson Ding on 2/26/17.
//  Copyright © 2017 Wilson Ding. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class HeatMapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate{
    
    @IBOutlet weak var mapView: MKMapView!
    
    let mapSpan = 0.001
    
    var locationManager: CLLocationManager! = CLLocationManager()
    
    var beaconList = [(CLBeaconRegion, CLBeacon)]()
    
    var numOfImmediateBeacons = 0
    var numOfNearBeacons = 0
    var numOfFarBeacons = 0
    
    @IBOutlet weak var immediateLabel: UILabel!
    @IBOutlet weak var nearLabel: UILabel!
    @IBOutlet weak var farLabel: UILabel!
    
    var timer = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mapView.isZoomEnabled = false
        self.mapView.isScrollEnabled = false
        self.mapView.isUserInteractionEnabled = false
        
        getLocation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if CLLocationManager.isRangingAvailable() {
            locationManager = CLLocationManager()
            locationManager.delegate = self
            
            locationManager.requestWhenInUseAuthorization()
            
            let beaconRegions = [CLBeaconRegion(proximityUUID: NSUUID(uuidString: "637DBAD2-7B9E-4E9F-930E-01D7C3AEC175")! as UUID, identifier: "Freeman")]
            
            beaconRegions.forEach(locationManager.startRangingBeacons)
        } else {
            let alert = UIAlertController(title: "Unsupported", message: "Beacon ranging unavailable on this device.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default) { alertAction -> Void in
                self.navigationController?.popViewController(animated: true)
            })
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.createHeatMap), userInfo: nil, repeats: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let rangedRegions = locationManager?.rangedRegions as? Set<CLBeaconRegion> {
            rangedRegions.forEach(locationManager!.stopRangingBeacons)
        }
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
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        
        var numOfImmediate = 0
        var numOfNear = 0
        var numOfFar = 0
        
        beacons.forEach { beacon in
            if beacon.proximity == .far {
                numOfFar = numOfFar + 1
            } else if beacon.proximity == .near {
                numOfNear = numOfNear + 1
            } else {
                numOfImmediate = numOfImmediate + 1
            }
        }
        
        self.numOfImmediateBeacons = numOfImmediate
        
        self.numOfFarBeacons = numOfFar
        
        self.numOfNearBeacons = numOfNear
    }
    
    func createHeatMap() {
        self.immediateLabel.text = "Immediate (~ 1 meter): \(self.numOfImmediateBeacons)"
        self.nearLabel.text = "Near (~ 50 feet): \(self.numOfNearBeacons)"
        self.farLabel.text = "Far (~ 100 feet): \(self.numOfFarBeacons)"
    }
}
