//
//  Endpoint.swift
//  
//
//  Created by Thomas De Leon on 1/26/23.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// A type that defines a particular resource on a ``Service``, where requests can be made.
///
/// An `APISubComponent` is an ``APIComponent`` which is nested in another ``APIComponent``.
public protocol Endpoint: APISubComponent {
    /// The path provided by this endpoint
    static var path: String { get }
}

extension Endpoint {
    public static var baseURL: URL {
        Parent.baseURL.appendingPathComponent(path)
    }
}
