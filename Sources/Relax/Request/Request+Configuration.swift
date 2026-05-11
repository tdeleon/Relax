//
//  Request+Configuration.swift
//  
//
//  Created by Thomas De Leon on 10/22/22.
//

import Foundation
#if canImport(FoundationNetworking)
@preconcurrency import FoundationNetworking
#endif

public struct SendOptions: Sendable, Hashable {
    public var cachePolicy: URLRequest.CachePolicy?
    public var timeoutInterval: TimeInterval?
    public var httpShouldHandleCookies: Bool?
    public var allowsCellularAccess: Bool?
    public var networkServiceType: URLRequest.NetworkServiceType?
    
    #if !canImport(FoundationNetworking)
    public var allowsConstrainedNetworkAccess: Bool?
    public var allowsExpensiveNetworkAccess: Bool?
    
    public init(
        cachePolicy: URLRequest.CachePolicy? = nil,
        timeoutInterval: TimeInterval? = nil,
        httpShouldHandleCookies: Bool? = nil,
        allowsCellularAccess: Bool? = nil,
        networkServiceType: URLRequest.NetworkServiceType? = nil,
        allowsConstrainedNetworkAccess: Bool? = nil,
        allowsExpensiveNetworkAccess: Bool? = nil
    ) {
        self.cachePolicy = cachePolicy
        self.timeoutInterval = timeoutInterval
        self.httpShouldHandleCookies = httpShouldHandleCookies
        self.allowsCellularAccess = allowsCellularAccess
        self.networkServiceType = networkServiceType
        self.allowsConstrainedNetworkAccess = allowsConstrainedNetworkAccess
        self.allowsExpensiveNetworkAccess = allowsExpensiveNetworkAccess
    }
    #else
    public init(
        cachePolicy: URLRequest.CachePolicy? = nil,
        timeoutInterval: TimeInterval? = nil,
        httpShouldHandleCookies: Bool? = nil,
        allowsCellularAccess: Bool? = nil,
        networkServiceType: URLRequest.NetworkServiceType? = nil
    ) {
        self.cachePolicy = cachePolicy
        self.timeoutInterval = timeoutInterval
        self.httpShouldHandleCookies = httpShouldHandleCookies
        self.allowsCellularAccess = allowsCellularAccess
        self.networkServiceType = networkServiceType
        self.allowsConstrainedNetworkAccess = allowsConstrainedNetworkAccess
        self.allowsExpensiveNetworkAccess = allowsExpensiveNetworkAccess
    }
    #endif
    
    internal var hasSetOptions: Bool {
        self != SendOptions()
    }
}

extension URLRequest {
    internal mutating func apply(options: SendOptions) {
        if let cachePolicy = options.cachePolicy {
            self.cachePolicy = cachePolicy
        }
        if let timeoutInterval = options.timeoutInterval {
            self.timeoutInterval = timeoutInterval
        }
        if let httpShouldHandleCookies = options.httpShouldHandleCookies {
            self.httpShouldHandleCookies = httpShouldHandleCookies
        }
        if let allowsCellularAccess = options.allowsCellularAccess {
            self.allowsCellularAccess = allowsCellularAccess
        }
        if let networkServiceType = options.networkServiceType {
            self.networkServiceType = networkServiceType
        }
        #if !canImport(FoundationNetworking)
        if let allowsConstrainedNetworkAccess = options.allowsConstrainedNetworkAccess {
            self.allowsConstrainedNetworkAccess = allowsConstrainedNetworkAccess
        }
        if let allowsExpensiveNetworkAccess = options.allowsExpensiveNetworkAccess {
            self.allowsExpensiveNetworkAccess = allowsExpensiveNetworkAccess
        }
        #endif
    }
}

extension Request {
    /// Defines configuration options for requests to use
    public struct Configuration: Hashable, Sendable {
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
        /// Whether to parse HTTP status codes as errors
        ///
        /// When true, the status code of a response will be parsed, and any code outside the `1XX-3XX` range will be returned as a ``RequestError/httpStatus(request:error:)``.
        public var parseHTTPStatusErrors: Bool
        /// Always append a trailing `/` to the end of the path components
        ///
        /// Some APIs require a trailing slash at the end of the URL path. This option will append a `/` character after the path, before the query items.
        public var appendTraillingSlashToPath: Bool
        
        /// A configuration structure with all default values
        ///
        /// Default property values are as follows:
        /// Property                                                                  | Default Value
        /// -------------------------------------------------------- | ---------------------------------------------------------------------------
        /// ``allowsCellularAccess``                          |  `true`
        /// ``cachePolicy``                                              | `URLRequest.CachePolicy.useProtocolCachePolicy`
        /// ``httpShouldUsePipelining``                   | `false`
        /// ``networkServiceType``                              | `URLRequest.NetworkServiceType.default`
        /// ``timeoutInterval``                                     | `60`
        /// ``httpShouldHandleCookies``                   | `true`
        /// ``allowsConstrainedNetworkAccess``* | `true`
        /// ``allowsExpensiveNetworkAccess``*                    | `true`
        /// ``parseHTTPStatusErrors``                       | `false`
        /// ``appendTraillingSlashToPath``            | `false`
        ///
        /// _*available on iOS, macOS, tvOS, and watchOS only._
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
        ///   - parseHTTPStatusErrors: Whether to parse HTTP status codes for errors
        ///   - appendTrailingSlashToPath: Whether to append a trailing '/' to the path components
        public init(
            allowsCellularAccess: Bool = true,
            cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy,
            httpShouldUsePipelining: Bool = false,
            networkServiceType: URLRequest.NetworkServiceType = .default,
            timeoutInterval: TimeInterval = 60,
            httpShouldHandleCookies: Bool = true,
            parseHTTPStatusErrors: Bool = false,
            appendTraillingSlashToPath: Bool = false
        ) {
            self.allowsCellularAccess = allowsCellularAccess
            self.cachePolicy = cachePolicy
            self.httpShouldUsePipelining = httpShouldUsePipelining
            self.networkServiceType = networkServiceType
            self.timeoutInterval = timeoutInterval
            self.httpShouldHandleCookies = httpShouldHandleCookies
            self.parseHTTPStatusErrors = parseHTTPStatusErrors
            self.appendTraillingSlashToPath = appendTraillingSlashToPath
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
        ///   - parseHTTPStatusErrors: Whether to parse HTTP status codes for errors
        ///   - appendTrailingSlashToPath: Whether to append a trailing '/' to the path components
        public init(
            allowsCellularAccess: Bool = true,
            cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy,
            httpShouldUsePipelining: Bool = false,
            networkServiceType: URLRequest.NetworkServiceType = .default,
            timeoutInterval: TimeInterval = 60,
            httpShouldHandleCookies: Bool = true,
            allowsConstrainedNetworkAccess: Bool = true,
            allowsExpensiveNetworkAccess: Bool = true,
            parseHTTPStatusErrors: Bool = false,
            appendTraillingSlashToPath: Bool = false
        ) {
            self.allowsCellularAccess = allowsCellularAccess
            self.cachePolicy = cachePolicy
            self.httpShouldUsePipelining = httpShouldUsePipelining
            self.networkServiceType = networkServiceType
            self.timeoutInterval = timeoutInterval
            self.httpShouldHandleCookies = httpShouldHandleCookies
            self.allowsConstrainedNetworkAccess = allowsConstrainedNetworkAccess
            self.allowsExpensiveNetworkAccess = allowsExpensiveNetworkAccess
            self.parseHTTPStatusErrors = parseHTTPStatusErrors
            self.appendTraillingSlashToPath = appendTraillingSlashToPath
        }
#endif
    }
}
