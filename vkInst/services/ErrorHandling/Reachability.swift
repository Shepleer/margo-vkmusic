//
//  Reachability.swift
//  vkInst
//
//  Created by Ivan Shpileuski on 9/11/19.
//  Copyright © 2019 Ivan Shpileuski. All rights reserved.
//

import SystemConfiguration

public class Reachability {
    class func isConnectedToNetwork() -> Bool {
        var zeroAdress = sockaddr_in(sin_len: 0,
                                     sin_family: 0,
                                     sin_port: 0,
                                     sin_addr: in_addr(s_addr: 0),
                                     sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAdress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAdress))
        zeroAdress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouterReachability = withUnsafePointer(to: &zeroAdress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        })
        
        var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
        guard let defaultReachability = defaultRouterReachability else { fatalError() }
        if SCNetworkReachabilityGetFlags(defaultReachability, &flags) == false {
            return false
        }
        let isReachable: Bool = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection: Bool = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        
        return isReachable && !needsConnection
    }
}
