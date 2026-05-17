//
//  Body.swift
//  
//
//  Created by Thomas De Leon on 1/11/23.
//

import Foundation

/// A structure which describes the body of a request
public struct Body: Hashable, Sendable {
    var _value: Data?
            
    public init(data: Data?) {
        self._value = data
    }
    
    /// Creates a body from an Encodable value encoded as JSON.
    /// - Parameters:
    ///   - data: Value to encode as JSON.
    ///   - encoder: An optional JSONEncoder to use for the encoding
    public init<T: Encodable>(_ value: T, encoder: JSONEncoder = JSONEncoder()) {
        self.init(data: try? encoder.encode(value))
    }
    
    /// Creates a body from a dictionary
    /// - Parameter dictionary: Dictionary to serialize as JSON
    /// - Parameter options: Options for JSONSerialization
    public init(_ dictionary: [String: Any], options: JSONSerialization.WritingOptions = []) {
        self.init(data: try? JSONSerialization.data(withJSONObject: dictionary, options: options))
    }
    
    /// Creates a body from any number of `Data` or `Encodable` instances using a ``Builder``.
    ///
    /// This initializer combines all `Data` or `Encodable` instances specified in `content`. Each instance will be appended to each other (from top to
    /// bottom), producing a single `Data` object. `Encodable` instances will be encoded into `Data`. ``Body`` instances can also be nested inside
    /// of `content`.
    ///
    /// - Note: When encoding `Encodable` instances, the default `JSONEncoder` will be used. If you need a custom encoder, use the
    /// ``Body/init(_:encoder:)`` initializer instead.
    /// - Parameter content: A body builder that returns the content of the body.
    public init(@Builder _ content: () -> Body) {
        self.init(data: content()._value)
    }
    
    public static func +(lhs: Self, rhs: Self) -> Self {
        if let leftData = lhs._value, let rightData = rhs._value {
            Body(data: leftData + rightData)
        } else if let leftData = lhs._value {
            Body(data: leftData)
        } else if let rightData = rhs._value {
            Body(data: rightData)
        } else {
            Body(data: nil)
        }
    }
    
    public static func +=(lhs: inout Self, rhs: Self) {
        lhs = lhs + rhs
    }
}

extension Body {
    @resultBuilder
    public enum Builder {
        public static func buildBlock() -> Body {
            .init(data: nil)
        }
        
        public static func buildPartialBlock(first: Body) -> Body {
            first
        }
        
        public static func buildPartialBlock(accumulated: Body, next: Body) -> Body {
            accumulated + next
        }
        
        public static func buildOptional(_ component: Body?) -> Body {
            component ?? Body(data: nil)
        }
        
        public static func buildEither(first component: Body) -> Body {
            component
        }
        
        public static func buildEither(second component: Body) -> Body {
            component
        }
        
        public static func buildArray(_ components: [Body]) -> Body {
            components.reduce(Body(data: nil), +)
        }
        
        public static func buildLimitedAvailability(_ component: Body) -> Body {
            component
        }
        
        public static func buildExpression(_ expression: Body) -> Body {
            expression
        }
        
        public static func buildExpression(_ expression: Data?) -> Body {
            .init(data: expression)
        }
        
        public static func buildExpression(_ expression: Data) -> Body {
            .init(data: expression)
        }
        
        public static func buildExpression<T: Encodable>(_ expression: T) -> Body {
            .init(expression)
        }
        
        public static func buildExpression(_ expression: [String: Any]) -> Body {
            .init(expression)
        }
    }
}
