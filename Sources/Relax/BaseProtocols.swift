//
//  BaseProtocols.swift
//
//
//  Created by Thomas De Leon on 5/12/20.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public protocol BaseURLProviding {
    /// The base URL to use for requests.
    ///
    /// This value is only a base and does not include any values provided by RequestProperties, such as `URLQueryItem`.
    static var baseURL: URL { get }
}

//MARK: - RequestProperty Providing
public protocol RequestPropertyProviding {
    /// Properties to be used by all child Requests.
    ///
    /// Any properties defined on an `APIComponentSubItem` or `Request` will override, or, if the property is an `AppendableRequestProperty`,
    /// append to those defined here.
    @RequestProperties.Builder static var sharedProperties: RequestProperties { get }
    static var allProperties: RequestProperties { get }
}

extension RequestPropertyProviding {
    @RequestProperties.Builder
    public static var sharedProperties: RequestProperties { RequestProperties.empty }
    
    public static var allProperties: RequestProperties {
        sharedProperties
    }
}

//MARK: - Request Configuration Providing
public protocol RequestConfigurationProviding {
    /// The configuration to use for any Requests provided by this component or its children
    static var configuration: Request.Configuration { get }
}

extension RequestConfigurationProviding {
    static var configuration: Request.Configuration { .default }
}

//MARK: - APIComponent & APIComponentSubItem

/// A component of an API
public typealias APIComponent = BaseURLProviding & RequestPropertyProviding & RequestConfigurationProviding



/// A nested component of an API, which inherits properties and a base URL from it's Parent.
public protocol APIComponentSubItem<Parent>: APIComponent {
    /// The parent component for this item
    associatedtype Parent: APIComponent
}

extension APIComponentSubItem {
    public static var allProperties: RequestProperties {
        Parent.allProperties + sharedProperties
    }
}

//MARK: - Service

/**
 A protocol to define a REST API service

 To define a service, implement the `Service` protocol. Each service has a distinct base URL, and all requests made
 to the service will use this base URL. Use services to logically group requests together for better organization and code
 reusability.

 - Note: For implementing dynamic base URLs (such as with different environments like Dev, Stage, Prod, etc), it is not necessary to define multiple services.

 #### About the protocol
 This protocol only has two properties- `Service.baseURL` and `Service.session`. The `baseURL` property is required to be implemented, and provides
 the base URL used for all requests (see [Making Requests](Making%20Requests.html) for more on requests). The `session` property is a
 `URLSession` instance that requests are made using. This property has a default implementation of `URLSession.shared`, but you can override this
 with your own. Additionally, when making requests,  a session may be passed in per request.
 
 - SeeAlso: `Endpoint`, `ServiceRequest`
 
*/
public protocol Service: APIComponent {
    /// The `URLSession` that requests to this service will use.
    ///
    /// The value of this property will be used for all requests made on this service, unless an override
    /// is provided to a given request.
    static var session: URLSession { get }
}

extension Service {
    ///  Returns `URLSession.shared`.
    public static var session: URLSession { .shared }
}

//MARK: - Endpoint

protocol Endpoint: APIComponentSubItem {
    /// The path provided by this endpoint
    static var path: String { get }
}

extension Endpoint {
    public static var baseURL: URL {
        Parent.baseURL.appendingPathComponent(path)
    }
}