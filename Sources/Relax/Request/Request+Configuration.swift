//
//  Request+Configuration.swift
//  
//
//  Created by Thomas De Leon on 10/22/22.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

extension Request {
    /// <#Description#>
    public struct Configuration: Hashable {
        public var allowsCellularAccess: Bool
        public var cachePolicy: URLRequest.CachePolicy
        public var httpShouldUsePipelining: Bool
        public var networkServiceType: URLRequest.NetworkServiceType
        public var timeoutInterval: TimeInterval
        public var httpShouldHandleCookies: Bool
        
        public static var `default`: Configuration {
            Configuration()
        }
        
#if canImport(FoundationNetworking)
        /// <#Description#>
        /// - Parameters:
        ///   - allowsCellularAccess: <#allowsCellularAccess description#>
        ///   - cachePolicy: <#cachePolicy description#>
        ///   - httpShouldUsePipelining: <#httpShouldUsePipelining description#>
        ///   - networkServiceType: <#networkServiceType description#>
        ///   - timeoutInterval: <#timeoutInterval description#>
        ///   - httpShouldHandleCookies: <#httpShouldHandleCookies description#>
        public init(
            allowsCellularAccess: Bool = true,
            cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy,
            httpShouldUsePipelining: Bool = false,
            networkServiceType: URLRequest.NetworkServiceType = .default,
            timeoutInterval: TimeInterval = 60,
            httpShouldHandleCookies: Bool = true
        ) {
            self.allowsCellularAccess = allowsCellularAccess
            self.cachePolicy = cachePolicy
            self.httpShouldUsePipelining = httpShouldUsePipelining
            self.networkServiceType = networkServiceType
            self.timeoutInterval = timeoutInterval
            self.httpShouldHandleCookies = httpShouldHandleCookies
        }
#else
        public var allowsConstrainedNetworkAccess: Bool
        public var allowsExpensiveNetworkAccess: Bool
        
        /// <#Description#>
        /// - Parameters:
        ///   - allowsCellularAccess: <#allowsCellularAccess description#>
        ///   - cachePolicy: <#cachePolicy description#>
        ///   - httpShouldUsePipelining: <#httpShouldUsePipelining description#>
        ///   - networkServiceType: <#networkServiceType description#>
        ///   - timeoutInterval: <#timeoutInterval description#>
        ///   - httpShouldHandleCookies: <#httpShouldHandleCookies description#>
        ///   - allowsConstrainedNetworkAccess: <#allowsConstrainedNetworkAccess description#>
        ///   - allowsExpensiveNetworkAccess: <#allowsExpensiveNetworkAccess description#>
        public init(
            allowsCellularAccess: Bool = true,
            cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy,
            httpShouldUsePipelining: Bool = false,
            networkServiceType: URLRequest.NetworkServiceType = .default,
            timeoutInterval: TimeInterval = 60,
            httpShouldHandleCookies: Bool = true,
            allowsConstrainedNetworkAccess: Bool = true,
            allowsExpensiveNetworkAccess: Bool = true
        ) {
            self.allowsCellularAccess = allowsCellularAccess
            self.cachePolicy = cachePolicy
            self.httpShouldUsePipelining = httpShouldUsePipelining
            self.networkServiceType = networkServiceType
            self.timeoutInterval = timeoutInterval
            self.httpShouldHandleCookies = httpShouldHandleCookies
            self.allowsConstrainedNetworkAccess = allowsConstrainedNetworkAccess
            self.allowsExpensiveNetworkAccess = allowsExpensiveNetworkAccess
        }
#endif
    }
}
