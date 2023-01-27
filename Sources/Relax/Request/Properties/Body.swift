//
//  Body.swift
//  
//
//  Created by Thomas De Leon on 1/11/23.
//

import Foundation

/// Describes the body of a request
public struct Body: RequestProperty {
    public var baseValue: Data?
            
    public init(value: Data?) {
        self.baseValue = value
    }
    
    /// Creates a body from an Encodable value encoded as JSON.
    /// - Parameters:
    ///   - value: Value to encode as JSON.
    ///   - encoder: An optional JSONEncoder to use for the encoding
    public init<T: Encodable>(_ value: T, encoder: JSONEncoder = JSONEncoder()) {
        self.init(value: try? encoder.encode(value))
    }
    
    /// Creates a body from any number of `Data` or `Encodable` instances.
    ///
    /// This initializer combines all `Data` or `Encodable` instances specified in `content`. Each instance will be appended to each other (from top to
    /// bottom), producing a single `Data` object. `Encodable` instances will be encoded into `Data`. ``Body`` instances can also be nested inside
    /// of `content`.
    ///
    /// - Note: When encoding `Encodable` instances, the default `JSONEncoder` will be used. If you need a custom encoder, use the
    /// ``Body/init(_:encoder:)`` initializer instead.
    /// - Parameter content: A body builder that returns the content of the body.
    public init(@Builder _ content: () -> Body) {
        self.init(value: content().baseValue)
    }
    
    public func append(to property: Body) -> Body {
        if let baseValue, let other = property.baseValue {
            return Body(value: baseValue + other)
        } else if let baseValue {
            return Body(value: baseValue)
        } else if let other = property.baseValue {
            return Body(value: other)
        } else {
            return Body(value: nil)
        }
    }
}

extension Body {
    @resultBuilder
    public enum Builder {
        public static func buildBlock() -> Body {
            .init(value: nil)
        }
        
        public static func buildPartialBlock(first: Body) -> Body {
            first
        }
        
        public static func buildPartialBlock(accumulated: Body, next: Body) -> Body {
            accumulated + next
        }
        
        public static func buildOptional(_ component: Body?) -> Body {
            component ?? Body(value: nil)
        }
        
        public static func buildEither(first component: Body) -> Body {
            component
        }
        
        public static func buildEither(second component: Body) -> Body {
            component
        }
        
        public static func buildArray(_ components: [Body]) -> Body {
            components.reduce(Body(value: nil), +)
        }
        
        public static func buildLimitedAvailability(_ component: Body) -> Body {
            component
        }
        
        public static func buildExpression(_ expression: Body) -> Body {
            expression
        }
        
        public static func buildExpression(_ expression: Data?) -> Body {
            .init(value: expression)
        }
        
        public static func buildExpression(_ expression: Data) -> Body {
            .init(value: expression)
        }
        
        public static func buildExpression<T: Encodable>(_ expression: T) -> Body {
            .init(expression)
        }
    }
}
