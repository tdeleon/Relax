//
//  Endpoint.swift
//  Relax
//
//  Created by Thomas De Leon on 3/3/26.
//

import Foundation
import HTTPTypes

/// Defines individual endpoints of an API
///
/// The path value of the endpoint is appended to the base URL of the ``Server`` currently being used. You define ``Operation``s on an endpoint, which are
///  then used by the macro to generate ``Request``s and convenience functions to send the requests and parse responses.
///
/// A path can optionally have ``Parameter``s marked in curly braces (`{}`), which are then used by operations when sending requests.
///
/// ```swift
/// Endpoint("/users/{id}", summary: "User ID path", group: "users") {
///     Endpoint.Operation(.get, summary: "Get user by ID") {
///         Response.json(.ok, returning: User.self)
///     } parameters: {
///         Parameter.path("id", ofType: Int.self)
///     }
///
///     Endpoint.Operation(.post, bodyParameter: .json(User.self, name: "user"), summary: "Create a new user") {
///         Response(.created)
///     }
/// }
/// ```
///
/// Parameters may also be defined at the endpoint level, and are then inherited by all operations defined on that endpoint.
/// ```swift
/// Endpoint("/users/") {
///     Endpoint.Operation(.get) {
///         Response.json(.ok, returning: User.self)
///     }
/// } parameters: {
///     Parameter.query("id", ofType: Int.self)
/// }
/// ```
///
/// - SeeAlso: [Paths Object](https://spec.openapis.org/oas/v3.2.0.html#paths-object) in the OpenAPI specification.
public struct Endpoint: Sendable {
    public let path: String
    public let summary: String?
    public let group: String?
    public let description: String?
    public let operations: [HTTPRequest.Method: Operation]
    public let servers: [Server]
    public let parameters: [Parameter]
    
    /// Create a path
    /// - Parameters:
    ///   - path: The path string
    ///   - operations: Operations that exist at this path
    ///   - parameters: Parameters that apply to all operations on this path
    ///   - servers: Specific servers to use for operations on this path. Overrides servers defined at the root of the API
    public init(
        _ path: String,
        @OperationsBuilder operations: () -> [HTTPRequest.Method: Operation],
        @Parameter.Builder parameters: () -> [Parameter] = { [] },
        @ServersBuilder servers: () -> [Server] = { [] }
    ) {
        self.path = path
        self.summary = nil
        self.group = nil
        self.servers = servers()
        self.operations = operations()
        self.parameters = parameters()
        self.description = nil
    }
    
    /// Create a path, grouping operations under a specified name
    /// - Parameters:
    ///   - path: The path string
    ///   - summary: A short summary of the path
    ///   - group: A name to group operations in this path by
    ///   - operations: Operations that apply to this path
    ///   - parameters: Parameters that apply to all operations on this path
    ///   - servers: Specific servers to use for operations on this path. Overrides servers defined at the root of the API
    ///   - description: A longer description of the path
    public init(
        _ path: String,
        summary: String? = nil,
        group: String,
        @OperationsBuilder operations: () -> [HTTPRequest.Method: Operation],
        @Parameter.Builder parameters: () -> [Parameter] = { [] },
        @ServersBuilder servers: () -> [Server] = { [] },
        @DescriptionBuilder description: () -> String? = { nil }
    ) {
        self.path = path
        self.summary = summary
        self.group = group
        self.servers = servers()
        self.operations = operations()
        self.parameters = parameters()
        self.description = description()
    }
    
    /// Create a path, grouping operations under a specified tag
    /// - Parameters:
    ///   - path: The path string
    ///   - summary: A short summary of the path
    ///   - tag: A tag to group operations in this path by
    ///   - operations: Operations that apply to this path
    ///   - parameters: Parameters that apply to all operations on this path
    ///   - servers: Specific servers to use for operations on this path. Overrides servers defined at the root of the API
    ///   - description: A longer description of the path
    public init(
        _ path: String,
        summary: String? = nil,
        tag: Tag,
        @OperationsBuilder operations: () -> [HTTPRequest.Method: Operation],
        @Parameter.Builder parameters: () -> [Parameter] = { [] },
        @ServersBuilder servers: () -> [Server] = { [] },
        @DescriptionBuilder description: () -> String? = { nil }
    ) {
        self.path = path
        self.summary = summary
        self.group = tag.name
        self.servers = servers()
        self.operations = operations()
        self.parameters = parameters()
        self.description = description()
    }
    
    /// A result builder to define path operations.
    ///
    /// Use this result builder to define operations (requests) that can be used at the given path. If multiple operations with the same
    /// [`HTTPRequest.Method`](https://swiftpackageindex.com/apple/swift-http-types/documentation/httptypes), then the last one
    /// defined is used.
    ///
    /// ```swift
    /// Endpoint("/users/{id}", summary: "User ID path", group: "users") {
    ///     Endpoint.Operation(.get, summary: "Get user by ID") {
    ///         Response.json(.ok, returning: User.self)
    ///     } parameters: {
    ///         Parameter.path("id", ofType: Int.self)
    ///     }
    ///
    ///     Endpoint.Operation(.post, bodyParameter: .json(User.self, name: "user"), summary: "Create a new user") {
    ///         Response(.created)
    ///     }
    /// ```
    ///
    /// - Note: This builder is used by the macro at compile time. Optionals, conditionals, and arrays are not supported to ensure deterministic macro expansion.
    @resultBuilder
    public enum OperationsBuilder {
        public static func buildBlock() -> [HTTPRequest.Method: Endpoint.Operation] {
            [:]
        }
        
        public static func buildPartialBlock(
            first: [HTTPRequest.Method: Endpoint.Operation]
        ) -> [HTTPRequest.Method: Endpoint.Operation] {
            first
        }
        
        public static func buildPartialBlock(
            accumulated: [HTTPRequest.Method: Endpoint.Operation],
            next: [HTTPRequest.Method: Endpoint.Operation]
        ) -> [HTTPRequest.Method: Endpoint.Operation] {
            accumulated.merging(next) { _, new in new }
        }
        
        public static func buildExpression(_ expression: Endpoint.Operation) -> [HTTPRequest.Method: Endpoint.Operation] {
            [expression.method: expression]
        }
        
        @available(*, unavailable, message: "Optionals are not supported in this builder.")
        public static func buildOptional(_ component: [HTTPRequest.Method : Endpoint.Operation]?) -> [HTTPRequest.Method : Endpoint.Operation] {
            component ?? [:]
        }
        
        @available(*, unavailable, message: "Conditionals are not supported in this builder.")
        public static func buildEither(first component: [HTTPRequest.Method : Endpoint.Operation]) -> [HTTPRequest.Method : Endpoint.Operation] {
            component
        }
        
        @available(*, unavailable, message: "Conditionals are not supported in this builder.")
        public static func buildEither(second component: [HTTPRequest.Method : Endpoint.Operation]) -> [HTTPRequest.Method : Endpoint.Operation] {
            component
        }
        
        @available(*, unavailable, message: "Conditionals are not supported in this builder.")
        public static func buildLimitedAvailability(_ component: [HTTPRequest.Method : Endpoint.Operation]) -> [HTTPRequest.Method : Endpoint.Operation] {
            component
        }
        
        @available(*, unavailable, message: "Arrays are not supported in this builder.")
        public static func buildArray(_ components: [[HTTPRequest.Method : Endpoint.Operation]]) -> [HTTPRequest.Method : Endpoint.Operation] {
            components.flatMap { $0 }.reduce(into: [:]) { $0[$1.key] = $1.value }
        }
    }
}
