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
    @objc func leftBarButtonPressed() {
        if pingBrain!.getIsStarted() {
            setLeftNavigationButtonToStart()
            pingBrain?.stopPinging()
        } else {
            setLeftNavigationButtonToStop()
            pingBrain?.checkReachabilityOfPingResultArray()
        }
    }
    
    @objc func optionsBarButtonPressed() {
        performSegue(withIdentifier: "OptionSegue", sender: self)
    }

    //==================================================== Functions associated with changing the UI
    private func setLeftNavigationButtonToStart() {
        navigationItem.leftBarButtonItem?.title = "Start"
    }
    
    private func setLeftNavigationButtonToStop() {
        navigationItem.leftBarButtonItem?.title = "Stop"
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
        pingResultTableViewCell.statusLabel.textColor = .yellow
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
    
    private func reloadRowByNumber(rowNumber: Int) {
        DispatchQueue.main.async {
            let indexPath = NSIndexPath(item: rowNumber - 1, section: 0) as IndexPath
            self.tableView.reloadRows(at: [indexPath], with: .fade)
        }
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


