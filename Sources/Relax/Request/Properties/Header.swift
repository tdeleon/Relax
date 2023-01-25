//
//  Headers.swift
//  
//
//  Created by Thomas De Leon on 1/11/23.
//

import Foundation

public struct Header: CustomStringConvertible {
    public var name: String
    public var value: String
        
    public init(_ name: String, _ value: String) {
        self.name = name
        self.value = value
    }
    
    internal init(_ name: Header.Name, _ value: String) {
        self.init(name.rawValue, value)
    }
    
    public var description: String {
        "\(name):\(value)"
    }
}

extension Header {
    public struct Name: RawRepresentable {
        public var rawValue: String
        
        public init(rawValue: String) {
            self.rawValue = rawValue
        }
        public init(_ rawValue: String) {
            self.init(rawValue: rawValue)
        }
        
        public static let accept = Name("Accept")
        public static let acceptLanguage = Name("Accept-Language")
        public static let authorization = Name("Authorization")
        public static let cacheControl = Name("Cache-Control")
        public static let contentType = Name("Content-Type")
    }
    
    public struct AuthorizationType: RawRepresentable, Hashable {
        public var rawValue: String
        
        public init(rawValue: String) {
            self.rawValue = rawValue
        }
        
        public init(_ rawValue: String) {
            self.init(rawValue: rawValue)
        }
        
        public static let basic = AuthorizationType("Basic")
        public static let bearer = AuthorizationType("Bearer")
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
    
    public static func accept(_ value: String) -> Header { Header(.accept, value) }
    public static func accept(_ contentType: ContentType) -> Header { Header(.accept, contentType.rawValue) }
    public static func acceptLanguage(_ value: String) -> Header { Header(.acceptLanguage, value) }
    public static func authorization(_ value: String) -> Header { Header(.authorization, value) }
    public static func authorization(_ type: AuthorizationType, value: String) -> Header {
        Header(.authorization, "\(type.rawValue) \(value)")
    }
    public static func cacheControl(_ value: String) -> Header { Header(.cacheControl, value) }
    public static func contentType(_ value: String) -> Header { Header(.contentType, value) }
    public static func contentType(_ type: ContentType) -> Header { Header(.contentType, type.rawValue) }

    internal var dictionary: [String: String] {
        [name: value]
    }
    
}

public struct Headers: RequestProperty {
    public var baseValue: [String: String]
    
    public init(value: [String: String]) {
        self.baseValue = value
    }

    public init(@Builder _ headers: () -> Headers) {
        self.init(value: headers().baseValue)
    }
    
    public init(headers: [Header]) {
        self.init(
            value:
                Headers(
                    value: headers.reduce([:], { $0.mergingCommaSeparatedValues($1.dictionary) })
                )
                .baseValue
        )
    }
    
    public func append(to property: Headers) -> Headers {
        Headers(value: baseValue.mergingCommaSeparatedValues(property.baseValue))
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
