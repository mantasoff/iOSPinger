//
//  PingBrain.swift
//  iOSPingerApp
//
//  Created by Mantas Paškevičius on 30/01/2020.
//  Copyright © 2020 Mantas Paškevičius. All rights reserved.
//

import Foundation
import Reachability

class PingBrain{
    private var pingResultArray: [PingResult]?
    private var shouldStartRunning = true
    private var numberOfRetries = 1 //  number of times when a ping is done an IP address if unsucssesful
    private var numberOfRunningEntries = 0
    private var allowedNumberOfRunningEntries = 100
    private var nextEntryToRun = 0
    private var timeOutSeconds = 3;
    private var isStarted = false
    private var numberOfFinishedEntries = 0
    private var numberOfConnectedEntries = 0
    
    func checkReachabilityOfPingResultArray() {
        numberOfRunningEntries = 0
        nextEntryToRun = allowedNumberOfRunningEntries
        isStarted = true
        for pingResult in pingResultArray! {
            if numberOfRunningEntries >= allowedNumberOfRunningEntries {
                return
            }
            numberOfRunningEntries += 1
            runPingOnPingResult(pingResult: pingResult)
        }
    }
    
    func runNextPingFromPingResult(pingResult: PingResult) {
        //let lastRanPingResultIndex = pingResultArray?.firstIndex(of: pingResult)
        if nextEntryToRun + 1 > pingResultArray!.count {
            return
        }
        
        let nextEntryToBeRan = nextEntryToRun
        runPingOnPingResult(pingResult: pingResultArray![nextEntryToBeRan])
        nextEntryToRun += 1
    }
    
    func isPossibleToRetryPing(pingResult: PingResult) -> Bool {
        return pingResult.getTimesRan() < numberOfRetries
    }
    
    func runPingOnPingResult(pingResult: PingResult) {
        if isStarted {
            pingResult.setIsRunning(isRunning: true)
            pingResult.pingIpAddress()
        } else {
            print("Stopping Queue")
        }
    }
    
    func generatePingResultArray() {
        let networkBrain = NetworkBrain()
        pingResultArray = [] as [PingResult]
        let initialIp = networkBrain.removeLastNumberOfAddress(ipAddress: networkBrain.getIPAddress())
        var i = 0;
        while(i < 256) {        //An IP address ending can be from 0..255 inclusively, but 0 and 255 are rarely used
            pingResultArray! += [PingResult(ipAddress: initialIp + String(i), isConnected: false, pingBrain: self)]
            i += 1
        }
    }
    //================================ Sorting Functions
    internal func sortPingResultArrayByReachabilityAscending() {
        if pingResultArray != nil {
            pingResultArray?.sort(by: { (PingResult1, PingResult2) -> Bool in
                return PingResult1.getIsConnected()
            })
        }
    }
    
    internal func sortPingResultArrayByReachabilityDescending() {
        if pingResultArray != nil {
            pingResultArray?.sort(by: { (PingResult1, PingResult2) -> Bool in
                return !PingResult1.getIsConnected()
            })
        }
    }
    
    func sortPingResultArrayByIPAddressAscending() {
        if pingResultArray != nil {
            let networkBrain = NetworkBrain()
            
            pingResultArray?.sort(by: { (PingResult1, PingResult2) -> Bool in
                let pingResult1LastNumberString = networkBrain.getLastNumberOfAddress(ipAddress: PingResult1.getIpAddress())
                let pingResult2LastNumberString = networkBrain.getLastNumberOfAddress(ipAddress: PingResult2.getIpAddress())
                return (Int(pingResult1LastNumberString) ?? -1) <= (Int(pingResult2LastNumberString) ?? -1)
            })
        }
    }
    
    func sortPingResultArrayByIPAddressDescending() {
        if pingResultArray != nil {
            let networkBrain = NetworkBrain()
            
            pingResultArray?.sort(by: { (PingResult1, PingResult2) -> Bool in
                let pingResult1LastNumberString = networkBrain.getLastNumberOfAddress(ipAddress: PingResult1.getIpAddress())
                let pingResult2LastNumberString = networkBrain.getLastNumberOfAddress(ipAddress: PingResult2.getIpAddress())
                return (Int(pingResult1LastNumberString) ?? -1) >= (Int(pingResult2LastNumberString) ?? -1)
            })
        }
    }
    
    //================================ Getters and setters
    func stopPinging() {
        isStarted = false
    }
    
    func checkIfIsStarted() -> Bool {
        return isStarted
    }
    
    func addToNumberOfFinishedEntries() {
        numberOfFinishedEntries += 1
    }
    
    func getNumberOfFinishedEntries() -> Int {
        return numberOfFinishedEntries
    }
    
    func addToNumberOfConnectedEntries() {
        numberOfConnectedEntries += 1
    }
    
    func getNumberOfConnectedEntries() -> Int {
        return numberOfConnectedEntries
    }
    
    func getTimeoutSeconds() -> Int {
        return timeOutSeconds
    }
    
    func getNumberOfRetries() -> Int {
        return numberOfRetries
    }
    
    func getIsStarted() -> Bool {
        return isStarted
    }
    
    func getAllowedNumberOfRunningEntries() -> Int {
        return allowedNumberOfRunningEntries
    }
    
    func getPingResultArrayCount() -> Int {
        return pingResultArray?.count ?? 0
    }
    
    func setPingResultArray(pingResultArray: [PingResult]) {
        self.pingResultArray = pingResultArray
    }
    
    func getPingResultArray() -> [PingResult] {
        return pingResultArray!
    }
    
    func getPingResultIndexInPingResultArray(pingResult: PingResult) -> Int {
        return pingResultArray?.firstIndex(of: pingResult) ?? -1
    }
}

//============================ Extension to make a call on the OptionViewController
extension PingBrain: onOptionsSave {
    func changeTheOptions(numberOfThreads: Int, numberOfRetries: Int, timeOutSecods: Int) {
        allowedNumberOfRunningEntries = numberOfThreads
        self.numberOfRetries = numberOfRetries
        self.timeOutSeconds = timeOutSecods
    }
    func buttonPressedSortPingResultArrayByReachabilityAscending() {
        sortPingResultArrayByReachabilityAscending()
    }
    func buttonPressedSortPingResultArrayByReachabilityDescending() {
        sortPingResultArrayByReachabilityDescending()
    }
    func buttonPressedSortPingResultArrayByIPAddressAscending() {
        sortPingResultArrayByIPAddressAscending()
    }
    func buttonPressedSortPingResultArrayByIPAddressDescending() {
        sortPingResultArrayByIPAddressDescending()
    }
}
