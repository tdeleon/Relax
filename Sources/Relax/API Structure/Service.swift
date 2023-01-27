//
//  Service.swift
//  
//
//  Created by Thomas De Leon on 1/26/23.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// A type that defines a REST API service
///
/// A ``Service`` defines a REST API at the root level, and all ``Request``s and ``Endpoint``s which share a common base URL belong to the service.
/// You define common properties here which will be used by all requests that belong to the service.
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
