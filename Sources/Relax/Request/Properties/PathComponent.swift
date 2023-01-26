//
//  PathComponents.swift
//  
//
//  Created by Thomas De Leon on 7/17/22.
//

import Foundation

public struct PathComponents: RequestProperty {
    public var baseValue: [String]
    
    public init(value: [String]) {
        self.baseValue = value.filter { !$0.isEmpty }
    }
    
    public init(@Builder _ components: () -> PathComponents) {
        self.init(value: components().baseValue)
    }
    
    public func append(to property: PathComponents) -> PathComponents {
        .init(value: baseValue + property.baseValue)
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
