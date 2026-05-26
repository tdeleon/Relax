//
//  Operation.swift
//  Relax
//
//  Created by Thomas De Leon on 4/1/26.
//

import Foundation
import HTTPTypes

extension Path {
    public struct Operation: Sendable {
        public let method: HTTPRequest.Method
        public let id: String?
        public let summary: String?
        public let description: String?
        public let tags: [Tag]
        public let parameters: [Parameter]
        public let body: Body
        public let bodyParameter: BodyParameter?
        public let responses: [Response]
        public let security: [SecurityScheme]
        public let servers: [Server]
        
        internal init(
            method: HTTPRequest.Method,
            id: StaticString?,
            summary: String?,
            description: String?,
            tags: [Tag],
            parameters: [Parameter],
            body: Body,
            bodyParameter: BodyParameter?,
            responses: [Response],
            security: [SecurityScheme],
            servers: [Server]
        ) {
            self.method = method
            self.id = id.map { "\($0)" }
            self.summary = summary
            self.description = description
            self.tags = tags
            self.parameters = parameters
            self.body = body
            self.bodyParameter = bodyParameter
            self.responses = responses
            self.security = security
            self.servers = servers
        }

        /// Create a request operation
        /// - Parameters:
        ///   - method: The HTTP method to use
        ///   - id: An optional identifier for this operation
        ///   - bodyParameter: A parameter to be sent in the request body
        ///   - summary: A short summary of the operation
        ///   - responses: Expected responses to be received
        ///   - parameters: Parameters for the operation
        ///   - tags: Tags to group the operation under
        ///   - security: Security schemes to apply to the operation, overriding those defined on a given server
        ///   - servers: Servers to use for this operation, overriding those defined at the root level of the API
        ///   - description: A longer description of the operation
        public init(
            _ method: HTTPRequest.Method,
            id: StaticString? = nil,
            bodyParameter: BodyParameter? = nil,
            summary: String? = nil,
            @ResponsesBuilder responses: () -> [Response],
            @Parameter.Builder parameters: () -> [Parameter] = { [] },
            @Tag.Builder tags: () -> [Tag] = { [] },
            @SecurityBuilder security: () -> [SecurityScheme] = { [] },
            @ServersBuilder servers: () -> [Server] = { [] },
            @DescriptionBuilder description: () -> String? = { nil }
        ) {
            self.init(
                method: method,
                id: id,
                summary: summary,
                description: description(),
                tags: tags(),
                parameters: parameters(),
                body: Body(data: nil),
                bodyParameter: bodyParameter,
                responses: responses(),
                security: security(),
                servers: servers()
            )
        }
        
        /// Create a request operation with a body
        /// - Parameters:
        ///   - method: The HTTP method to use
        ///   - id: An optional identifier for this operation
        ///   - summary: A short summary of the operation
        ///   - responses: Expected responses to be received
        ///   - parameters: Parameters for the operation
        ///   - body: A body to be sent on the request
        ///   - tags: Tags to group the operation under
        ///   - security: Security schemes to apply to the operation, overriding those defined on a given server
        ///   - servers: Servers to use for this operation, overriding those defined at the root level of the API
        ///   - description: A longer description of the operation
        public init(
            _ method: HTTPRequest.Method,
            id: StaticString? = nil,
            summary: String? = nil,
            @ResponsesBuilder responses: () -> [Response],
            @Parameter.Builder parameters: () -> [Parameter] = { [] },
            @Body.Builder body: () -> Body,
            @Tag.Builder tags: () -> [Tag] = { [] },
            @SecurityBuilder security: () -> [SecurityScheme] = { [] },
            @ServersBuilder servers: () -> [Server] = { [] },
            @DescriptionBuilder description: () -> String? = { nil }
        ) {
            self.init(
                method: method,
                id: id,
                summary: summary,
                description: description(),
                tags: tags(),
                parameters: parameters(),
                body: body(),
                bodyParameter: nil,
                responses: responses(),
                security: security(),
                servers: servers()
            )
        }
        
        @resultBuilder
        public enum ResponsesBuilder {
            public static func buildBlock() -> [Response] {
                []
            }
            
            public static func buildPartialBlock(
                first: [Response]
            ) -> [Response] {
                first
            }
            
            public static func buildPartialBlock(
                accumulated: [Response],
                next: [Response]
            ) -> [Response] {
                accumulated + next
            }
            
            public static func buildExpression(_ expression: Response) -> [Response] {
                [expression]
            }
        }
    }
}
