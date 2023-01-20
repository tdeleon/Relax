//
//  File.swift
//  
//
//  Created by Thomas De Leon on 1/11/23.
//

import Foundation

public struct Header {
    public var name: String
    public var value: String
        
    public init(_ name: String, _ value: String) {
        self.name = name
        self.value = value
    }
    
    internal init(_ name: Header.Name, _ value: String) {
        self.init(name.rawValue, value)
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
        
        public static let basic = AuthorizationType("basic")
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
    public let requestKeyPath = \Request.headers
    
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
    
    public func append(to property: inout [String : String]) {
        property = property.mergingCommaSeparatedValues(baseValue)
    }

    @resultBuilder
    public enum Builder {
        public static func buildBlock() -> [Header] {
            []
        }
        
        public static func buildBlock(_ components: [Header]...) -> [Header] {
            components.flatMap { $0 }
        }
        
        public static func buildOptional(_ component: [Header]?) -> [Header] {
            component ?? []
        }
        
        public static func buildEither(first component: [Header]) -> [Header] {
            component
        }
        
        public static func buildEither(second component: [Header]) -> [Header] {
            component
        }
        
        public static func buildArray(_ components: [[Header]]) -> [Header] {
            components.flatMap { $0 }
        }
        
        public static func buildExpression(_ expression: Header) -> [Header] {
            [expression]
        }
        
        public static func buildExpression(_ expression: [String: String]) -> [Header] {
            expression.map { Header($0.key, $0.value) }
        }
        
        public static func buildLimitedAvailability(_ component: [Header]) -> [Header] {
            component
        }
        
        public static func buildFinalResult(_ component: [Header]) -> Headers {
            Headers(headers: component)
        }
    }
}

extension Dictionary where Key == String, Value == String {
    internal func mergingCommaSeparatedValues(_ other: [String: String]) -> [String: String] {
        self.merging(other, uniquingKeysWith: {"\($0), \($1)"})
    }
}
