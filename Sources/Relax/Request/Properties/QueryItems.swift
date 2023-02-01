//
//  QueryItems.swift
//  
//
//  Created by Thomas De Leon on 7/17/22.
//

import Foundation

/// A structure which represents a single query item
public struct QueryItem {
    /// The query item name
    public var name: String
    /// The query item value
    public var value: String?
    /// The `URLQueryItem` representation
    public var urlQueryItem: URLQueryItem {
        .init(name: name, value: value)
    }
    
    /// Creates a query item from a `URLQueryItem`
    /// - Parameter item: A `URLQueryItem` to create the query item from
    public init(_ item: URLQueryItem) {
        self.name = item.name
        self.value = item.value
    }
    
    /// Creates a query item from a tuple
    /// - Parameters:
    ///   - name: The query item name
    ///   - value: The query item value, from any string representable value
    public init(_ name: String, _ value: CustomStringConvertible?) {
        self.name = name
        self.value = value?.description
    }
    
    /// Creates a query item from a tuple with a `QueryItem.Name`
    /// - Parameters:
    ///   - name: The `QueryItem.Name`
    ///   - value: The item value, from any string representable value
    public init(_ name: QueryItem.Name, _ value: CustomStringConvertible?) {
        self.init(name.rawValue, value)
    }
}

extension QueryItem {
    /// A structure representing a query item name.
    ///
    /// You can use this to define commonly used query item names in your requests by adding static constant properties in an extension.
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

/// A structure which describes the query items in a request.
public struct QueryItems: RequestProperty {
    public var value: [URLQueryItem]
    
    public init(value: [URLQueryItem]) {
        self.value = value
    }
    
    /// Creates query items from any number of ``QueryItem``, `URLQueryItem`, or `(String, CustomStringConvertible?)` instances using a
    /// ``Builder``.
    ///
    /// All items provided in `items` will be combined into an array of `URLQueryItem`s as the value for ``QueryItems``.
    ///
    /// - Parameter items: A ``Builder`` that returns the query items to be used.
    public init(@Builder _ items: () -> QueryItems) {
        self.init(value: items().value)
    }
    
    public func append(to property: QueryItems) -> QueryItems {
        QueryItems(value: value + property.value)
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
        
        public static func buildExpression(_ expression: (String, CustomStringConvertible?)) -> QueryItems {
            .init(value: [.init(name: expression.0, value: expression.1?.description)])
        }
        
        public static func buildExpression(_ expression: QueryItem?) -> QueryItems {
            guard let expression else { return .init(value: [])}
            return .init(value: [expression.urlQueryItem])
        }
        
        public static func buildLimitedAvailability(_ component: QueryItems) -> QueryItems {
            component
        }
    }
}
