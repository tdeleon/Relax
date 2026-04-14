//
//  File.swift
//  Relax
//
//  Created by Thomas De Leon on 4/1/26.
//

import Foundation

extension Path {
    public struct Operation: Sendable {
        public let method: Request.HTTPMethod
        public let id: String?
        public let summary: String?
        public let description: String?
        public let tags: [Tag]
        public let parameters: [Parameter]
        public let responses: [Response.HTTPStatus: Response]
        public let security: [SecurityScheme]
        public let servers: [Server]
        
        public init(
            _ method: Request.HTTPMethod,
            id: StaticString? = nil,
            summary: String? = nil,
            @ResponsesBuilder responses: () -> [Response.HTTPStatus : Response],
            @Parameter.Builder parameters: () -> [Parameter] = { [] },
            @Tag.Builder tags: () -> [Tag] = { [] },
            @SecurityBuilder security: () -> [SecurityScheme] = { [] },
            @ServersBuilder servers: () -> [Server] = { [] },
            @DescriptionBuilder description: () -> String? = { nil }
        ) {
            self.method = method
            self.id = id == nil ? nil : "\(id!)"
            self.tags = tags()
            self.summary = summary
            self.description = description()
            self.parameters = parameters()
            self.responses = responses()
            self.security = security()
            self.servers = servers()
        }
        
        @resultBuilder
        public enum ResponsesBuilder {
            public static func buildBlock() -> [Response.HTTPStatus: Response] {
                [:]
            }
            
            public static func buildPartialBlock(
                first: [Response.HTTPStatus : Response]
            ) -> [Response.HTTPStatus : Response] {
                first
            }
            
            public static func buildPartialBlock(
                accumulated: [Response.HTTPStatus : Response],
                next: [Response.HTTPStatus : Response]
            ) -> [Response.HTTPStatus : Response] {
                accumulated.merging(next) { _, new in new }
            }
            
            public static func buildExpression(_ expression: Response) -> [Response.HTTPStatus : Response] {
                [expression.httpStatus: expression]
            }
        }
    }
}
