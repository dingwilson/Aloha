//
//  ViewController.swift
//  Aloha
//
//  Created by Wilson Ding on 2/26/17.
//  Copyright © 2017 Wilson Ding. All rights reserved.
//

import UIKit
import CoreLocation

class BeaconListTableViewController: UITableViewController {
    
    var manager: CLLocationManager?
    
    var beaconList = [(CLBeaconRegion, CLBeacon)]()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // 1
        if CLLocationManager.isRangingAvailable() {
            // 2
            manager = CLLocationManager()
            manager!.delegate = self
            
            // 3
            manager!.requestWhenInUseAuthorization()
            
            // 4
            let beaconRegions = [CLBeaconRegion(proximityUUID: NSUUID(uuidString: "637DBAD2-7B9E-4E9F-930E-01D7C3AEC175")! as UUID, identifier: "Freeman")]
            
            // 5
            beaconRegions.forEach(manager!.startRangingBeacons)
        } else {
            // 6
            let alert = UIAlertController(title: "Unsupported", message: "Beacon ranging unavailable on this device.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default) { alertAction -> Void in
                self.navigationController?.popViewController(animated: true)
            })
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let rangedRegions = manager?.rangedRegions as? Set<CLBeaconRegion> {
            rangedRegions.forEach(manager!.stopRangingBeacons)
        }
    }
}

// MARK: - Table view data source

extension BeaconListTableViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return beaconList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BeaconCell", for: indexPath)
        
        let (region, beacon) = beaconList[indexPath.row]
        
        cell.textLabel?.text = "\(region.identifier), Major: \(beacon.major), Minor: \(beacon.minor)"
        cell.detailTextLabel?.text = "\(beacon.rssi)"
        
        return cell
    }
}

// MARK: - Location Manager Delegate
extension BeaconListTableViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        // 1
        var outputText = "Ranged beacons count: \(beacons.count)\n\n"
        beacons.forEach { beacon in
            outputText += beacon.description.substring(from: beacon.description.range(of:"major:")!.lowerBound)
            outputText += "\n\n"
        }
        NSLog("%@", outputText)
        
        // 2
        beacons.forEach { beacon in
            if let index = beaconList.index(where: { $0.1.proximityUUID.uuidString == beacon.proximityUUID.uuidString && $0.1.major == beacon.major && $0.1.minor == beacon.minor }) {
                beaconList[index] = (region, beacon)
            } else {
                beaconList.append((region, beacon))
            }
        }
        
        // 3
        tableView.reloadData()
    }
}
