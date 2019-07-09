//
//  ReachabilityObserverDelegate.swift
//  ThisIsMyArea
//
//  Created by Sean Tee on 09/07/2019.
//  Copyright © 2019 Sean. All rights reserved.
//

import Foundation
import Reachability


fileprivate var reachability: Reachability!

protocol ReachabilityActionDelegate {
    func onConnectedToWifi(bssid: String?)
}

protocol ReachabilityObserverDelegate: class, ReachabilityActionDelegate {
    func addReachabilityObserver()
    func removeReachabilityObserver()
}

// Declaring default implementation of adding/removing observer
extension ReachabilityObserverDelegate {
    
    /** Subscribe on reachability changing */
    func addReachabilityObserver() {
        reachability = Reachability()
        
        reachability.whenReachable = { [weak self] reachability in
            if reachability.connection == .wifi {
                if let bssid = Utility.getWiFiBSSID(){
                    self?.onConnectedToWifi(bssid: bssid)
                }
            } else {
                  self?.onConnectedToWifi(bssid: nil)
            }
        }
        
        reachability.whenUnreachable = { [weak self] reachability in
            self?.onConnectedToWifi(bssid: nil)
        }
        
        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
    }
    
    /** Unsubscribe */
    func removeReachabilityObserver() {
        reachability.stopNotifier()
        reachability = nil
    }
}
