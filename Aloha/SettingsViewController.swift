//
//  SettingsViewController.swift
//  Aloha
//
//  Created by Wilson Ding on 2/26/17.
//  Copyright © 2017 Wilson Ding. All rights reserved.
//

import UIKit
import FirebaseDatabase

class SettingsViewController: UIViewController {

    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var minorValueTextField: UITextField!
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    var ref: FIRDatabaseReference!
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ref = FIRDatabase.database().reference()
    }

    @IBAction func didPressSubmit(_ sender: Any) {
        if let name = nameTextField.text {
            if let minorValue = minorValueTextField.text {
                self.ref.child("beacons").child(minorValue).setValue(["name": name,
                                                                      "type": segmentedControl.titleForSegment(at: segmentedControl.selectedSegmentIndex)])
            }
        }
    }
    

}
