//
//  Path.swift
//  Relax
//
//  Created by Thomas De Leon on 3/3/26.
//

import Foundation
import HTTPTypes

public struct Path: Sendable {
    public let path: String
    public let summary: String?
    public let group: String?
    public let description: String?
    public let operations: [HTTPRequest.Method: Operation]
    public let servers: [Server]
    public let parameters: [Parameter]
    
    public init(
        _ path: String,
        @OperationsBuilder operations: () -> [HTTPRequest.Method: Operation],
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
        @OperationsBuilder operations: () -> [HTTPRequest.Method: Operation],
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
        @OperationsBuilder operations: () -> [HTTPRequest.Method: Operation],
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
        public static func buildBlock() -> [HTTPRequest.Method: Path.Operation] {
            [:]
        }
        
        public static func buildPartialBlock(
            first: [HTTPRequest.Method: Path.Operation]
        ) -> [HTTPRequest.Method: Path.Operation] {
            first
        }
        
        public static func buildPartialBlock(
            accumulated: [HTTPRequest.Method: Path.Operation],
            next: [HTTPRequest.Method: Path.Operation]
        ) -> [HTTPRequest.Method: Path.Operation] {
            accumulated.merging(next) { _, new in new }
        }
        
        public static func buildExpression(_ expression: Path.Operation) -> [HTTPRequest.Method: Path.Operation] {
            [expression.method: expression]
        }
    }
}
