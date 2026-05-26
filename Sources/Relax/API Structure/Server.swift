//
//  Server.swift
//  Relax
//
//  Created by Thomas De Leon on 2/19/26.
//

import Foundation

/// Defines a server for the API
///
/// The `Server` type is used to define a valid server for the API to use. You can define multiple servers to represent different environments, and/or define variables
/// within each server base URL path.
///
/// At least one server is required to be defined, and if multiple are defined, the ``API`` macro will generate an initializer with
/// an argument for the server to use. Each server you define will be mapped to a case in a generated enum.
///
/// You can define a server using a simple name and URL string:
/// ```
/// var servers: [Server] {
///     Server("Prod", url: "https://prod.example.com", description: "Prod server")
///     Server("Stage", url: "https://stage.example.com", description: "Staging server")
/// }
/// ```
/// Then, when using the API, you can select the server:
/// ```
/// let api = MyAPI(server: .prod)
/// ```
///
/// You can also define variables within the URL string within curly braces, with matching definitions with ``Server/Variable``. Variables can be any type with
/// string representation.
/// ```
///
/// @API
/// struct MyAPI {
///     enum Region: String {
///         case east
///         case west
///     }
///
///     var servers: [Server] {
///         Server("Prod", url: "https://prod-{region}.example.com", description: "Prod server") {
///             Server.Variable("region", type: Region.self, defaultValue: .east, description: "The region to use")
///         }
///         Server("Stage", url: "https://stage.example.com", description: "Staging server")
///     }
/// }
///
/// let api = MyAPI(server: .prod(.west))
/// ```
/// - Important: At least one ``Server`` is required to be defined for an API. If duplicate variables are defined, only the first one will be used.
///
/// - Note: If a placeholder is present without a corresponding ``Server/Variable`` definition, then it will be assumed to be of `String` type.
///
/// - SeeAlso: [Server Object](https://spec.openapis.org/oas/v3.2.0.html#server-object) and [Server Variable Object](https://spec.openapis.org/oas/v3.2.0.html#server-variable-object) in the OpenAPI specification.
public struct Server: Sendable {
    let name: String?
    let url: String
    let description: String?
    let variables: [String: Variable]
    
    /// Defines a variable for a server
    ///
    /// Use `Server.Variable` to specify variables in a ``Server`` base URL string. Server names should match the template placeholder names in curly
    /// braces.
    ///
    /// ```
    /// Server("Prod", url: "https://prod-{region}.example.com", description: "Prod server") {
    ///     Server.Variable("region", type: String.self, description: "The region to use")
    /// }
    /// ```
    public struct Variable: Hashable, @unchecked Sendable {
        let name: String
        let type: Any.Type
        let defaultValue: Any?
        let description: String?
        
        public func hash(into hasher: inout Hasher) {
            hasher.combine(name)
            hasher.combine(description)
            hasher.combine(String(describing: type))
        }
        
        public static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.name == rhs.name
            && lhs.description == rhs.description
            && String(describing: lhs.type) == String(describing: rhs.type)
        }
        
        /// Create a server variable
        /// - Parameters:
        ///   - name: The variable name. Must match the placeholder in braces in the `Server` url string, i.e. `{name}`.
        ///   - type: The variable type
        ///   - defaultValue: The default value for the variable
        ///   - description: A short description of the variable
        ///
        /// - Note: Variable names will be converted to camel case and sanitized (whitespace removed, etc) for use in generated code as an enum case.
        public init<T: CustomStringConvertible>(
            _ name: String,
            type: T.Type,
            defaultValue: T? = nil,
            description: StaticString? = nil
        ) {
            self.name = name
            self.type = type
            self.defaultValue = defaultValue
            self.description = description == nil ? nil : "\(description!)"
        }
        
        /// Create a server variable of an enum type with String values
        /// - Parameters:
        ///   - name: The variable name. Must match the placeholder in braces in the `Server` url string, i.e. `{name}`.
        ///   - type: The variable type
        ///   - defaultValue: The default value for the variable
        ///   - description: A short description of the variable
        ///
        /// - Note: Variable names will be converted to camel case and sanitized (whitespace removed, etc) for use in generated code as an enum case.
        public init<T: RawRepresentable>(
            _ name: String,
            type: T.Type,
            defaultValue: T? = nil,
            description: StaticString? = nil
        ) where T.RawValue: CustomStringConvertible {
            self.init(name: name, type: type, defaultValue: defaultValue, description: description)
        }
        
        internal init(name: String, type: Any.Type, defaultValue: Any? = nil, description: StaticString? = nil) {
            self.name = name
            self.type = type
            self.defaultValue = defaultValue
            self.description = description == nil ? nil : "\(description!)"
        }
    }
    
    internal init(_ name: String, url: String, description: String?, variables: [String: Variable]) {
        self.name = name
        self.url = url
        self.description = description
        self.variables = variables
    }
    
    /// Create a server with variables
    /// - Parameters:
    ///   - name: The name of the server
    ///   - url: The base URL string
    ///   - description: A short description of the server
    ///   - variables: A result builder defining variables to replace placeholders in braces (`{}`) in the URL string.
    ///
    /// Variable names should match placeholder names in the `url` string in braces. If a variable is defined in the `variables` builder without being used,
    /// it will be ignored. Variable types can be a simple string value, or any type which can be represented by a string.
    ///
    /// ```
    /// enum Region: String {
    ///     case east
    ///     case west
    /// }
    ///
    /// Server("Regional", url: "https://{region}.example.com", description: "Regional server") {
    ///     Server.Variable("region", type: Region.self, defaultValue: .east, description: "The region to use")
    /// }
    /// ```
    public init(_ name: String, url: StaticString, description: String? = nil, @Builder variables: () -> [String: Variable]) {
        self.init(name, url: "\(url)", description: description, variables: variables())
    }
    
    /// Create a server with a URL string
    /// - Parameters:
    ///   - name: The name of the server
    ///   - url: The base URL string
    ///   - description: A short description of the server
    ///
    /// Use this initializer to define a server with a URL string, without any variables:
    ///  ```
    ///  Server("Prod", url: "https://prod.example.com")
    ///  ```
    public init(_ name: String, url: String, description: String? = nil) {
        self.init(name, url: url, description: description, variables: [:])
    }
    
    /// Create a server with a URL
    /// - Parameters:
    ///   - name: The name of the server
    ///   - url: The base URL
    ///   - description: A short description of the server
    ///
    /// Use this initializer to define a server with a URL, without any variables
    ///  ```
    ///  let url = URL(string: "https://example.com")!
    ///  Server("Prod", url: url)
    ///  ```
    ///  - Important: If you pass in a variable for `url`, it must be available at the same scope as the type the @API macro is, in order to be available to the
    ///   macro at compile time.
    public init(_ name: String, url: URL, description: String? = nil) {
        self.init(name, url: url.absoluteString, description: description)
    }
}

extension Server {
    /// A result builder to define servers.
    ///
    /// Use this result builder to define one or more servers that the API can use.
    /// ```
    /// var servers: [Server] {
    ///     Server("Prod", url: "https://prod-{region}.example.com", description: "Prod server") {
    ///         Server.Variable("region", type: Region.self, defaultValue: .east, description: "The region to use")
    ///     }
    ///     Server("Stage", url: "https://stage.example.com", description: "Staging server")
    /// }
    ///  ```
    ///
    /// - Note:This builder is used by the macro at compile time. Optionals, conditionals, and arrays are not supported to ensure deterministic macro expansion.
    @resultBuilder
    public enum Builder {
        public static func buildBlock() -> [String: Variable] {
            [:]
        }
        
        public static func buildPartialBlock(
            first: [String : Server.Variable]
        ) -> [String : Server.Variable] {
            first
        }
        
        public static func buildPartialBlock(
            accumulated: [String : Server.Variable], next: [String : Server.Variable]
        ) -> [String : Server.Variable] {
            accumulated.merging(next) { _, new in new }
        }
        
        @available(*, unavailable, message: "Optionals are not supported in this builder.")
        public static func buildOptional(
            _ component: [String : Server.Variable]?
        ) -> [String : Server.Variable] {
            component ?? [:]
        }
        
        @available(*, unavailable, message: "Conditionals are not supported in this builder.")
        public static func buildEither(
            first component: [String : Server.Variable]
        ) -> [String : Server.Variable] {
            component
        }
        
        @available(*, unavailable, message: "Conditionals are not supported in this builder.")
        public static func buildEither(
            second component: [String : Server.Variable]
        ) -> [String : Server.Variable] {
            component
        }
        
        @available(*, unavailable, message: "Arrays are not supported in this builder.")
        public static func buildArray(
            _ components: [[String : Server.Variable]]
        ) -> [String : Server.Variable] {
            components.flatMap { $0 }.reduce(into: [:]) { $0[$1.key] = $1.value }
        }
        
        @available(*, unavailable, message: "Conditionals are not supported in this builder.")
        public static func buildLimitedAvailability(
            _ component: [String : Server.Variable]
        ) -> [String : Server.Variable] {
            component
        }
        
        public static func buildExpression(_ expression: Variable) -> [String : Server.Variable] {
            [expression.name: expression]
        }
    }
}

