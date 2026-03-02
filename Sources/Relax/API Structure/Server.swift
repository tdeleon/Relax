//
//  Server.swift
//  Relax
//
//  Created by Thomas De Leon on 2/19/26.
//

import Foundation

public protocol Server {
    var url: URL { get }
}

public struct ServerDefinition: Server {
    public let url: URL
}

public struct ServerDescription {
    let name: String?
    let url: String
    let description: String?
    let variables: [String: Variable]
    
    public struct Variable: Hashable {
        let name: String
        let type: Any.Type
        let defaultValue: Any?
        let description: String?
        
        public func hash(into hasher: inout Hasher) {
            hasher.combine(name)
            hasher.combine(description)
            hasher.combine(String(describing: type))
        }
        
        public static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.name == rhs.name
            && lhs.description == rhs.description
            && String(describing: lhs.type) == String(describing: rhs.type)
        }
    }
    
    internal init(_ name: String, url: String, description: String?, variables: [String: Variable]) {
        self.name = name
        self.url = url
        self.description = description
        self.variables = variables
    }
    
    /// <#Description#>
    /// - Parameters:
    ///   - name: Name for server
    ///   - url: Base URL for server
    ///   - description: Description of server
    ///   - variables: <#variables description#>
    public init(_ name: String, url: StaticString, description: String? = nil, @Builder variables: () -> [String: Variable]) {
        self.init(name, url: "\(url)", description: description, variables: variables())
    }
    
    public init(_ name: String, url: String, description: String? = nil) {
        self.init(name, url: url, description: description, variables: [:])
    }
    
    public init(_ name: String, url: URL, description: String? = nil) {
        self.init(name, url: url.absoluteString, description: description)
    }
}

extension ServerDescription {
    @resultBuilder
    public enum Builder {
        public static func buildBlock() -> [String: Variable] {
            [:]
        }
        
        public static func buildPartialBlock(
            first: [String : ServerDescription.Variable]
        ) -> [String : ServerDescription.Variable] {
            first
        }
        
        public static func buildPartialBlock(
            accumulated: [String : ServerDescription.Variable], next: [String : ServerDescription.Variable]
        ) -> [String : ServerDescription.Variable] {
            accumulated.merging(next) { _, new in new }
        }
        
        @available(*, unavailable, message: "Use explicit #Server() to define servers")
        public static func buildOptional(
            _ component: [String : ServerDescription.Variable]?
        ) -> [String : ServerDescription.Variable] {
            component ?? [:]
        }
        
        @available(*, unavailable, message: "Use explicit #Server() to define servers")
        public static func buildEither(
            first component: [String : ServerDescription.Variable]
        ) -> [String : ServerDescription.Variable] {
            component
        }
        
        @available(*, unavailable, message: "Use explicit #Server() to define servers")
        public static func buildEither(
            second component: [String : ServerDescription.Variable]
        ) -> [String : ServerDescription.Variable] {
            component
        }
        
        @available(*, unavailable, message: "Use explicit #Server() to define servers")
        public static func buildArray(
            _ components: [[String : ServerDescription.Variable]]
        ) -> [String : ServerDescription.Variable] {
            components.flatMap { $0 }.reduce(into: [:]) { $0[$1.key] = $1.value }
        }
        
        @available(*, unavailable, message: "Use explicit #Server() to define servers")
        public static func buildLimitedAvailability(
            _ component: [String : ServerDescription.Variable]
        ) -> [String : ServerDescription.Variable] {
            component
        }
        
        public static func buildExpression(_ expression: Variable) -> [String : ServerDescription.Variable] {
            [expression.name: expression]
        }
        
//        public static func buildExpression<T: CustomStringConvertible>(
//            _ expression: (String, T)
//        ) -> [String : ServerDescription.Variable] {
//            [expression.0: Variable(
//                name: expression.0,
//                type: type(of: expression.1),
//                defaultValue: expression.1,
//                description: nil
//            )]
//        }
//        
//        public static func buildExpression<T: CustomStringConvertible>(
//            _ expression: (String, T.Type)
//        ) -> [String : ServerDescription.Variable] {
//            [expression.0: Variable(name: expression.0, type: expression.1, defaultValue: nil, description: nil)]
//        }
    }
}

