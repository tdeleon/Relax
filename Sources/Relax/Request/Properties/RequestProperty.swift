//
//  RequestProperty.swift
//  
//
//  Created by Thomas De Leon on 1/11/23.
//

import Foundation

public protocol RequestProperty<PropertyType, SettableType>: Hashable {
    associatedtype PropertyType
    associatedtype SettableType

    var baseValue: PropertyType { get }
    init(value: SettableType)
    var requestKeyPath: WritableKeyPath<Request, PropertyType> { get }
    func append(to base: inout PropertyType)
}

extension RequestProperty {
    public func set(on base: inout PropertyType) {
        base = baseValue
    }
}

extension RequestProperty where PropertyType: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(baseValue)
    }
}

//MARK: Result Builder
@resultBuilder
public enum RequestPropertyBuilder {
    public static func buildBlock() -> [any RequestProperty] {
        []
    }
    
    public static func buildBlock(_ components: [any RequestProperty]...) -> [any RequestProperty] {
        components.flatMap { $0 }
    }
    
    public static func buildArray(_ components: [any RequestProperty]) -> [any RequestProperty] {
        components
    }
    
    public static func buildLimitedAvailability(_ component: [any RequestProperty]) -> [any RequestProperty] {
        component
    }
    
    public static func buildOptional(_ component: [any RequestProperty]?) -> [any RequestProperty] {
        component ?? []
    }
    
    public static func buildEither(first component: [any RequestProperty]) -> [any RequestProperty] {
        component
    }
    
    public static func buildEither(second component: [any RequestProperty]) -> [any RequestProperty] {
        component
    }
    
    public static func buildArray(_ components: [[any RequestProperty]]) -> [any RequestProperty] {
        components.flatMap { $0 }
    }
    
    public static func buildExpression(_ expression: any RequestProperty) -> [any RequestProperty] {
        [expression]
    }
}

//MARK: - Empty Request Property
public struct EmptyRequestProperty: RequestProperty {
    public let baseValue = [""]
    public init(value: [String] = []) {}
    public let requestKeyPath = \Request.pathParameters
    public func append(to base: inout [String]) {}
    public func set(on base: inout [String]) {}
}
