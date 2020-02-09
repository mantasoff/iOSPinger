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
    private var numberOfRetries = 2 //  number of times when a ping is done an IP address if unsucssesful
    private var numberOfRunningEntries = 0
    private var allowedNumberOfRunningEntries = 3
    private var timeOutSeconds = 3;
    private var isStarted = false
    private var isPaused = false
    private var numberOfFinishedEntries = 0
    private var numberOfConnectedEntries = 0
    
    func checkReachabilityOfPingResultArray() {
        if pingResultArray == nil {
            return
        }
        if pingResultArray?.count == 0 {
            return
        }
        
        numberOfRunningEntries = 0
        isStarted = true
        while (numberOfRunningEntries < allowedNumberOfRunningEntries && (pingResultArray!.count > numberOfRunningEntries)) {
            runPingOnPingResult(pingResult: pingResultArray![getNextReadyPingResultIndex()])
            numberOfRunningEntries += 1
        }
    }
    
    func runNextPing() {
        let nextEntryToBeRan = getNextReadyPingResultIndex()
        if nextEntryToBeRan == -1 { // getNextReadyPingResultIndex() returns -1 if there are no more entries to be ran
            return
        }
        runPingOnPingResult(pingResult: pingResultArray![nextEntryToBeRan])
    }
    
    func isPossibleToRetryPing(pingResult: PingResult) -> Bool {
        return pingResult.getTimesRan() < numberOfRetries
    }
    
    func runPingOnPingResult(pingResult: PingResult) {
        if isStarted && !isPaused {
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
        if !(networkBrain.checkIfTheIPAddressIsReal(ipAddress: initialIp)) {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "co.mancio.nointernetconnection"), object: nil)
            return
        }
    
        var i = 0;
        while(i < 260) {        //An IP address ending can be from 0..255 inclusively, but 0 and 255 are rarely used
            pingResultArray! += [PingResult(ipAddress: initialIp + String(i), isConnected: false, pingBrain: self)]
            i += 1
        }
    }
    
    private func getNextReadyPingResultIndex() -> Int {
        for pingResult in pingResultArray! {
            if !pingResult.getIsConnected() && !pingResult.getIsRunning() && (pingResult.getTimesRan() < numberOfRetries) {
                return getPingResultIndexInPingResultArray(pingResult: pingResult)
            }
        }
        return -1
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
    
    func setDefaults() {
        for pingResult in pingResultArray! {
            pingResult.setDefault()
        }
        numberOfRunningEntries = 0
        isStarted = false
        isPaused = false
        numberOfFinishedEntries = 0
        numberOfConnectedEntries = 0
    }
    
    //================================ Getters and setters
    func stopPinging() {
        isStarted = false
    }
    
    func checkIfIsStarted() -> Bool {
        return isStarted
    }
    
    func addToNumberOfFinishedEntriesAndSendNotification() {
        numberOfFinishedEntries += 1
        if numberOfFinishedEntries == pingResultArray!.count {
            isStarted = false
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "co.mancio.pingsarefinished"), object: nil)
        }
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
    
    func getIsPaused() -> Bool {
        return isPaused
    }
    
    func setIsPaused(isPaused: Bool) {
        self.isPaused = isPaused
    }
    
    func setPingResultIpAddressByIndex(index: Int, ipAddress: String) {
        if pingResultArray == nil {
            return
        }
        
        pingResultArray![index].setIpAddress(ipAddress: ipAddress)
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
