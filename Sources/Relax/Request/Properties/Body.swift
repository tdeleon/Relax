//
//  Body.swift
//  
//
//  Created by Thomas De Leon on 1/11/23.
//

import Foundation

public struct Body: RequestProperty {
    public var baseValue: Data?
            
    public init(value: Data?) {
        self.baseValue = value
    }
    
    public init<Model: Encodable>(_ model: Model, encoder: JSONEncoder = JSONEncoder()) {
        self.init(value: try? encoder.encode(model))
    }
    
    public init(@Builder _ body: () -> Body) {
        self.init(value: body().baseValue)
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
