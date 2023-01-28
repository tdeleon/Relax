//
//  Headers.swift
//  
//
//  Created by Thomas De Leon on 1/11/23.
//

import Foundation

/// A structure which represents a single request header
public struct Header: CustomStringConvertible {
    /// The header name
    public var name: String
    /// The header value
    public var value: String
    
    /// Creates a header with the specified name and value
    /// - Parameters:
    ///   - name: <#name description#>
    ///   - value: <#value description#>
    public init(_ name: String, _ value: String) {
        self.name = name
        self.value = value
    }
    
    /// <#Description#>
    /// - Parameters:
    ///   - name: <#name description#>
    ///   - value: <#value description#>
    internal init(_ name: Header.Name, _ value: String) {
        self.init(name.rawValue, value)
    }
    
    public var description: String {
        "\(name):\(value)"
    }
}

extension Header {
    /// Represents a request header name
    ///
    /// Common header names are provided, but additional can be added through an extension.
    public struct Name: RawRepresentable {
        public var rawValue: String
        
        public init(rawValue: String) {
            self.rawValue = rawValue
        }
        public init(_ rawValue: String) {
            self.init(rawValue: rawValue)
        }
        
        /// Header name `Accept`
        public static let accept = Name("Accept")
        /// Header name `Accept-Language`
        public static let acceptLanguage = Name("Accept-Language")
        /// Header name `Authorization`
        public static let authorization = Name("Authorization")
        /// Header name `Cache-Control`
        public static let cacheControl = Name("Cache-Control")
        /// Header name `Content-Type`
        public static let contentType = Name("Content-Type")
    }
    
    /// Header authorization types
    ///
    /// Common authorization types are provided, but additional can be added through an extension.
    public struct AuthorizationType: RawRepresentable, Hashable {
        public var rawValue: String
        
        public init(rawValue: String) {
            self.rawValue = rawValue
        }
        
        public init(_ rawValue: String) {
            self.init(rawValue: rawValue)
        }
        
        /// Authorization type `Basic`
        public static let basic = AuthorizationType("Basic")
        /// Authorization type `Bearer`
        public static let bearer = AuthorizationType("Bearer")
        /// Authorization type `Digest`
        public static let digest = AuthorizationType("Digest")
    }
    
    /// A struct representing request content types
    ///
    /// Additional content types may be added as needed.
    public struct ContentType: RawRepresentable, Hashable {
        public var rawValue: String

        ///
        public init(_ rawValue: String) {
            self.init(rawValue: rawValue)
        }
        public init(rawValue: String) {
            self.rawValue = rawValue
        }
        
        
        /// Content type of `application/json`
        public static let applicationJSON = ContentType("application/json")
        /// Content type of `text/plain`
        public static let textPlain = ContentType("text/plain")
        
    }
    
    /// Creates an Accept header with the given value
    /// - Parameter value: A string with the accept value
    /// - Returns: A header with the format `Accept: {value}`
    public static func accept(_ value: String) -> Header { Header(.accept, value) }
    /// Creates an Accept header with a ``ContentType``
    /// - Parameter contentType: The content type value
    /// - Returns: A header with the format `Accept: {contentType}`
    public static func accept(_ contentType: ContentType) -> Header { Header(.accept, contentType.rawValue) }
    
    /// Creates an Accept-Language header with the given value
    /// - Parameter value: The accept language value
    /// - Returns: A header with the format `Accept-Language: {value}`
    public static func acceptLanguage(_ value: String) -> Header { Header(.acceptLanguage, value) }
    
    /// Creates an Authorization header with the given value
    ///
    /// The `value` you provide should already be properly encoded; this method does not apply any encoding. You should also provide the
    /// authorization type (i.e. `Bearer`, `Basic`, etc).
    ///
    /// - Parameter value: The authorization value
    /// - Returns: A header with the format `Authorization: {value}`
    public static func authorization(_ value: String) -> Header { Header(.authorization, value) }
    /// Creates an Authorization header with the given type
    ///
    /// The `value` you provide should already be properly encoded; this method does not apply any encoding.  ``AuthorizationType`` provides
    /// common authorization type names as a convenience- you can add additional through an extension.
    ///
    /// - Parameters:
    ///   - type: The authorization type
    ///   - value: The authorization value
    /// - Returns: A header with the format `Authorization: {type} {value}`
    public static func authorization(_ type: AuthorizationType, value: String) -> Header {
        Header(.authorization, "\(type.rawValue) \(value)")
    }
    
    /// Creates a Cache-Control header with the given value
    /// - Parameter value: The cache control value
    /// - Returns: A header with the format `Cache-Control: {value}`
    public static func cacheControl(_ value: String) -> Header { Header(.cacheControl, value) }
    
    /// Creates a Content-Type header with the given value
    /// - Parameter value: The content type value
    /// - Returns: A header with the format `Content-Type: {value}`
    public static func contentType(_ value: String) -> Header { Header(.contentType, value) }
    /// Creates a Content-Type header with the given type
    ///
    /// ``ContentType`` provides common content type names as a convenience- you can add additional through an extension.
    /// - Parameter type: The Content-Type
    /// - Returns: A header with the format `Content-Type: {type}`
    public static func contentType(_ type: ContentType) -> Header { Header(.contentType, type.rawValue) }

    internal var dictionary: [String: String] {
        [name: value]
    }
    
}

/// A structure which describes the headers in a request.
public struct Headers: RequestProperty {
    public var value: [String: String]
    
    public init(value: [String: String]) {
        self.value = value
    }
    
    /// Creates headers from any number of ``Header``, `[String: String]`, or `(String, String)` instances using a ``Builder``.
    ///
    /// All items provided in `headers` will be combined to a single dictionary as the value for the ``Headers`` instance.
    ///
    /// - Parameter headers: A ``Builder`` that returns the headers to be used.
    public init(@Builder _ headers: () -> Headers) {
        self.init(value: headers().value)
    }
    
    /// Creates headers from an array of `Header` instances.
    /// - Parameter headers: An array of headers
    public init(headers: [Header]) {
        self.init(
            value:
                Headers(
                    value: headers.reduce([:], { $0.mergingCommaSeparatedValues($1.dictionary) })
                )
                .value
        )
    }
    
    public func append(to property: Headers) -> Headers {
        Headers(value: value.mergingCommaSeparatedValues(property.value))
    }

    @resultBuilder
    public enum Builder {
        public static func buildBlock() -> Headers {
            .init(value: [:])
        }
        
        public static func buildPartialBlock(first: Headers) -> Headers {
            first
        }
        
        public static func buildPartialBlock(accumulated: Headers, next: Headers) -> Headers {
            accumulated + next
        }
        
        public static func buildOptional(_ component: Headers?) -> Headers {
            component ?? .init(value: [:])
        }
        
        public static func buildEither(first component: Headers) -> Headers {
            component
        }
        
        public static func buildEither(second component: Headers) -> Headers {
            component
        }
        
        public static func buildArray(_ components: [Headers]) -> Headers {
            components.reduce(.init(value: [:]), +)
        }
        
        public static func buildExpression(_ expression: Headers) -> Headers {
            expression
        }
        
        public static func buildExpression(_ expression: Header) -> Headers {
            .init(headers: [expression])
        }
        
        public static func buildExpression(_ expression: [String: String]) -> Headers {
            .init(value: expression)
        }
        
        public static func buildExpression(_ expression: (String, String)) -> Headers {
            .init(value: [expression.0: expression.1])
        }
        
        public static func buildLimitedAvailability(_ component: Headers) -> Headers {
            component
        }
    }
}

extension Dictionary where Key == String, Value == String {
    internal func mergingCommaSeparatedValues(_ other: [String: String]) -> [String: String] {
        self.merging(other, uniquingKeysWith: {"\($0),\($1)"})
    }
}
