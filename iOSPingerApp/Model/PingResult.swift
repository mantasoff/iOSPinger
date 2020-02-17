//
//  PingResult.swift
//  iOSPingerApp
//
//  Created by Mantas Paškevičius on 01/02/2020.
//  Copyright © 2020 Mantas Paškevičius. All rights reserved.
//

import Foundation
import Reachability

protocol onConnectionStatusChangedDelegate {
    func connectionStatusChanged(index: Int)
}

class PingResult : Equatable {
    private var ipAddress: String
    private var isConnected: Bool
    private var timesRan: Int = 0
    private var finishedRunning = false
    private var isRunning = false
    private var pingBrain: PingBrain
    private var reachability: Reachability?
    var onConnectionStatusChanged: onConnectionStatusChangedDelegate!
    
    init(ipAddress: String, isConnected: Bool, pingBrain: PingBrain) {
        self.ipAddress = ipAddress
        self.isConnected = isConnected
        self.pingBrain = pingBrain
    }
    
    func pingIpAddress() {
        reachability = try? Reachability(hostname: ipAddress)
        reachability?.allowsCellularConnection = false

        isRunning = true
        self.onConnectionStatusChanged.connectionStatusChanged(index: pingBrain.getPingResultIndexInPingResultArray(pingResult: self))
        
        self.reachability?.whenReachable = { reachability in
            self.updatePingResultConnection(isConnected: true)
            reachability.stopNotifier()
        }
        
        self.reachability?.whenUnreachable = { reachability in
            self.updatePingResultConnection(isConnected: false)
            reachability.stopNotifier()
        }
        
        DispatchQueue.global().asyncAfter(deadline: .now() + Double(pingBrain.getTimeoutSeconds()), execute: {
            do {
                try self.reachability?.startNotifier()
            } catch  {
                print("The Reachability Library seems to be working incorrectly. Please restart the program if the problem continues")
            }
        })
    }
    
    func setDefault() {
        isConnected = false
        timesRan = 0
        finishedRunning = false
        isRunning = false
    }
    
    func updatePingResultConnection(isConnected: Bool) {
        self.isConnected = isConnected
        if self.isConnected {
            self.isRunning = false
            self.pingBrain.runNextPing()
            self.pingBrain.addToNumberOfConnectedEntries()
        } else {
            self.timesRan += 1
            if self.pingBrain.isPossibleToRetryPing(pingResult: self) {
                self.pingBrain.runPingOnPingResult(pingResult: self);
                return
            }
            self.isRunning = false
            self.pingBrain.runNextPing()
        }
        pingBrain.addToNumberOfFinishedEntriesAndSendNotification()
        onConnectionStatusChanged.connectionStatusChanged(index: pingBrain.getPingResultIndexInPingResultArray(pingResult: self))
    }
    
    //MARK: Equality Methods
    static func ==(lhs: PingResult, rhs: PingResult) -> Bool {
        return lhs.isEqual(to: rhs)
    }
    
    func isEqual(to: PingResult) -> Bool {
        return((ipAddress == to.ipAddress) && (isConnected == to.isConnected) && (timesRan == to.timesRan))
    }
    
    //MARK: Getters and Setters
    func getIsRunning() -> Bool {
        return isRunning
    }
    
    func setIsRunning(isRunning: Bool) {
        self.isRunning = isRunning
    }
    
    func getTimesRan() -> Int {
        return timesRan
    }
    
    func getIsConnected() -> Bool {
        return isConnected
    }
    
    func getIpAddress() -> String {
        return ipAddress
    }
    
    func setIpAddress(ipAddress: String) {
        self.ipAddress = ipAddress
    }
}
