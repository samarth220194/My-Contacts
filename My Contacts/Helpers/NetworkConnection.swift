//
//  NetworkConnection.swift
//  My Contacts
//
//  Created by Samarth Kejriwal on 09/06/19.
//  Copyright © 2019 Samarth Kejriwal. All rights reserved.
//

import Reachability


class NetworkConnection: NSObject
{
    var reachability: Reachability!
    
    static let sharedInstance: NetworkConnection = { return NetworkConnection() }()
    
    
    override init() {
        super.init()
        
        reachability = Reachability()!
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(networkStatusChanged(_:)),
            name: .reachabilityChanged,
            object: reachability
        )
        
        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
    }
    
    @objc func networkStatusChanged(_ notification: Notification) {
        // Do something globally here!
    }
    
    static func stopNotifier() -> Void {
        do {
            try (NetworkConnection.sharedInstance.reachability).startNotifier()
        } catch {
            print("Error stopping notifier")
        }
    }
    
    static func isReachable(completed: @escaping (NetworkConnection) -> Void) {
        if (NetworkConnection.sharedInstance.reachability).connection != .none {
            completed(NetworkConnection.sharedInstance)
        }
    }
    
    static func isUnreachable(completed: @escaping (NetworkConnection) -> Void) {
        if (NetworkConnection.sharedInstance.reachability).connection == .none {
            completed(NetworkConnection.sharedInstance)
        }
    }
    
    static func isReachableViaWWAN(completed: @escaping (NetworkConnection) -> Void) {
        if (NetworkConnection.sharedInstance.reachability).connection == .cellular {
            completed(NetworkConnection.sharedInstance)
        }
    }
    
    static func isReachableViaWiFi(completed: @escaping (NetworkConnection) -> Void) {
        if (NetworkConnection.sharedInstance.reachability).connection == .wifi {
            completed(NetworkConnection.sharedInstance)
        }
    }
    
}
