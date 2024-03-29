//
//  HostConnect.swift
//
//  Created by administrator on 2019/02/04.
//  Copyright © 2019年 Akiko Shinozaki. All rights reserved.
//

import UIKit
import Reachability

protocol HostConnectDelegate{
    func complete(_: Any)
    func failed(status: ConnectionStatus)
//    func failed(error: Error)
}
enum ConnectionStatus {
    case success
    case vpn_error
    case host_res_error
    case notConnect
}

let hostConnect = HostConnect()
var connect:ConnectionStatus = .notConnect

class HostConnect: NSObject {
    var delegate:HostConnectDelegate?
    var ipList:[String] = ["172.17.","172.31."]
    var vpnConnect:Bool = false
    
    var reachability: Reachability?
    var networkStatus = ""
    
        
     func start(hostName:String) {
        print("---------hostconnect start()")
        connect = .notConnect
        stopNotifier()
        
        vpnConnect = IP_Check()
        print(vpnConnect)
        if vpnConnect {
            reachability = try? Reachability(hostname: hostName)
        } else {
            reachability = try? Reachability()
        }

        startNotifier()

        reachability?.whenReachable = { reachability in
            self.updateStatusWhenReachable(reachability)
        }
        reachability?.whenUnreachable = { reachability in
            self.updateStatusWhenNotReachable(reachability)
        }
       
    }

    func updateStatusWhenReachable(_ reachability: Reachability) {
        print(#function)
        print("\(reachability.description) - \(reachability.connection)")
        if IP_Check() {
            connect = .success
            self.delegate?.complete(connect)
        }else {
            connect = .vpn_error
            self.delegate?.failed(status: connect)
        }
    }
    
    func updateStatusWhenNotReachable(_ reachability: Reachability) {
        print(#function)
        print("\(reachability.description) - \(reachability.connection)")

        connect = .notConnect
        self.delegate?.failed(status: .notConnect)
    }
    
    func startNotifier() {
        print("--- start notifier")
        do {
            try reachability?.startNotifier()
        } catch {
            networkStatus = "Unable to start\nnotifier"
            print(networkStatus)
            return
        }
    }
    
    func stopNotifier() {
        print("--- stop notifier")
        reachability?.stopNotifier()
        NotificationCenter.default.removeObserver(self, name: .reachabilityChanged, object: nil)
        reachability = nil
    }

    
    @objc func reachabilityChanged(_ note: Notification) {
        print(#function)
        let reachability = note.object as! Reachability
        
        if reachability.connection != .unavailable {
            updateStatusWhenReachable(reachability)
        } else {
            updateStatusWhenNotReachable(reachability)
        }
    
    }
    
    deinit {
        stopNotifier()
    }
    
    //MARK:- IPアドレスのチェック
    func IP_Check() -> Bool{
        var connect:Bool = false
        print(self.ipList)
        for ip in self.getNetworkInterfaces() {
            for str in self.ipList {
                //ipアドレスに指定の値が含まれていればtrueに
                if ip.hasPrefix(str){
                    //ipAddress = ip
                    connect = true
                }
            }
        }
        return connect
        
    }
    
    // IPアドレスを配列で取得
    func getNetworkInterfaces() -> [String] {
        var address : [String] = []
        
        // Get list of all interfaces on the local machine:
        var ifaddr : UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0 else { return [] }
        guard let firstAddr = ifaddr else { return [] }
        
        // For each interface ...
        for ifptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
            let interface = ifptr.pointee
            
            // Check for IPv4 or IPv6 interface:
            let addrFamily = interface.ifa_addr.pointee.sa_family
            //if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) { //IPv6は今は不要
            if addrFamily == UInt8(AF_INET) {
                // Check interface name:
                //let name = String(cString: interface.ifa_name)
                
                // Convert interface address to a human readable string:
                var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                getnameinfo(interface.ifa_addr, socklen_t(interface.ifa_addr.pointee.sa_len),
                            &hostname, socklen_t(hostname.count),
                            nil, socklen_t(0), NI_NUMERICHOST)
                address.append(String(cString: hostname))
                //print("\(name): \(String(cString: hostname))")
            }
        }
        //print(address)
        freeifaddrs(ifaddr)
        
        return address
    }
    
}
