//
//  File.swift
//  Relax
//
//  Created by Thomas De Leon on 4/13/26.
//

import Foundation
import SwiftSyntax

internal struct PathDecl: Hashable {
    let path: String
    let summary: String?
    let tags: [TagDecl]
    let description: String?
    let servers: [ServerDecl]
    let operations: [String: OperationDecl]
    let parameters: [ParameterDecl]
    
    init(
        path: String,
        summary: String? = nil,
        tags: [TagDecl] = [],
        description: String? = nil,
        servers: [ServerDecl] = [],
        operations: [String : OperationDecl] = [:],
        parameters: [ParameterDecl] = []
    ) {
        self.path = path
        self.summary = summary
        self.tags = tags
        self.description = description
        self.servers = servers
        self.operations = operations
        self.parameters = parameters
    }
    
    static func from(_ expr: FunctionCallExprSyntax) -> Self? {
        let parameters = expr.additionalTrailingClosure(matching: "parameters")
        
        let tags = expr.additionalTrailingClosure(matching: "tags")?
            .compactMap { $0 }
            .compactMap { TagDecl.from($0) }
        
        let description = expr.parseDescription()
        
        return nil
    }
}

internal struct OperationDecl: Hashable {
    let method: String
    let id: String?
    let summary: String?
    let tags: [TagDecl]
    let parameters: [ParameterDecl]
    let responses: [String: ResponseDecl]
    let security: [SecuritySchemeDecl]
    let servers: [ServerDecl]
    
    init(
        method: String,
        id: String? = nil,
        summary: String? = nil,
        tags: [TagDecl] = [],
        parameters: [ParameterDecl] = [],
        responses: [String : ResponseDecl] = [:],
        security: [SecuritySchemeDecl] = [],
        servers: [ServerDecl] = []
    ) {
        self.method = method
        self.id = id
        self.summary = summary
        self.tags = tags
        self.parameters = parameters
        self.responses = responses
        self.security = security
        self.servers = servers
    }
}

internal struct ResponseDecl: Hashable {
    let summary: String?
    let description: String?
    let status: String
    let content: [String: String]
    
    init(summary: String? = nil, description: String? = nil, status: String, content: [String : String]) {
        self.summary = summary
        self.description = description
        self.status = status
        self.content = content
    }
}

internal struct ParameterDecl: Hashable {
    let name: String
    let location: String
    let description: String?
    let required: Bool
    let type: String
    
    init(name: String, location: String, description: String? = nil, required: Bool, type: String) {
        self.name = name
        self.location = location
        self.description = description
        self.required = required
        self.type = type
    }
}

internal struct TagDecl: Hashable {
    let name: String
    let summary: String?
    let description: String?
    
    init(name: String, summary: String? = nil, description: String? = nil) {
        self.name = name
        self.summary = summary
        self.description = description
    }
    
    static func from(_ expr: CodeBlockItemSyntax) -> Self? {
        var name: String?
        var summary: String?
        var description: String?
        
        if let funcCallExpr = expr.item.as(FunctionCallExprSyntax.self),
           funcCallExpr.calledExpression.as(DeclReferenceExprSyntax.self)?.baseName.text == "Tag" {
            name = funcCallExpr.arguments.first?.expression.as(StringLiteralExprSyntax.self)?.representedLiteralValue
            summary = funcCallExpr.argument("summary")?.expression.as(StringLiteralExprSyntax.self)?.representedLiteralValue
            description = funcCallExpr.parseDescription()
        } else {
            name = expr.item.as(StringLiteralExprSyntax.self)?.representedLiteralValue
        }
        
        guard let name else { return nil }
        return TagDecl(name: name, summary: summary, description: description)
    }
}
