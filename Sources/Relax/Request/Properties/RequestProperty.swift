//
//  RequestProperty.swift
//  
//
//  Created by Thomas De Leon on 1/11/23.
//

import Foundation

public protocol RequestProperty<PropertyType>: Hashable {
    associatedtype PropertyType
    var baseValue: PropertyType { get }
    init(value: PropertyType)
    func append(to property: Self) -> Self
}

extension RequestProperty {
    public static func +(lhs: Self, rhs: Self) -> Self {
        lhs.append(to: rhs)
    }
    static public func +=( left: inout Self, right: Self) {
        left = left + right
    }
}

public struct RequestProperties: Hashable {
    var headers: Headers = Headers(value: [:])
    var queryItems: QueryItems = QueryItems(value: [])
    var pathComponents: PathComponents = PathComponents(value: [])
    var body: Body = Body(value: nil)
    
    public static func + (lhs: RequestProperties, rhs: RequestProperties) -> RequestProperties {
        var new = rhs
        new.headers = lhs.headers.append(to: new.headers)
        new.queryItems = lhs.queryItems.append(to: new.queryItems)
        new.pathComponents = lhs.pathComponents.append(to: new.pathComponents)
        new.body = lhs.body.append(to: new.body)
        return new
    }
    
    public static let empty: RequestProperties = .init()
    
    static func from(_ requestProperty: some RequestProperty) -> RequestProperties {
        switch requestProperty {
        case let headers as Headers:
            return .init(headers: headers)
        case let queryItems as QueryItems:
            return .init(queryItems: queryItems)
        case let pathComponents as PathComponents:
            return .init(pathComponents: pathComponents)
        case let body as Body:
            return .init(body: body)
        default:
            return .init()
        }
    }
    
}

//MARK: Result Builder
@resultBuilder
public enum RequestPropertiesBuilder {
    public static func buildBlock() -> RequestProperties {
        .empty
    }
    
    public static func buildPartialBlock(first: RequestProperties) -> RequestProperties {
        first
    }
    
    public static func buildPartialBlock(accumulated: RequestProperties, next: RequestProperties) -> RequestProperties {
        next + accumulated
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
    
    public static func buildExpression(_ expression: RequestProperties) -> RequestProperties {
        expression
    }
    
    public static func buildExpression(_ expression: Headers) -> RequestProperties {
        RequestProperties(headers: expression)
    }
    
    public static func buildExpression(_ expression: QueryItems) -> RequestProperties {
        RequestProperties(queryItems: expression)
    }
    
    public static func buildExpression(_ expression: PathComponents) -> RequestProperties {
        RequestProperties(pathComponents: expression)
    }
    
    public static func buildExpression(_ expression: Body) -> RequestProperties {
        RequestProperties(body: expression)
    }
}
