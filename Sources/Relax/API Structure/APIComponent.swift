//
//  APIComponent.swift
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
    
    /// The configuration to use for any Requests provided by this component or its children.
    ///
    /// The default value  is ``Request/Configuration-swift.struct/default``
    static var configuration: Request.Configuration { get }
    
    /// The URLSession to use for any Requests defined in this component or its children.
    ///
    /// The default value is `URLSession.shared`.
    static var session: URLSession { get }
    
    /// The decoder to use for any Requests provided by this component or its childern.
    ///
    /// The default value is `JSONDecoder()`.
    static var decoder: JSONDecoder { get }
}

//MARK: Default Implementation
extension APIComponent {
    public static var configuration: Request.Configuration { .default }
    
    @Request.Properties.Builder
    public static var sharedProperties: Request.Properties { .empty }
    
    public static var allProperties: Request.Properties { sharedProperties }
    
    public static var session: URLSession { .shared }
        
    public static var decoder: JSONDecoder { JSONDecoder() }
}

//MARK: - APISubComponent
/// A type that defines a nested component of a REST API
public protocol APISubComponent<Parent>: APIComponent {
    /// Connects the type to a parent ``APIComponent`` to allow for inheriting values.
    associatedtype Parent: APIComponent
}

extension APISubComponent {
    public static var allProperties: Request.Properties {
        Parent.allProperties + sharedProperties
    }
    
    public static var configuration: Request.Configuration {
        Parent.configuration
    }
    
    public static var session: URLSession {
        Parent.session
    }
    
    public static var decoder: JSONDecoder {
        Parent.decoder
    }
}

