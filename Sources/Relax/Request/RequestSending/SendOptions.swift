//
//  SendOptions.swift
//  Relax
//
//  Created by Thomas De Leon on 10/22/22.
//

import Foundation
#if canImport(FoundationNetworking)
@preconcurrency import FoundationNetworking
#endif
import HTTPTypesFoundation

public struct SendOptions: Sendable, Hashable {
    /// The cache policy for this request
    /// - SeeAlso: https://developer.apple.com/documentation/foundation/urlsessionconfiguration/requestcachepolicy
    public var cachePolicy: URLRequest.CachePolicy?
    /// The timeout interval for this request
    public var timeoutInterval: TimeInterval?
    /// Whether cookies should be handled for this request
    public var httpShouldHandleCookies: Bool?
    /// Whether this request allows cellular access
    public var allowsCellularAccess: Bool?
    /// The network service type for this request
    public var networkServiceType: URLRequest.NetworkServiceType?
    
    #if !canImport(FoundationNetworking)
    /// Allow constrained network access on this request
    public var allowsConstrainedNetworkAccess: Bool?
    /// Allow expensinve network access on this request
    public var allowsExpensiveNetworkAccess: Bool?
    
    /// <#Description#>
    /// - Parameters:
    ///   - cachePolicy: <#cachePolicy description#>
    ///   - timeoutInterval: <#timeoutInterval description#>
    ///   - httpShouldHandleCookies: <#httpShouldHandleCookies description#>
    ///   - allowsCellularAccess: <#allowsCellularAccess description#>
    ///   - networkServiceType: <#networkServiceType description#>
    ///   - allowsConstrainedNetworkAccess: <#allowsConstrainedNetworkAccess description#>
    ///   - allowsExpensiveNetworkAccess: <#allowsExpensiveNetworkAccess description#>
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
    /// <#Description#>
    /// - Parameters:
    ///   - cachePolicy: <#cachePolicy description#>
    ///   - timeoutInterval: <#timeoutInterval description#>
    ///   - httpShouldHandleCookies: <#httpShouldHandleCookies description#>
    ///   - allowsCellularAccess: <#allowsCellularAccess description#>
    ///   - networkServiceType: <#networkServiceType description#>
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
    }
    #endif
}

extension URLRequest {
    internal mutating func apply(options: SendOptions?) {
        guard let options else { return }
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
    
    internal func applying(options: SendOptions?) -> URLRequest {
        var request = self
        request.apply(options: options)
        return request
    }
}

extension Request {
    internal func urlRequest(applying options: SendOptions?) throws -> URLRequest {
        guard let request = urlRequest?.applying(options: options) else { throw URLError(.badURL) }
        return request
    }
}
