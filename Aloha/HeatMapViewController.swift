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
import LFHeatMap

class HeatMapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate{
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var heatMapImageView: UIImageView!
    @IBOutlet weak var heatMapButton: UIButton!
    
    let mapSpan = 0.001
    
    var locationManager: CLLocationManager! = CLLocationManager()
    
    var beaconList = [(CLBeaconRegion, CLBeacon)]()
    
    var locations : [CLLocation] = []
    
    var weights : [NSNumber] = []
    
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
        
        self.heatMapImageView.isHidden = true
        
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
        
        //self.timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(self.createHeatMap), userInfo: nil, repeats: true)
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
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let location = CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
    }
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        
        beacons.forEach { beacon in
            if let index = beaconList.index(where: { $0.1.proximityUUID.uuidString == beacon.proximityUUID.uuidString && $0.1.major == beacon.major && $0.1.minor == beacon.minor }) {
                if beacon.proximity == .far {
                    beaconList.remove(at: index)
                } else {
                    beaconList[index] = (region, beacon)
                }
            } else {
                if beacon.proximity != .far {
                    beaconList.append((region, beacon))
                }
            }
        }
        
        locations.append(CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude))
        
        weights.append(NSNumber(integerLiteral: beacons.count))
    }
    
    func createHeatMap() {
        let heatMapImage = LFHeatMap.heatMap(for: self.mapView, boost: 0.1, locations: self.locations as [AnyObject], weights: self.weights as [AnyObject]) as UIImage
        
        self.heatMapImageView.isHidden = false
        
        self.heatMapImageView.image = heatMapImage
        self.heatMapImageView.alpha = 0.75
    }
    
    @IBAction func didPressHeatMapButton(_ sender: Any) {
        createHeatMap()
    }
    
}
