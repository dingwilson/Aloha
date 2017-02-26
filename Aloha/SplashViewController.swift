//
//  SplashViewController.swift
//  Aloha
//
//  Created by Wilson Ding on 2/26/17.
//  Copyright © 2017 Wilson Ding. All rights reserved.
//

import UIKit
import SwiftVideoBackground

class SplashViewController: UIViewController {

    @IBOutlet weak var backgroundVideo: BackgroundVideo!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        backgroundVideo.createBackgroundVideo(name: "Background", type: "mp4", alpha: 0.25)
    }
    
    

}
