//
//  QueryItem.swift
//  
//
//  Created by Thomas De Leon on 7/17/22.
//

import Foundation

public struct QueryItem {
    public var name: String
    public var value: String?
    
    public var urlQueryItem: URLQueryItem {
        .init(name: name, value: value)
    }
        
    public init(_ item: URLQueryItem) {
        self.name = item.name
        self.value = item.value
    }
    
    public init(_ name: String, _ value: String?) {
        self.name = name
        self.value = value
    }
    
    public init(_ name: QueryItem.Name, _ value: String?) {
        self.init(name.rawValue, value)
    }
}

extension QueryItem {
    public struct Name: RawRepresentable {
        public var rawValue: String
        
        public init(rawValue: String) {
            self.rawValue = rawValue
        }
        
        public init(_ rawValue: String) {
            self.init(rawValue: rawValue)
        }
    }
}

//MARK: - QueryItems

public struct QueryItems: RequestProperty {
    public var baseValue: [URLQueryItem]
    public let requestKeyPath = \Request.queryItems
    
    public init(value: [URLQueryItem]) {
        self.baseValue = value
    }
    
    public init(items: [QueryItem]) {
        self.init(value: items.map(\.urlQueryItem))
    }
    
    public init(@Builder _ items: () -> QueryItems) {
        self.init(value: items().baseValue)
    }
    
    public func append(to property: inout [URLQueryItem]) {
        property.append(contentsOf: baseValue)
    }
}

//MARK: Result Builder
extension QueryItems {
    @resultBuilder
    public enum Builder {
        public static func buildBlock() -> [QueryItem] {
            []
        }
        
        public static func buildBlock(_ components: [QueryItem]...) -> [QueryItem] {
            components.flatMap { $0 }
        }
        
        public static func buildOptional(_ component: [QueryItem]?) -> [QueryItem] {
            component ?? []
        }
        
        public static func buildEither(first component: [QueryItem]) -> [QueryItem] {
            component
        }
        
        public static func buildEither(second component: [QueryItem]) -> [QueryItem] {
            component
        }
        
        public static func buildArray(_ components: [[QueryItem]]) -> [QueryItem] {
            components.flatMap { $0 }
        }
        
        public static func buildExpression(_ expression: URLQueryItem) -> [QueryItem] {
            [QueryItem(expression.name, expression.value)]
        }
        
        public static func buildExpression(_ expression: QueryItem) -> [QueryItem] {
            [expression]
        }
        
        public static func buildLimitedAvailability(_ component: [QueryItem]) -> [QueryItem] {
            component
        }
        
        public static func buildFinalResult(_ component: [QueryItem]) -> QueryItems {
            QueryItems(items: component)
        }
    }
}
