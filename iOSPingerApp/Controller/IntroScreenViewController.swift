//
//  IntroScreenViewController.swift
//  iOSPingerApp
//
//  Created by Mantas Paškevičius on 08/02/2020.
//  Copyright © 2020 Mantas Paškevičius. All rights reserved.
//

import UIKit

class IntroScreenViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func pingLocalNetworkPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "PingResultTableViewSegue", sender: self)
    }
    @IBAction func pingSpecificIPPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "SinglePingSegue", sender: self)
    }
}
