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

/// A structure that groups properties of a request
public struct RequestProperties: Hashable {
    var headers: Headers = Headers(value: [:])
    var queryItems: QueryItems = QueryItems(value: [])
    var pathComponents: PathComponents = PathComponents(value: [])
    var body: Body = Body(value: nil)
    
    public static func +(lhs: RequestProperties, rhs: RequestProperties) -> RequestProperties {
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
    public static let empty: RequestProperties = .init()
    
    internal static func from(_ requestProperty: some RequestProperty) -> RequestProperties {
        .empty
        .updating(requestProperty, replace: true)
    }
    
    internal func adding(_ requestProperty: some RequestProperty) -> RequestProperties {
        updating(requestProperty, replace: false)
    }
    
    internal func setting(_ requestProperty: some RequestProperty) -> RequestProperties {
        updating(requestProperty, replace: true)
    }
    
    private func updating(_ requestProperty: some RequestProperty, replace: Bool) -> RequestProperties {
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

//MARK: Result Builder
extension RequestProperties {
    /// A result builder to combine one or more ``RequestProperty`` into a single instance
    @resultBuilder
    public enum Builder {
        public static func buildBlock() -> RequestProperties {
            .empty
        }
        
        public static func buildPartialBlock(first: RequestProperties) -> RequestProperties {
            first
        }
        
        public static func buildPartialBlock(accumulated: RequestProperties, next: RequestProperties) -> RequestProperties {
            accumulated + next
        }
        
        public static func buildOptional(_ component: RequestProperties?) -> RequestProperties {
            component ?? .empty
        }
        
        public static func buildEither(first component: RequestProperties) -> RequestProperties {
            component
        }
        
        public static func buildEither(second component: RequestProperties) -> RequestProperties {
            component
        }
        
        public static func buildArray(_ components: [RequestProperties]) -> RequestProperties {
            components.reduce(.empty, +)
        }
        
        public static func buildLimitedAvailability(_ component: RequestProperties) -> RequestProperties {
            component
        }
        
        public static func buildExpression(_ expression: some RequestProperty) -> RequestProperties {
            .from(expression)
        }
        
        public static func buildExpression(_ expression: RequestProperties) -> RequestProperties {
            expression
        }
    }
}
