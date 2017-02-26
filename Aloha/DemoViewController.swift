//
//  DemoViewController.swift
//  Aloha
//
//  Created by Wilson Ding on 2/26/17.
//  Copyright © 2017 Wilson Ding. All rights reserved.
//

import UIKit
import CoreLocation
import FirebaseDatabase
import SwiftVideoBackground

class DemoViewController: UIViewController {
    
    @IBOutlet weak var backgroundVideo: BackgroundVideo!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var totalImpressionsLabel: UILabel!
    
    var manager: CLLocationManager?
    
    var beaconList = [(CLBeaconRegion, CLBeacon)]()
    
    var prevBeaconList = [(CLBeaconRegion, CLBeacon)]()
    
    var ref: FIRDatabaseReference!
    
    var userList = [(Int, String, String)]()
    
    var currentUser : String = "My Friend"
    var currentUserType: String = "False"
    var currentMinor : Int = 999999
    var currentTime : Int = 0
    
    var totalImpressions : Int!
    
    var timer = Timer()
    var valueTimer = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = FIRDatabase.database().reference()
        
        backgroundVideo.createBackgroundVideo(name: "Background", type: "mp4", alpha: 0.3)
        
        totalImpressions = 0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        messageLabel.isHidden = true
        timeLabel.isHidden = true
        totalImpressionsLabel.isHidden = true
        
        userList = [(Int, String, String)]()
        
        updateMinors()
        
        if CLLocationManager.isRangingAvailable() {
            manager = CLLocationManager()
            manager!.delegate = self
            
            manager!.requestWhenInUseAuthorization()
            
            let beaconRegions = [CLBeaconRegion(proximityUUID: NSUUID(uuidString: "637DBAD2-7B9E-4E9F-930E-01D7C3AEC175")! as UUID, identifier: "Freeman")]
            
            beaconRegions.forEach(manager!.startRangingBeacons)
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
        
        currentTime = 0
        
        currentUser = "My Friend"
        
        currentMinor = 999999
        
        currentUserType = "False"
        
        while currentUser == nil {
            findClosestBeacon()
        }
        
        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateTime), userInfo: nil, repeats: true)
        
        self.valueTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.updateValues), userInfo: nil, repeats: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let rangedRegions = manager?.rangedRegions as? Set<CLBeaconRegion> {
            rangedRegions.forEach(manager!.stopRangingBeacons)
        }
        
        self.timer.invalidate()
        self.valueTimer.invalidate()
    }
    
    func updateMinors() {
        ref.child("beacons").observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            
            var name : Any?
            var type : Any?
            
            if let beacons = value {
                for (key, value) in beacons {
                    for (item, object) in (value as! NSDictionary) {
                        if item as! String == "name" {
                            name = object as? String
                        } else {
                            type = object as? String
                        }
                    }
                    let user = (Int(key as! String)!, name as! String, type as! String)
                    self.userList.append(user)
                }
            }
            
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func findClosestBeacon() {
        var closestName : String!
        var closestMinor : Int!
        var closestType : String!
        var closestRSSI : Int!
        
        for (region, beacon) in beaconList {
            for (minor, name, type) in self.userList {
                if minor == Int(beacon.minor) {
                    if let rssi = closestRSSI {
                        if beacon.rssi != 0 && beacon.rssi > rssi {
                            closestName = name
                            closestMinor = minor
                            closestType = type
                            closestRSSI = beacon.rssi
                        }
                    } else {
                        closestName = name
                        closestMinor = minor
                        closestType = type
                        closestRSSI = beacon.rssi
                    }

                }
            }
        }
        
        if let closest = closestMinor {
            if closest != self.currentMinor {
                currentTime = 0
                currentMinor = closestMinor
                currentUser = closestName!
                currentUserType = closestType!
            }
        }
    }
    
    func updateTime() {
        findClosestBeacon()
        
        currentTime = currentTime + 1
        timeLabel.text = "You have been here for \(currentTime) seconds."
        
        nameLabel.text = currentUser
        
        switch(currentUserType) {
        case "Hacker":
            messageLabel.text = "Thank you for hacking with us at Buildathon!"
            break
        case "Teammate":
            messageLabel.text = "Thanks for being on my team at Buildathon!"
            break
        case "Mentor":
            messageLabel.text = "Thank you for mentoring at Buildathon!"
            break
        case "Sponsor":
            messageLabel.text = "Thank you for sponsoring Buildathon!"
            break
        case "Organizer":
            messageLabel.text = "Thank you for organizing Buildathon!"
            break
        default:
            messageLabel.text = "Thank you for being amazing. :)"
            break
        }
        
        if currentUser != "My Friend" {
            timeLabel.isHidden = false
            
            messageLabel.isHidden = false
            
            totalImpressionsLabel.isHidden = false
        }
    }
    
    func updateValues() {
        totalImpressionsLabel.text = "Total Impressions: \(totalImpressions!)"
    }
}

// MARK: - Location Manager Delegate
extension DemoViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        
        beacons.forEach { beacon in
            if let index = beaconList.index(where: { $0.1.proximityUUID.uuidString == beacon.proximityUUID.uuidString && $0.1.major == beacon.major && $0.1.minor == beacon.minor }) {
                if beacon.proximity == .far {
                    beaconList.remove(at: index)
                } else {
                    beaconList[index] = (region, beacon)
                }
            } else {
                if beacon.proximity == .immediate {
                    beaconList.append((region, beacon))
                    totalImpressions = totalImpressions + 1
                }
            }
        }
    }
}
