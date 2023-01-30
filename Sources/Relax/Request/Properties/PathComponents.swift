//
//  PathComponents.swift
//  
//
//  Created by Thomas De Leon on 7/17/22.
//

import Foundation

/// A structure which describes path components to be appended to the base URL of a request.
///
/// You should not escape the values entered here as they will be escaped when they are appended to the URL of the request.
public struct PathComponents: RequestProperty {
    public var value: [String]
    
    public init(value: [String]) {
        self.value = value.filter { !$0.isEmpty }
    }
    
    /// Creates path components from any number of strings or string arrays using a ``Builder``.
    /// - Parameter components: A ``Builder`` that returns the path components to be used.
    public init(@Builder _ components: () -> PathComponents) {
        self.init(value: components().value)
    }
    
    public func append(to property: PathComponents) -> PathComponents {
        .init(value: value + property.value)
    }
}

//MARK: Result Builder
extension PathComponents {
    @resultBuilder
    public enum Builder {
        public static func buildBlock() -> PathComponents {
            .init(value: [])
        }
        
        public static func buildPartialBlock(first: PathComponents) -> PathComponents {
            first
        }
        
        public static func buildPartialBlock(accumulated: PathComponents, next: PathComponents) -> PathComponents {
            accumulated + next
        }
        
        public static func buildOptional(_ component: PathComponents?) -> PathComponents {
            component ?? .init(value: [])
        }
        
        public static func buildEither(first component: PathComponents) -> PathComponents {
            component
        }
        
        public static func buildEither(second component: PathComponents) -> PathComponents {
            component
        }
        
        public static func buildArray(_ components: [PathComponents]) -> PathComponents {
            components.reduce(.init(value: []), +)
        }
        
        public static func buildExpression(_ expression: PathComponents) -> PathComponents {
            expression
        }
        
        public static func buildExpression(_ expression: String) -> PathComponents {
            PathComponents(value: [expression])
        }
        
        public static func buildExpression(_ expression: [String]) -> PathComponents {
            PathComponents(value: expression)
        }
        
        public static func buildLimitedAvailability(_ component: PathComponents) -> PathComponents {
            component
        }
    }
}
