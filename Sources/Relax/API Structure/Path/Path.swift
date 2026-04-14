//
//  Path.swift
//  Relax
//
//  Created by Thomas De Leon on 3/3/26.
//

import Foundation

public struct Path: Sendable {
    public let path: String
    public let summary: String?
    public let tags: [Tag]
    public let description: String?
    public let operations: [Request.HTTPMethod: Operation]
    public let servers: [Server]
    public let parameters: [Parameter]
    
    public init(
        _ path: String,
        summary: String? = nil,
        @OperationsBuilder operations: () -> [Request.HTTPMethod: Operation],
        @Parameter.Builder parameters: () -> [Parameter] = { [] },
        @ServersBuilder servers: () -> [Server] = { [] },
        @Tag.Builder tags: () -> [Tag] = { [] },
        @DescriptionBuilder description: () -> String? = { nil }
    ) {
        self.path = path
        self.summary = summary
        self.tags = tags()
        self.servers = servers()
        self.operations = operations()
        self.parameters = parameters()
        self.description = description()
    }
    
    @resultBuilder
    public enum OperationsBuilder {
        public static func buildBlock() -> [Request.HTTPMethod: Path.Operation] {
            [:]
        }
        
        public static func buildPartialBlock(
            first: [Request.HTTPMethod: Path.Operation]
        ) -> [Request.HTTPMethod: Path.Operation] {
            first
        }
        
        public static func buildPartialBlock(
            accumulated: [Request.HTTPMethod: Path.Operation],
            next: [Request.HTTPMethod: Path.Operation]
        ) -> [Request.HTTPMethod: Path.Operation] {
            accumulated.merging(next) { _, new in new }
        }
        
        public static func buildExpression(_ expression: Path.Operation) -> [Request.HTTPMethod: Path.Operation] {
            [expression.method: expression]
        }
    }
}
