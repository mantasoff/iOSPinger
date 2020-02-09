//
//  PingResultTableViewController.swift
//  iOSPingerApp
//
//  Created by Mantas Paškevičius on 01/02/2020.
//  Copyright © 2020 Mantas Paškevičius. All rights reserved.
//

import UIKit

class PingResultTableViewController: UITableViewController {

    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var progressLabel: UILabel!
    private var pingBrain: PingBrain?
    
    override func viewDidLoad() {
        setObservers()
        setupPingBrain()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Options", style: .plain, target: self, action: #selector(optionsBarButtonPressed))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Start", style: .plain, target: self, action: #selector(leftBarButtonPressed))
        super.viewDidLoad()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pingBrain!.getPingResultArrayCount()
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "PingResultTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? PingResultTableViewCell else {
            fatalError("The dequeued cell is not an instance of PingResultTableViewCell.")
        }
        // Configure the cell...
        setCellAppearanceByPingResult(pingResultTableViewCell: cell, pingResult: pingBrain!.getPingResultArray()[indexPath.row])
        return cell
    }
      
    //==================================================== Button Action functions
    @IBAction func backButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "backToIntro", sender: self)
    }
    @objc func leftBarButtonPressed() {
        if navigationItem.leftBarButtonItem?.title == "Start" {
            pingBrain?.checkReachabilityOfPingResultArray()
        }
        if navigationItem.leftBarButtonItem?.title == "Pause" {
            pingBrain?.setIsPaused(isPaused: true)
        }
        if navigationItem.leftBarButtonItem?.title == "Continue" {
            pingBrain?.setIsPaused(isPaused: false)
            pingBrain?.checkReachabilityOfPingResultArray()
        }
        if navigationItem.leftBarButtonItem?.title == "Restart" {
            pingBrain?.setDefaults()
            tableView.reloadData()
            pingBrain?.checkReachabilityOfPingResultArray()
        }
        setLeftNavigationButtonAppearance()
    }
    
    @objc func optionsBarButtonPressed() {
        performSegue(withIdentifier: "OptionSegue", sender: self)
    }

    //==================================================== Functions associated with changing the UI
    private func setLeftNavigationButtonToStart() {
        navigationItem.leftBarButtonItem?.title = "Start"
    }
    
    private func setLeftNavigationButtonToPause() {
        navigationItem.leftBarButtonItem?.title = "Pause"
    }
    
    private func setLeftNavigationButtonToContinue() {
        navigationItem.leftBarButtonItem?.title = "Continue"
    }
    
    private func setLeftNavigationButtonToRestart() {
        navigationItem.leftBarButtonItem?.title = "Restart"
    }
    
    private func setCellToReachable(_ pingResultTableViewCell: PingResultTableViewCell) {
        pingResultTableViewCell.statusLabel.text = "Reachable"
        pingResultTableViewCell.statusLabel.textColor = .green
    }
    
    private func setCellToNotReachable(_ pingResultTableViewCell: PingResultTableViewCell) {
        pingResultTableViewCell.statusLabel.text = "Not Reachable"
        pingResultTableViewCell.statusLabel.textColor = .red
    }
    
    private func setCellToLoading(_ pingResultTableViewCell: PingResultTableViewCell) {
        pingResultTableViewCell.statusLabel.text = "Loading..."
        pingResultTableViewCell.statusLabel.textColor = .orange
    }
    
    private func setProgressBarValue(numberOfFinishedEntries: Int, numberOfEntries: Int) {
        let progress = (1.0 / Float(numberOfEntries)) * Float(numberOfFinishedEntries)
        progressBar.setProgress(progress, animated: true)
    }
    
    private func setProgressLabelValue(numberOfConnectedEntries: Int, numberOfEntries: Int) {
        progressLabel.text = "\(numberOfConnectedEntries) out of \(numberOfEntries) are reachable"
    }
    
    private func setCellAppearanceByPingResult(pingResultTableViewCell:
        PingResultTableViewCell, pingResult: PingResult) {
        
        pingResultTableViewCell.ipAddressLabel.text = pingResult.getIpAddress()
        if pingResult.getIsConnected() {
            setCellToReachable(pingResultTableViewCell)
        } else if pingResult.getIsRunning() {
            setCellToLoading(pingResultTableViewCell)
        } else {
            setCellToNotReachable(pingResultTableViewCell)
        }
    }
    
    private func setLeftNavigationButtonAppearance() {
        if pingBrain == nil {
            print("PingBrain seems to be not initialized")
            return
        }
        
        if pingBrain!.getIsStarted() && pingBrain!.getIsPaused() {
            setLeftNavigationButtonToContinue()
        }
        if pingBrain!.getIsStarted() && !pingBrain!.getIsPaused() {
            setLeftNavigationButtonToPause()
        }
        if pingBrain!.getPingResultArrayCount() == pingBrain?.getNumberOfFinishedEntries() {
            setLeftNavigationButtonToRestart()
        }
        if !pingBrain!.getIsStarted() && (pingBrain?.getNumberOfFinishedEntries() == 0) {
            setLeftNavigationButtonToStart()
        }
    }
    
    private func reloadRowByNumber(rowNumber: Int) {
        DispatchQueue.main.async {
            let indexPath = NSIndexPath(item: rowNumber - 1, section: 0) as IndexPath
            self.tableView.reloadRows(at: [indexPath], with: .fade)
        }
    }
    
    //================================================ Notification Observers
    private func setObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(setPingsFinished), name: NSNotification.Name(rawValue: "co.mancio.pingsarefinished"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(setNoInternetConnection), name: NSNotification.Name(rawValue: "co.mancio.nointernetconnection"), object: nil)
    }
    
    //================================================ Notification Observer Functions
    @objc private func setPingsFinished() {
        setLeftNavigationButtonAppearance()
    }
    
    @objc private func setNoInternetConnection() {
        progressLabel.text = "Please Check Your Connection"
    }

    //================================================ Setup functions
    private func setOnConnectionStatusChangedExtensionOnPingResultArray(pingResultArray: [PingResult]) {
        for pingResult in pingResultArray {
            pingResult.onConnectionStatusChanged = self
        }
    }
    
    private func setupPingBrain() {
        if pingBrain == nil {
            pingBrain = PingBrain()
        }
        pingBrain?.generatePingResultArray()
        let pingResultArray = pingBrain!.getPingResultArray()
        setOnConnectionStatusChangedExtensionOnPingResultArray(pingResultArray: pingResultArray)
        pingBrain?.setPingResultArray(pingResultArray: pingResultArray)
    }
    
    //================================================ Preparation for changing the UIView
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "OptionSegue" {
            let optionsViewController = segue.destination as! OptionsViewController
            optionsViewController.onOptionsSaved = pingBrain
            optionsViewController.setNumberOfThreads(numberOfThreads: pingBrain!.getAllowedNumberOfRunningEntries())
            optionsViewController.setNumberOfRetries(numberOfRetries: pingBrain!.getNumberOfRetries())
            optionsViewController.setTimeOutSeconds(timeOutSeconds: pingBrain!.getTimeoutSeconds())
            optionsViewController.setPingResultTableViewController(pingResultTableViewController: self)
        }
    }
}

extension PingResultTableViewController: onConnectionStatusChangedDelegate {
    func connectionStatusChanged(index: Int) {
        reloadRowByNumber(rowNumber: index)
        setProgressBarValue(numberOfFinishedEntries: pingBrain!.getNumberOfFinishedEntries(), numberOfEntries: pingBrain!.getPingResultArrayCount())
        setProgressLabelValue(numberOfConnectedEntries: pingBrain!.getNumberOfConnectedEntries(), numberOfEntries: pingBrain!.getPingResultArrayCount())
    }
}


