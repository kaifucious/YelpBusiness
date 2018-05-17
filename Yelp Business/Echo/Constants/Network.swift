//
//  Network.swift
//  Yelp Business
//
//  Created by Ghost Maverick on 5/16/18.
//  Copyright © 2018 Developer. All rights reserved.
//

import Foundation
import Alamofire
import CoreLocation
import SystemConfiguration

class Network: Echoable
{
    private var networkConnected: Bool!
    private var networkStatusTimer: Timer?

    init()
    {
        self.networkStatusTimer = Timer.scheduledTimer(timeInterval: 1.0,
                                                       target: self,
                                                       selector: #selector(self.updateNetworkStatus(sender:)),
                                                       userInfo: nil,
                                                       repeats: true)
    }
    
    // MARK: -Echo Handler
    func handle(intendedObserverNames: [String], dispatcher: Dispatchable, object: EchoObject) { }
    
    // MARK: -Network Connection Checker
    private func isConnectedToNetwork() -> Bool
    {
        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) { zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
        if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
            return false
        }

        // Working for Cellular and WIFI
        let isReachable = flags.rawValue & UInt32(kSCNetworkFlagsReachable) != 0
        let needsConnection = flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired) != 0
        let ret = isReachable && !needsConnection
        
        return ret
    }
    
    // MARK: -Network Status Updates
    @objc func updateNetworkStatus(sender: Timer)
    {
        let connected = self.isConnectedToNetwork()
   
        if self.networkConnected == nil {
            // We havent checked for a connection yet
            self.networkConnected = connected
            
            let object: NetworkObject = .networkStatusUpdated(self.networkConnected)
            object.emit(qos: .main, intendedObserverNames: nil, dispatcher: self)
        } else {
            // If there is no change to the network status, there is no need to emit anything
            guard connected != self.networkConnected else { return }
            self.networkConnected = connected
            
            let object: NetworkObject = .networkStatusUpdated(self.networkConnected)
            object.emit(qos: .main, intendedObserverNames: nil, dispatcher: self)
        } 
    }
}
