//
//  RequestConfiguration.swift
//  
//
//  Created by Thomas De Leon on 10/22/22.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public struct RequestConfiguration {
    var allowsCellularAccess: Bool = true
    var cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy
    var httpShouldUsePipelining: Bool = false
    var networkServiceType: URLRequest.NetworkServiceType = .default
    var timeoutInterval: TimeInterval = 60
    
    #if !canImport(FoundationNetworking)
    var allowsConstrainedNetworkAccess: Bool = true
    var allowsExpensiveNetworkAccess: Bool = true
    var httpShouldHandleCookies: Bool = true
    #endif
}
