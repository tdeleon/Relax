//
//  APIService.swift
//
//
//  Created by Thomas De Leon on 12/27/23.
//

#if swift(>=5.9)
import Foundation

/// Defines and implements conformance of the Service protocol.
///
/// This macro adds support to a custom type and conforms it to the ``Service`` protocol. You specify a base URL which all child ``Request``s  and
/// ``Endpoint``s will use.
///
/// ```swift
/// // Defines MyService with a 
/// // base URL of https://example.com/api
/// @APIService("https://example.com/api")
/// enum MyService {
///     // Define child requests and endpoints
/// }
/// ```
///
/// - Note: The string supplied for the base URL will be checked that it is a valid URL.
///
/// - Parameter baseURL: The base URL for the service which all child ``Request``s and ``Endpoint``s will inherit.
@attached(extension, conformances: APIComponent, names: named(baseURL))
public macro APIService(_ baseURL: String) = #externalMacro(module: "RelaxMacros", type: "APIServiceMacro")
#endif
