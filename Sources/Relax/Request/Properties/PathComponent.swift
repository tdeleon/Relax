//
//  PathComponent.swift
//  
//
//  Created by Thomas De Leon on 7/17/22.
//

import Foundation

public struct PathComponents: RequestProperty {
    public var baseValue: [String]
    public let requestKeyPath = \Request.pathParameters
    
    public init(value: [String]) {
        self.baseValue = value
    }
    
    public init(@Builder _ components: () -> PathComponents) {
        self.init(value: components().baseValue)
    }
    
    public func append(to property: inout [String]) {
        property.append(contentsOf: baseValue)
    }
}

//MARK: Result Builder
extension PathComponents {
    @resultBuilder
    public enum Builder {
        public static func buildBlock() -> [String] {
            []
        }
        
        public static func buildBlock(_ components: [String]...) -> [String] {
            components.flatMap { $0 }
        }
        
        public static func buildOptional(_ component: [String]?) -> [String] {
            component ?? []
        }
        
        public static func buildEither(first component: [String]) -> [String] {
            component
        }
        
        public static func buildEither(second component: [String]) -> [String] {
            component
        }
        
        public static func buildExpression(_ expression: String) -> [String] {
            [expression]
        }
        
        public static func buildArray(_ components: [[String]]) -> [String] {
            components.flatMap { $0 }
        }
        
        public static func buildLimitedAvailability(_ component: [String]) -> [String] {
            component
        }
        
        public static func buildFinalResult(_ component: [String]) -> PathComponents {
            PathComponents(value: component.filter { !$0.isEmpty } )
        }
    }
}
