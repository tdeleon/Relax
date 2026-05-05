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
    public let group: String?
    public let description: String?
    public let operations: [Request.HTTPMethod: Operation]
    public let servers: [Server]
    public let parameters: [Parameter]
    
    public init(
        _ path: String,
        @OperationsBuilder operations: () -> [Request.HTTPMethod: Operation],
        @Parameter.Builder parameters: () -> [Parameter] = { [] },
        @ServersBuilder servers: () -> [Server] = { [] },
    ) {
        self.path = path
        self.summary = nil
        self.group = nil
        self.servers = servers()
        self.operations = operations()
        self.parameters = parameters()
        self.description = nil
    }
    
    public init(
        _ path: String,
        summary: String? = nil,
        group: String,
        @OperationsBuilder operations: () -> [Request.HTTPMethod: Operation],
        @Parameter.Builder parameters: () -> [Parameter] = { [] },
        @ServersBuilder servers: () -> [Server] = { [] },
        @DescriptionBuilder description: () -> String? = { nil }
    ) {
        self.path = path
        self.summary = summary
        self.group = group
        self.servers = servers()
        self.operations = operations()
        self.parameters = parameters()
        self.description = description()
    }
    
    public init(
        _ path: String,
        summary: String? = nil,
        tag: Tag,
        @OperationsBuilder operations: () -> [Request.HTTPMethod: Operation],
        @Parameter.Builder parameters: () -> [Parameter] = { [] },
        @ServersBuilder servers: () -> [Server] = { [] },
        @DescriptionBuilder description: () -> String? = { nil }
    ) {
        self.path = path
        self.summary = summary
        self.group = tag.name
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
