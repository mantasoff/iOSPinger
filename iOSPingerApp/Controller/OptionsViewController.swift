//
//  OptionsViewController.swift
//  iOSPingerApp
//
//  Created by Mantas Paškevičius on 03/02/2020.
//  Copyright © 2020 Mantas Paškevičius. All rights reserved.
//

import UIKit

protocol onOptionsSave {
    func changeTheOptions(numberOfThreads: Int, numberOfRetries: Int, timeOutSecods: Int)
    func buttonPressedSortPingResultArrayByReachabilityAscending()
    func buttonPressedSortPingResultArrayByReachabilityDescending()
    func buttonPressedSortPingResultArrayByIPAddressAscending()
    func buttonPressedSortPingResultArrayByIPAddressDescending()
}

class OptionsViewController: UIViewController {
    var onOptionsSaved: onOptionsSave!
    @IBOutlet weak var numberOfThreadsLabel: UILabel!
    @IBOutlet weak var numberOfRetriesLabel: UILabel!
    @IBOutlet weak var timeoutSecondsLabel: UILabel!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var numberOfThreadsStepper: UIStepper!
    @IBOutlet weak var numberOfRetriesStepper: UIStepper!
    @IBOutlet weak var timeoutSecondsStepper: UIStepper!
    
    private var pingResultTableViewController: PingResultTableViewController?
    private var numberOfThreads: Int?
    private var numberOfRetries: Int?
    private var timeOutSeconds: Int?
    private var needToReloadRows = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setInitialValues()
        setButtonAppearance()
        setStepperInitialValues()
    }
    
    @IBAction func numberOfThreadsStepperChanged(_ sender: UIStepper) {
        numberOfThreads = Int(sender.value)
        numberOfThreadsLabel.text = String(numberOfThreads!)
    }
    
    @IBAction func numberOfRetriesStepperChanged(_ sender: UIStepper) {
        numberOfRetries = Int(sender.value)
        numberOfRetriesLabel.text = String(numberOfRetries!)
    }
    
    @IBAction func timeoutSecondsStepperChanged(_ sender: UIStepper) {
        timeOutSeconds = Int(sender.value)
        timeoutSecondsLabel.text = String(timeOutSeconds!)
    }
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        onOptionsSaved.changeTheOptions(numberOfThreads: numberOfThreads ?? 1, numberOfRetries: numberOfRetries ?? 1, timeOutSecods: timeOutSeconds ?? 1)
        if needToReloadRows {
            pingResultTableViewController?.tableView.reloadData()
        }
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func sortByIPAscendingButtonPressed(_ sender: UIButton) {
        needToReloadRows = true
        onOptionsSaved.buttonPressedSortPingResultArrayByIPAddressAscending()
    }
    
    @IBAction func sortByIPDescendingButtonPressed(_ sender: UIButton) {
        needToReloadRows = true
        onOptionsSaved.buttonPressedSortPingResultArrayByIPAddressDescending()
    }
    
    @IBAction func sortByReachabilityAscendingButtonPressed(_ sender: UIButton) {
        needToReloadRows = true
        onOptionsSaved.buttonPressedSortPingResultArrayByReachabilityAscending()
    }
    
    @IBAction func sortByReachabilityDescendingButtonPressed(_ sender: UIButton) {
        needToReloadRows = true
        onOptionsSaved.buttonPressedSortPingResultArrayByReachabilityDescending()
    }
    
    private func setInitialValues() {
        numberOfThreadsLabel.text = String(numberOfThreads!)
        numberOfRetriesLabel.text = String(numberOfRetries!)
        timeoutSecondsLabel.text = String(timeOutSeconds!)
    }
    
    private func setButtonAppearance() {
        saveButton.layer.cornerRadius = 10.0
        saveButton.layer.borderWidth = 1
        saveButton.layer.borderColor = UIColor.blue.cgColor
    }

    private func setStepperInitialValues() {
        numberOfThreadsStepper.value = Double(numberOfThreads ?? 1)
        numberOfRetriesStepper.value = Double(numberOfRetries ?? 1)
        timeoutSecondsStepper.value = Double(timeOutSeconds ?? 1)
    }
    
    //============================================================ Setters
    func setNumberOfThreads(numberOfThreads: Int) {
        self.numberOfThreads = numberOfThreads
    }
    
    func setNumberOfRetries(numberOfRetries: Int) {
        self.numberOfRetries = numberOfRetries
    }
    
    func setTimeOutSeconds(timeOutSeconds: Int) {
        self.timeOutSeconds = timeOutSeconds
    }
    
    func setPingResultTableViewController(pingResultTableViewController: PingResultTableViewController) {
        self.pingResultTableViewController = pingResultTableViewController
    }
}
