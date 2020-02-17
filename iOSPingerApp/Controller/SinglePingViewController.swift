//
//  SinglePingViewController.swift
//  iOSPingerApp
//
//  Created by Mantas Paškevičius on 09/02/2020.
//  Copyright © 2020 Mantas Paškevičius. All rights reserved.
//

import UIKit

class SinglePingViewController: UIViewController{
    @IBOutlet weak var ipAddressTextField: UITextField!
    @IBOutlet weak var numberOfRetriesLabel: UILabel!
    @IBOutlet weak var numberOfTimeoutsLabel: UILabel!
    @IBOutlet weak var reachabilityLabel: UILabel!
    @IBOutlet weak var pingButton: UIButton!
    @IBOutlet weak var numberOfRetriesStepper: UIStepper!
    @IBOutlet weak var timeoutSecodsStepper: UIStepper!
    private var pingBrain: PingBrain?
    private var numberOfRetries: Int?
    private var timeOutSeconds: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPingBrain()
        setupInitialLabelValues()
        setupInitialStepperValues()
        // Do any additional setup after loading the view.
        self.ipAddressTextField.delegate = self
    }
    
    //MARK: Setup funtions
    private func setupPingBrain() {
        if pingBrain == nil {
            pingBrain = PingBrain()
        }
        let pingResult = PingResult(ipAddress: "", isConnected: false, pingBrain: pingBrain!)
        setOnConnectionStatusChangedExtensionOnPingResult(pingResult)
        pingBrain?.setPingResultArray([pingResult])
    }
    
    private func setOnConnectionStatusChangedExtensionOnPingResult(_ pingResult: PingResult) {
        pingResult.onConnectionStatusChanged = self
    }
    
    //MARK: IBAction functions
    @IBAction func numberOfRetriesStepperChanged(_ sender: UIStepper) {
        numberOfRetries = Int(sender.value)
        numberOfRetriesLabel.text = String(numberOfRetries!)
    }
    
    @IBAction func timeoutSecondsStepperChanged(_ sender: UIStepper) {
        timeOutSeconds = Int(sender.value)
        numberOfTimeoutsLabel.text = String(timeOutSeconds!)
    }
    
    @IBAction func pingButtonPressed(_ sender: UIButton) {
        pingBrain?.setDefaults()
        pingBrain?.setPingResultIpAddressByIndex(index: 0, ipAddress: ipAddressTextField.text ?? "")
        pingBrain?.checkReachabilityOfPingResultArray()
        pingButton.isEnabled = false
    }
    
    @IBAction func backBarButtonPressed(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: Appearance
    private func setReachabilityLabelAppearance() {
        let pingResultArray = pingBrain?.getPingResultArray()
        let pingResult = pingResultArray![0]
        
        if pingResult.getIsConnected() {
            setReachabilityLabelToReachable()
        } else if pingResult.getIsRunning() {
            setReachabilityLabelToLoading()
        } else {
            setReachabilityLabelToNotReachable()
        }
    }
    
    private func setPingButtonStatus() {
        
        let pingResultArray = pingBrain?.getPingResultArray()
        let pingResult = pingResultArray![0]
        
        if pingResult.getIsConnected() {
            setPingResultButtonEnable(isEnabled: true)
        } else if pingResult.getIsRunning() {
            setPingResultButtonEnable(isEnabled: false)
        } else {
            setPingResultButtonEnable(isEnabled: true)
        }
    }
    
    private func setReachabilityLabelToReachable() {
        reachabilityLabel.text = "Reachable"
        reachabilityLabel.textColor = .green
    }
    
    private func setReachabilityLabelToLoading() {
        reachabilityLabel.text = "Loading..."
        reachabilityLabel.textColor = .orange
    }
    
    private func setReachabilityLabelToNotReachable() {
        reachabilityLabel.text = "Not Reachable"
        reachabilityLabel.textColor = .red
    }
    
    private func setPingResultButtonEnable(isEnabled: Bool) {
        pingButton.isEnabled = isEnabled
    }
    
    private func setupInitialLabelValues() {
        numberOfRetriesLabel.text = String(pingBrain?.getNumberOfRetries() ?? 1)
        numberOfTimeoutsLabel.text = String(pingBrain?.getTimeoutSeconds() ?? 1)
    }
    
    private func setupInitialStepperValues() {
        numberOfRetriesStepper.value = Double(pingBrain?.getNumberOfRetries() ?? 1)
        timeoutSecodsStepper.value = Double(pingBrain?.getTimeoutSeconds() ?? 1)
    }
}

//MARK: Extensions
extension SinglePingViewController: onConnectionStatusChangedDelegate {
    func connectionStatusChanged(index: Int) {
        setReachabilityLabelAppearance()
        setPingButtonStatus()
    }
}

extension SinglePingViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}
