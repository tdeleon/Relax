//
//  API.swift
//  Relax
//
//  Created by Thomas De Leon on 3/3/26.
//

import Foundation

public protocol API {
    @ServersBuilder var servers: [Server] { get }
    @EndpointsBuilder var endpoints: [Endpoint] { get }
    @SecurityBuilder var security: [SecurityScheme] { get }
}

extension API {
    public var security: [SecurityScheme] { [] }
}

@resultBuilder
public enum EndpointsBuilder {
    public static func buildBlock() -> [Endpoint] {
        []
    }
    
    public static func buildPartialBlock(first: [Endpoint]) -> [Endpoint] {
        first
    }
    
    public static func buildPartialBlock(accumulated: [Endpoint], next: [Endpoint]) -> [Endpoint] {
        accumulated + next
    }
    
    public static func buildExpression(_ expression: Endpoint) -> [Endpoint] {
        [expression]
    }
    
    @available(*, unavailable, message: "Optionals are not supported in this builder.")
    public static func buildOptional(_ component: [Endpoint]?) -> [Endpoint] {
        component ?? []
    }
    
    @available(*, unavailable, message: "Conditionals are not supported in this builder.")
    public static func buildEither(first component: [Endpoint]) -> [Endpoint] {
        component
    }
    
    @available(*, unavailable, message: "Conditionals are not supported in this builder.")
    public static func buildEither(second component: [Endpoint]) -> [Endpoint] {
        component
    }
    
    @available(*, unavailable, message: "Arrays are not supported in this builder.")
    public static func buildArray(_ components: [[Endpoint]]) -> [Endpoint] {
        components.flatMap { $0 }
    }
    
    @available(*, unavailable, message: "Conditionals are not supported in this builder.")
    public static func buildLimitedAvailability(_ component: [Endpoint]) -> [Endpoint] {
        component
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
    
    @available(*, unavailable, message: "Optionals are not supported in this builder.")
    public static func buildOptional(_ component: [Server]?) -> [Server] {
        component ?? []
    }
    
    @available(*, unavailable, message: "Conditionals are not supported in this builder.")
    public static func buildEither(first component: [Server]) -> [Server] {
        component
    }
    
    @available(*, unavailable, message: "Conditionals are not supported in this builder.")
    public static func buildEither(second component: [Server]) -> [Server] {
        component
    }
    
    @available(*, unavailable, message: "Arrays are not supported in this builder.")
    public static func buildArray(_ components: [[Server]]) -> [Server] {
        components.flatMap { $0 }
    }
    
    @available(*, unavailable, message: "Conditionals are not supported in this builder.")
    public static func buildLimitedAvailability(_ component: [Server]) -> [Server] {
        component
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
    
    @available(*, unavailable, message: "Optionals are not supported in this builder.")
    public static func buildOptional(_ component: [SecurityScheme]?) -> [SecurityScheme] {
        component ?? []
    }
    
    @available(*, unavailable, message: "Conditionals are not supported in this builder.")
    public static func buildEither(first component: [SecurityScheme]) -> [SecurityScheme] {
        component
    }
    
    @available(*, unavailable, message: "Conditionals are not supported in this builder.")
    public static func buildEither(second component: [SecurityScheme]) -> [SecurityScheme] {
        component
    }
    
    @available(*, unavailable, message: "Arrays are not supported in this builder.")
    public static func buildArray(_ components: [[SecurityScheme]]) -> [SecurityScheme] {
        components.flatMap { $0 }
    }
    
    @available(*, unavailable, message: "Conditionals are not supported in this builder.")
    public static func buildLimitedAvailability(_ component: [SecurityScheme]) -> [SecurityScheme] {
        component
    }
}
