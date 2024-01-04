//
//  APIEndpoint.swift
//  
//
//  Created by Thomas De Leon on 1/3/24.
//

#if swift(>=5.9)
import Foundation

/// Defines and implements conformance of the Endpoint protocol.
///
/// This macro adds support to a custom type and conforms the type to the ``Endpoint`` protocol. You specify a parent ``APIComponent`` to link to, and a
/// path string which all requests will be made under.
///
/// ```swift
/// @APIService("https://example.com/api")
/// enum MyService {
///     // Defines a /users endpoint, as a child of MyService
///     @APIEndpoint<MyService>("users")
///     enum Users {
///           // define requests here
///     }
/// }
/// ```
///
/// - Note: The endpoint is not required to be nested under the service, but it can help to better organize your code. However, the endpoint **must** be linked
/// to a parent ``APIComponent`` by specifying it as a generic type.
///
/// - Parameter path: The path of the endpoint which all child ``Request``s or ``Endpoint``s will inherit.
@attached(extension, conformances: Endpoint, names: named(Parent), named(path))
public macro APIEndpoint<APIComponent>(_ path: String) = #externalMacro(module: "RelaxMacros", type: "APIEndpointMacro")
#endif
