//
//  API.swift
//  Relax
//
//  Created by Thomas De Leon on 3/3/26.
//

import Foundation

public protocol API {
    @ServersBuilder var servers: [Server] { get }
    @PathsBuilder var paths: [Path] { get }
    @SecurityBuilder var security: [SecurityScheme] { get }
}

extension API {
    public var security: [SecurityScheme] { [] }
}

@resultBuilder
public enum PathsBuilder {
    public static func buildBlock() -> [Path] {
        []
    }
    
    public static func buildPartialBlock(first: [Path]) -> [Path] {
        first
    }
    
    public static func buildPartialBlock(accumulated: [Path], next: [Path]) -> [Path] {
        accumulated + next
    }
    
    public static func buildExpression(_ expression: Path) -> [Path] {
        [expression]
    }
}

@resultBuilder
public enum ServersBuilder {
    public static func buildBlock() -> [Server] {
        []
    }
    
    public static func buildPartialBlock(first: [Server]) -> [Server] {
        first
    }
    
    public static func buildPartialBlock(accumulated: [Server], next: [Server]) -> [Server] {
        accumulated + next
    }
    
    public static func buildExpression(_ expression: Server) -> [Server] {
        [expression]
    }
}

@resultBuilder
public enum SecurityBuilder {
    public static func buildBlock() -> [SecurityScheme] {
        []
    }
    
    public static func buildPartialBlock(first: [SecurityScheme]) -> [SecurityScheme] {
        first
    }
    
    public static func buildPartialBlock(accumulated: [SecurityScheme], next: [SecurityScheme]) -> [SecurityScheme] {
        accumulated + next
    }
    
    public static func buildExpression(_ expression: SecurityScheme) -> [SecurityScheme] {
        [expression]
    }
}
