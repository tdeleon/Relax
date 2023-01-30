//
//  RequestProperty.swift
//  
//
//  Created by Thomas De Leon on 1/11/23.
//

import Foundation

/// A type describing a property of a request
public protocol RequestProperty<PropertyType>: Hashable {
    associatedtype PropertyType
    /// The base value type of the property
    var value: PropertyType { get }
    /// Create a new instance of the property
    init(value: PropertyType)
    /// Append this property to another property of the same type
    func append(to property: Self) -> Self
}

extension RequestProperty {
    public static func +(lhs: Self, rhs: Self) -> Self {
        lhs.append(to: rhs)
    }
    
    public static func +=(left: inout Self, right: Self) {
        left = left + right
    }
}

extension Request {
    /// A structure that groups properties of a request
    public struct Properties: Hashable {
        var headers: Headers = Headers(value: [:])
        var queryItems: QueryItems = QueryItems(value: [])
        var pathComponents: PathComponents = PathComponents(value: [])
        var body: Body = Body(value: nil)
        
        public static func +(lhs: Properties, rhs: Properties) -> Request.Properties {
            var new = rhs
            new.headers = lhs.headers.append(to: new.headers)
            new.queryItems = lhs.queryItems.append(to: new.queryItems)
            new.pathComponents = lhs.pathComponents.append(to: new.pathComponents)
            new.body = lhs.body.append(to: new.body)
            return new
        }
        
        public static func +=(left: inout Self, right: Self) {
            left = left + right
        }
        
        /// Provides an instance with no property values set
        public static let empty: Properties = .init()
        
        internal static func from(_ requestProperty: some RequestProperty) -> Request.Properties {
            .empty
            .updating(requestProperty, replace: true)
        }
        
        internal func adding(_ requestProperty: some RequestProperty) -> Request.Properties {
            updating(requestProperty, replace: false)
        }
        
        internal func setting(_ requestProperty: some RequestProperty) -> Request.Properties {
            updating(requestProperty, replace: true)
        }
        
        private func updating(_ requestProperty: some RequestProperty, replace: Bool) -> Request.Properties {
            var newProperties = self
            switch requestProperty {
            case let headers as Headers:
                newProperties.headers = replace ? headers : newProperties.headers + headers
            case let queryItems as QueryItems:
                newProperties.queryItems = replace ? queryItems : newProperties.queryItems + queryItems
            case let pathComponents as PathComponents:
                newProperties.pathComponents = replace ? pathComponents : newProperties.pathComponents + pathComponents
            case let body as Body:
                newProperties.body = replace ? body : newProperties.body + body
            default:
                break
            }
            return newProperties
        }
    }
}

//MARK: Result Builder
extension Request.Properties {
    /// A result builder to combine one or more ``RequestProperty`` into a single instance
    @resultBuilder
    public enum Builder {
        public static func buildBlock() -> Request.Properties {
            .empty
        }
        
        public static func buildPartialBlock(first: Request.Properties) -> Request.Properties {
            first
        }
        
        public static func buildPartialBlock(accumulated: Request.Properties, next: Request.Properties) -> Request.Properties {
            accumulated + next
        }
        
        public static func buildOptional(_ component: Request.Properties?) -> Request.Properties {
            component ?? .empty
        }
        
        public static func buildEither(first component: Request.Properties) -> Request.Properties {
            component
        }
        
        public static func buildEither(second component: Request.Properties) -> Request.Properties {
            component
        }
        
        public static func buildArray(_ components: [Request.Properties]) -> Request.Properties {
            components.reduce(.empty, +)
        }
        
        public static func buildLimitedAvailability(_ component: Request.Properties) -> Request.Properties {
            component
        }
        
        public static func buildExpression(_ expression: some RequestProperty) -> Request.Properties {
            .from(expression)
        }
        
        public static func buildExpression(_ expression: Request.Properties) -> Request.Properties {
            expression
        }
    }
}
