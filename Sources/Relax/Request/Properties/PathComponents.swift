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
public struct PathComponents: Hashable, Sendable {
    internal var _value: [String]
    
    public init(_ components: [String]) {
        self._value = components
    }
    
    public init(_ string: String) {
        _value = string.split(separator: "/").map { String($0) }.filter { !$0.isEmpty }
    }
    
    /// Creates path components from any number of strings or string arrays using a ``Builder``.
    /// - Parameter components: A ``Builder`` that returns the path components to be used.
    public init(@Builder _ components: () -> PathComponents) {
        self.init(components()._value)
    }
    
    public static func +(lhs: Self, rhs: Self) -> Self {
        self.init(lhs._value + rhs._value)
    }
}

extension PathComponents: RangeReplaceableCollection, RandomAccessCollection {
    public init() {
        _value = []
    }
    
    public var startIndex: Int {
        _value.startIndex
    }
    
    public var endIndex: Int {
        _value.endIndex
    }
    
    public func index(after i: Int) -> Int {
        _value.index(after: i)
    }
    
    public func index(before i: Int) -> Int {
        _value.index(before: i)
    }
    
    public subscript(position: Int) -> String {
        _value[position]
    }
    
    public mutating func replaceSubrange<C>(_ subrange: Range<Int>, with newElements: C) where C : Collection, String == C.Element {
        _value.replaceSubrange(subrange, with: newElements)
    }
}

extension PathComponents: CustomStringConvertible {
    public var description: String {
        _value.joined(separator: "/")
    }
}

//MARK: Result Builder
extension PathComponents {
    /// A result builder you use to define a ``PathComponents`` instance.
    ///
    /// This result builder combines any number of `CustomStringConvertible` instances into a single PathComponents instance, with support for conditionals.
    /// Each component will be appended to an array of Strings. You can use this builder in any closure with the `@PathComponents.Builder` attribute.
    ///
    /// ```swift
    ///  PathComponents {
    ///     "first"
    ///     2 //uses the String representation of an Int
    ///  }
    ///  // Value of components: ["first","2"]
    ///  ```
    @resultBuilder
    public enum Builder {
        public static func buildBlock() -> PathComponents {
            .init()
        }
        
        public static func buildPartialBlock(first: PathComponents) -> PathComponents {
            first
        }
        
        public static func buildPartialBlock(accumulated: PathComponents, next: PathComponents) -> PathComponents {
            accumulated + next
        }
        
        public static func buildOptional(_ component: PathComponents?) -> PathComponents {
            component ?? .init()
        }
        
        public static func buildEither(first component: PathComponents) -> PathComponents {
            component
        }
        
        public static func buildEither(second component: PathComponents) -> PathComponents {
            component
        }
        
        public static func buildArray(_ components: [PathComponents]) -> PathComponents {
            .init(components.flatMap(\._value))
        }
        
        public static func buildExpression(_ expression: PathComponents) -> PathComponents {
            expression
        }
        
        public static func buildExpression(_ expression: CustomStringConvertible?) -> PathComponents {
            guard let expression else { return .init() }
            return PathComponents(expression.description)
        }
        
        public static func buildExpression(_ expression: [CustomStringConvertible]) -> PathComponents {
            PathComponents(expression.map(\.description))
        }
        
        public static func buildLimitedAvailability(_ component: PathComponents) -> PathComponents {
            component
        }
    }
}
