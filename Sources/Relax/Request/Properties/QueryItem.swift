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
    
    public init(value: [URLQueryItem]) {
        self.baseValue = value
    }
    
    public init(@Builder _ items: () -> QueryItems) {
        self.init(value: items().baseValue)
    }
    
    public func append(to property: QueryItems) -> QueryItems {
        QueryItems(value: baseValue + property.baseValue)
    }
}

//MARK: Result Builder
extension QueryItems {
    @resultBuilder
    public enum Builder {
        public static func buildBlock() -> QueryItems {
            .init(value: [])
        }
        
        public static func buildPartialBlock(first: QueryItems) -> QueryItems {
            first
        }
        
        public static func buildPartialBlock(accumulated: QueryItems, next: QueryItems) -> QueryItems {
            accumulated + next
        }
        
        public static func buildOptional(_ component: QueryItems?) -> QueryItems {
            component ?? .init(value: [])
        }
        
        public static func buildEither(first component: QueryItems) -> QueryItems {
            component
        }
        
        public static func buildEither(second component: QueryItems) -> QueryItems {
            component
        }
        
        public static func buildArray(_ components: [QueryItems]) -> QueryItems {
            components.reduce(.init(value: []), +)
        }
        
        public static func buildExpression(_ expression: QueryItems) -> QueryItems {
            expression
        }
        
        public static func buildExpression(_ expression: URLQueryItem) -> QueryItems {
            .init(value: [expression])
        }
        
        public static func buildExpression(_ expression: QueryItem) -> QueryItems {
            .init(value: [expression.urlQueryItem])
        }
        
        public static func buildLimitedAvailability(_ component: [QueryItem]) -> [QueryItem] {
            component
        }
    }
}
