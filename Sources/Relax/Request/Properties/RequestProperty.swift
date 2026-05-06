//
//  RequestProperty.swift
//  
//
//  Created by Thomas De Leon on 1/11/23.
//

import Foundation
import HTTPTypes

extension Request {
    /// A structure that groups properties of a request
    public struct Properties: Hashable, Sendable {
        public var headers: HTTPFields = HTTPFields()
        public var queryItems: QueryItems = QueryItems([])
        public var pathComponents: PathComponents = PathComponents([])
        public var body: Body = Body(value: nil)
        
        public static func +(lhs: Properties, rhs: Properties) -> Request.Properties {
            var new = rhs
            new.headers += lhs.headers
            new.queryItems += lhs.queryItems
            new.pathComponents += lhs.pathComponents
            new.body = lhs.body.append(to: new.body)
            return new
        }
        
        public static func +=(left: inout Self, right: Self) {
            left = left + right
        }
        
        /// Provides an instance with no property values set
        public static let empty: Properties = .init()
        
        public init(
            headers: HTTPFields = HTTPFields(),
            queryItems: QueryItems = QueryItems([]),
            pathComponents: PathComponents = PathComponents([]),
            body: Body = Body(value: nil)
        ) {
            self.headers = headers
            self.queryItems = queryItems
            self.pathComponents = pathComponents
            self.body = body
        }
        
        public init(@Builder builder: () -> Request.Properties) {
            let properties = builder()
            self.init(
                headers: properties.headers,
                queryItems: properties.queryItems,
                pathComponents: properties.pathComponents,
                body: properties.body
            )
        }
    }
}

//MARK: Result Builder
extension Request.Properties {
    /// A result builder to combine one or more ``RequestProperty`` into a single instance
    @resultBuilder
    public enum Builder {
        public static func buildBlock() -> Request.Properties {
            .empty
        }
        
        public static func buildPartialBlock(first: Request.Properties) -> Request.Properties {
            first
        }
        
        public static func buildPartialBlock(accumulated: Request.Properties, next: Request.Properties) -> Request.Properties {
            accumulated + next
        }
        
        public static func buildOptional(_ component: Request.Properties?) -> Request.Properties {
            component ?? .empty
        }
        
        public static func buildEither(first component: Request.Properties) -> Request.Properties {
            component
        }
        
        public static func buildEither(second component: Request.Properties) -> Request.Properties {
            component
        }
        
        public static func buildArray(_ components: [Request.Properties]) -> Request.Properties {
            components.reduce(.empty, +)
        }
        
        public static func buildLimitedAvailability(_ component: Request.Properties) -> Request.Properties {
            component
        }
        
        public static func buildExpression(_ expression: HTTPFields) -> Request.Properties {
            Request.Properties(headers: expression)
        }
        
        public static func buildExpression(_ expression: HTTPField) -> Request.Properties {
            Request.Properties(headers: HTTPFields([expression]))
        }
        
        public static func buildExpression(_ expression: QueryItems) -> Request.Properties {
            Request.Properties(queryItems: expression)
        }
        
        public static func buildExpression(_ expression: URLQueryItem) -> Request.Properties {
            Request.Properties(queryItems: QueryItems([expression]))
        }
        
        public static func buildExpression(_ expression: PathComponents) -> Request.Properties {
            Request.Properties(pathComponents: expression)
        }
        
        public static func buildExpression(_ expression: Body) -> Request.Properties {
            Request.Properties(body: expression)
        }
        
        public static func buildExpression(_ expression: Request.Properties) -> Request.Properties {
            expression
        }
    }
}
