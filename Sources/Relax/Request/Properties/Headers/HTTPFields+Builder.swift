//
//  HTTPFields+Builder.swift
//  Relax
//
//  Created by Thomas De Leon on 1/11/23.
//

import Foundation
import HTTPTypes


extension HTTPFields {
    public init(@Builder fields: () -> HTTPFields) {
        self = fields()
    }
    
    @resultBuilder
    public enum Builder {
        public static func buildBlock() -> HTTPFields {
            HTTPFields()
        }
        
        public static func buildPartialBlock(first: HTTPFields) -> HTTPFields {
            first
        }
        
        public static func buildPartialBlock(accumulated: HTTPFields, next: HTTPFields) -> HTTPFields {
            accumulated + next
        }
        
        public static func buildOptional(_ component: HTTPFields?) -> HTTPFields {
            component ?? HTTPFields()
        }
        
        public static func buildEither(first component: HTTPFields) -> HTTPFields {
            component
        }
        
        public static func buildEither(second component: HTTPFields) -> HTTPFields {
            component
        }
        
        public static func buildArray(_ components: [HTTPFields]) -> HTTPFields {
            components.reduce(into: HTTPFields()) { $0 += $1 }
        }
        
        public static func buildExpression(_ expression: HTTPFields) -> HTTPFields {
            expression
        }
        
        public static func buildExpression(_ expression: HTTPField) -> HTTPFields {
            HTTPFields([expression])
        }
        
        public static func buildExpression(_ expression: HTTPField?) -> HTTPFields {
            guard let expression else { return HTTPFields() }
            return HTTPFields([expression])
        }
        
        public static func buildExpression(_ expression: (HTTPField.Name, String)) -> HTTPFields {
            HTTPFields(dictionaryLiteral: expression)
        }
        
        public static func buildExpression(_ expression: (String, String)) -> HTTPFields {
            guard let name = HTTPField.Name(expression.0) else { return HTTPFields() }
            return HTTPFields(dictionaryLiteral: (name, expression.1))
        }
    }
}
