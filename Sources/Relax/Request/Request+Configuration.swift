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
    /// Defines configuration options for requests to use
    public struct Configuration: Hashable {
        /// Allow access on cellular networks
        ///
        /// See [`allowsCellularAccess`](https://developer.apple.com/documentation/foundation/urlrequest/2011607-allowscellularaccess)
        public var allowsCellularAccess: Bool
        /// The cache policy of the request
        public var cachePolicy: URLRequest.CachePolicy
        /// Whether to continue transmitting data before receiving a response from an earlier transmission
        ///
        /// See [`httpShouldUsePipelining`](https://developer.apple.com/documentation/foundation/nsurlrequest/1409170-httpshouldusepipelining)
        public var httpShouldUsePipelining: Bool
        /// The service type of the request
        ///
        /// See [`networkServiceType`](https://developer.apple.com/documentation/foundation/urlrequest/2011409-networkservicetype)
        public var networkServiceType: URLRequest.NetworkServiceType
        /// The timeout interval for the request
        public var timeoutInterval: TimeInterval
        /// Whether cookies should be sent and received
        ///
        /// See [`httpShouldHandleCookies`](https://developer.apple.com/documentation/foundation/urlrequest/2011548-httpshouldhandlecookies)
        public var httpShouldHandleCookies: Bool
        
        /// A configuration structure with all default values
        ///
        /// Default values are:
        /// - allowsCellularAccess: `true`
        /// - cachePolicy: `URLRequest.CachePolicy.useProtocolCachePolicy`
        /// - httpShouldUsePipelining: `false`
        /// - networkServiceType: `URLRequest.NetworkServiceType.default`
        /// - timeoutInterval: 60
        /// - httpShouldHandleCookies: `true`
        ///
        /// Available on iOS, macOS, tvOS, and watchOS only:
        /// - allowsConstrainedNetworkAccess: `true`
        /// - allowsExpensiveNetworkAccess: `true`
        public static var `default`: Configuration {
            Configuration()
        }
        
#if canImport(FoundationNetworking)
        /// Creates a configuration structure
        ///
        /// - Parameters:
        ///   - allowsCellularAccess: Whether to allow cellular access
        ///   - cachePolicy: The cache policy
        ///   - httpShouldUsePipelining: Whether to use pipelining
        ///   - networkServiceType: The network service type
        ///   - timeoutInterval: The timeout interval
        ///   - httpShouldHandleCookies: Whether to handle cookies
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
        /// Allows access on constrained networks
        ///
        /// See [`allowsConstrainedNetworkAccess`](https://developer.apple.com/documentation/foundation/nsmutableurlrequest/3325676-allowsconstrainednetworkaccess)
        /// - Note: Available on iOS, macOS, tvOS, and watchOS only.
        public var allowsConstrainedNetworkAccess: Bool
        /// Allows access on expensive networks
        ///
        /// See [`allowsExpensiveNetworkAccess`](https://developer.apple.com/documentation/foundation/urlrequest/3358305-allowsexpensivenetworkaccess)
        /// - Note: Available on iOS, macOS, tvOS, and watchOS only.
        public var allowsExpensiveNetworkAccess: Bool
        
        /// Creates a configuration structure
        ///
        /// - Parameters:
        ///   - allowsCellularAccess: Whether to allow cellular access
        ///   - cachePolicy: The cache policy
        ///   - httpShouldUsePipelining: Whether to use pipelining
        ///   - networkServiceType: The network service type
        ///   - timeoutInterval: The timeout interval
        ///   - httpShouldHandleCookies: Whether to handle cookies
        ///   - allowsConstrainedNetworkAccess: Whether to allow access to constrained networks
        ///   - allowsExpensiveNetworkAccess: Whether to allow access to expensive networks
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
