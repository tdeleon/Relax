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

/// A type that defines a component of a REST API
public protocol APIComponent {
    /// The base URL to use for requests.
    ///
    /// This value is only a base and does not include any values provided by Request.Properties, such as `URLQueryItem`.
    static var baseURL: URL { get }
    
    /// Properties to be used by all child Requests.
    ///
    /// Any properties defined on an `APIComponentSubItem` or `Request` will override, or, if the property is an `AppendableRequestProperty`,
    /// append to those defined here.
    @Request.Properties.Builder static var sharedProperties: Request.Properties { get }
    
    /// All properties provided by this component and it's ancestors
    ///
    /// - Important: You should not override this property, doing so will not allow properties to be properly inherited by child components.
    static var allProperties: Request.Properties { get }
    
    /// The configuration to use for any Requests provided by this component or its children
    static var configuration: Request.Configuration { get }
}

extension APIComponent {
    public static var configuration: Request.Configuration { .default }
    
    @Request.Properties.Builder
    public static var sharedProperties: Request.Properties { .empty }
    
    public static var allProperties: Request.Properties {
        sharedProperties
    }
}


/// A type that defines a nested component of a REST API
public protocol APISubComponent<Parent>: APIComponent {
    /// Connects the type to a parent ``APIComponent`` to allow for inheriting values.
    associatedtype Parent: APIComponent
}

extension APISubComponent {
    public static var allProperties: Request.Properties {
        Parent.allProperties + sharedProperties
    }
}


//MARK: - Endpoint

/// A type that defines a particular resource on a ``Service``, where requests can be made.
///
/// 
public protocol Endpoint: APISubComponent {
    /// The path provided by this endpoint
    static var path: String { get }
}

extension Endpoint {
    public static var baseURL: URL {
        Parent.baseURL.appendingPathComponent(path)
    }
}
