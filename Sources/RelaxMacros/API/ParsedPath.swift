//
//  ParsedPath.swift
//  Relax
//
//  Created by Thomas De Leon on 4/13/26.
//

import Foundation
import SwiftSyntax
import SwiftSyntaxMacros

internal struct ParsedPath: APIDecl {
    let path: String
    let summary: String?
    let tags: [ParsedTag]
    let description: String?
    let servers: [ServerDecl]
    let operations: [String: ParsedOperation]
    let parameters: [ParsedParameter]
    
    init(
        path: String,
        summary: String? = nil,
        tags: [ParsedTag] = [],
        description: String? = nil,
        servers: [ServerDecl] = [],
        operations: [String : ParsedOperation] = [:],
        parameters: [ParsedParameter] = []
    ) {
        self.path = path
        self.summary = summary
        self.tags = tags
        self.description = description
        self.servers = servers
        self.operations = operations
        self.parameters = parameters
    }
    
    static func from(_ expr: FunctionCallExprSyntax, in context: MacroExpansionContext) -> Self? {
        guard let path = expr.arguments.first?.expression.as(StringLiteralExprSyntax.self)?.representedLiteralValue else { return nil }
        
        let summary = expr.argument("summary")?.expression.as(StringLiteralExprSyntax.self)?.representedLiteralValue
        
        let operations = expr.trailingClosure?.statements.functionCallExprItems {
            ParsedOperation.from(expr: $0, in: context)
        }
            .reduce(into: [:]) { $0[$1.method] = $1 }
        
        let servers = expr.additionalTrailingClosure(matching: "servers")?
            .compactMap { $0.item.as(FunctionCallExprSyntax.self) }
            .compactMap { ServerDecl.parse($0, in: context) } ?? []
        
        let parameters = expr.additionalTrailingClosure(matching: "parameters")?
            .compactMap { $0.item.as(FunctionCallExprSyntax.self) }
            .compactMap { ParsedParameter.from($0) }
        
        let tags = expr.additionalTrailingClosure(matching: "tags")?.compactMap { ParsedTag.from($0) } ?? []
        
        let description = expr.parseDescription()
        
        return ParsedPath(
            path: path,
            summary: summary,
            tags: tags,
            description: description,
            servers: servers,
            operations: operations ?? [:],
            parameters: parameters ?? []
        )
    }
}

internal struct ParsedOperation: APIDecl {
    let method: String
    let id: String?
    let summary: String?
    let description: String?
    let tags: [ParsedTag]
    let parameters: [ParsedParameter]
    let responses: [String: ParsedResponse]
    let security: [SecuritySchemeDecl]
    let servers: [ServerDecl]
    
    init(
        method: String,
        id: String? = nil,
        summary: String? = nil,
        description: String? = nil,
        tags: [ParsedTag] = [],
        parameters: [ParsedParameter] = [],
        responses: [String : ParsedResponse] = [:],
        security: [SecuritySchemeDecl] = [],
        servers: [ServerDecl] = []
    ) {
        self.method = method
        self.id = id
        self.summary = summary
        self.description = description
        self.tags = tags
        self.parameters = parameters
        self.responses = responses
        self.security = security
        self.servers = servers
    }
    
    static func from(expr: FunctionCallExprSyntax, in context: MacroExpansionContext) -> Self? {
        guard let method = expr.arguments.first?.expression.as(MemberAccessExprSyntax.self)?.trimmedDescription
        else { return nil }
        
        let id = expr.argument("id")?.expression.as(StringLiteralExprSyntax.self)?.representedLiteralValue
        let summary = expr.argument("summary")?.expression.as(StringLiteralExprSyntax.self)?.representedLiteralValue
        let description = expr.parseDescription()
        
        let tags = expr.additionalTrailingClosure(matching: "tags")?.compactMap { ParsedTag.from($0) }

        let parameters = expr.additionalTrailingClosure(matching: "parameters")?
            .functionCallExprItems
            .compactMap { ParsedParameter.from($0) }
        
        let security = expr.additionalTrailingClosure(matching: "security")?
            .functionCallExprItems { SecuritySchemeDecl.from($0)
        }
        
        let responses = expr.trailingClosure?.statements
            .functionCallExprItems { ParsedResponse.from($0) }
            .reduce(into: [:]) { $0[$1.status] = $1 }
        
        let servers = expr.additionalTrailingClosure(matching: "servers")?
            .functionCallExprItems { ServerDecl.parse($0, in: context) }
        
        return ParsedOperation(
            method: method,
            id: id,
            summary: summary,
            description: description,
            tags: tags ?? [],
            parameters: parameters ?? [],
            responses: responses ?? [:],
            security: security ?? [],
            servers: servers ?? []
        )
    }
}

internal struct ParsedResponse: APIDecl {
    let summary: String?
    let description: String?
    let status: String
    let content: [String: ParsedContent]
    
    init(summary: String? = nil, description: String? = nil, status: String, content: [String : ParsedContent]) {
        self.summary = summary
        self.description = description
        self.status = status
        self.content = content
    }
    
    static func from(_ expr: FunctionCallExprSyntax) -> Self? {
        guard expr.baseName(matches: "Response"),
              let status = expr.arguments.first?.expression.as(FunctionCallExprSyntax.self)?.trimmedDescription
        else { return nil }
        // status is first unlabeled argument, or default to .success if not present

        
        // summary labeled arg
        let summary = expr.argument("summary")?.expression.as(StringLiteralExprSyntax.self)?.representedLiteralValue
        
        var content: [String: ParsedContent]?
        // payload arg
        if let payloadExpr = expr.argument("payload")?.expression.as(FunctionCallExprSyntax.self) {
            // returning decodable -> shortcut to content [.application/json: Type]
            guard let payload = ParsedContent.Payload(expr: payloadExpr) else { return nil }
            content = [payload.contentType: ParsedContent(type: payload.contentType, payload: payload)]
        } else if let returning = expr.argument("returning")?
            .expression.as(MemberAccessExprSyntax.self)?
            .base?.as(DeclReferenceExprSyntax.self)?
            .trimmedDescription {
            let type = "applicationJSON"
            content = [type: ParsedContent(type: type, payload: ParsedContent.Payload.json(type: returning))]
        } else if let contentBuilder = expr.trailingClosure?
            .statements
            .functionCallExprItems(mapping: { ParsedContent.from($0) })
            .reduce(into: [:], { $0[$1.type] = $1 }) {
            content = contentBuilder
        }
        
        // description
        let description = expr.parseDescription()
        
        return ParsedResponse(summary: summary, description: description, status: status, content: content ?? [:])
    }
}

internal struct ParsedContent: APIDecl {
    let type: String
    let payload: Payload
    
    enum Payload: Hashable {
        case empty
        case bytes
        case json(type: String)
        case text(encoding: String)
        
        init?(expr: FunctionCallExprSyntax) {
            guard let type = expr.calledExpression.as(MemberAccessExprSyntax.self)?.declName.trimmedDescription
            else { return nil }
            
            let arg = expr.arguments.first?.trimmedDescription
            
            switch type {
            case "empty":
                self = .empty
            case "bytes":
                self = .bytes
            case "json":
                guard let arg else { return nil }
                self = .json(type: arg)
            case "text":
                guard let arg else { return nil }
                self = .text(encoding: arg)
            default:
                return nil
                
            }
        }
        
        var contentType: String {
            switch self {
            case .empty:
                "nil"
            case .bytes:
                ".applicationOctetStream"
            case .json:
                ".applicationJSON"
            case .text:
                ".textPlain"
            }
        }
    }
    
    static func from(_ expr: FunctionCallExprSyntax) -> Self? {
        if expr.calledExpression.as(MemberAccessExprSyntax.self)?.trimmedDescription == "Response.Content" {
            return parseStaticType(expr)
        } else {
            return parseContentPayload(expr)
        }
    }
    
    private static func parseStaticType(_ expr: FunctionCallExprSyntax) -> ParsedContent? {
        guard let contentArg = expr.arguments.first?.expression.as(MemberAccessExprSyntax.self)?.declName.trimmedDescription,
              let payloadExpr = expr.argument("payload")?.expression.as(FunctionCallExprSyntax.self),
              let payload = Payload(expr: payloadExpr)
        else { return nil }
        return ParsedContent(type: contentArg, payload: payload)
    }
    
    private static func parseContentPayload(_ expr: FunctionCallExprSyntax) -> ParsedContent? {
        guard let staticType = expr.calledExpression.as(MemberAccessExprSyntax.self)?.declName.trimmedDescription
        else { return nil }
        // parse args for static types
        let typeArg = expr.arguments.first?.expression.as(MemberAccessExprSyntax.self)?.trimmedDescription
        
        let contentType: String
        let payload: Payload
        
        switch staticType {
        case "json":
            guard let typeArg else { return nil }
            contentType = ".applicationJSON"
            payload = .json(type: typeArg)
        case "jsonDictionary":
            contentType = ".applicationJSON"
            payload = .bytes
        case "text":
            contentType = ".textPlain"
            payload = .text(encoding: typeArg ?? "utf8")
        case "data":
            contentType = typeArg ?? ".applicationOctetStream"
            payload = .bytes
        default:
            return nil
        }
        
        return ParsedContent(type: contentType, payload: payload)
    }
}

internal struct ParsedParameter: APIDecl {
    let name: String
    let location: String
    let description: String?
    let required: Bool
    let type: String
    let style: String?
    
    init(name: String, location: String, description: String? = nil, required: Bool, type: String, style: String?) {
        self.name = name
        self.location = location
        self.description = description
        self.required = required
        self.type = type
        self.style = style
    }
    
    static func from(_ expr: FunctionCallExprSyntax) -> Self? {
        guard expr.baseName(matches: "Parameter"),
              let location = expr.calledExpression.as(MemberAccessExprSyntax.self)?.declName.trimmedDescription,
              let name = expr.arguments.first?.expression.as(StringLiteralExprSyntax.self)?.representedLiteralValue
        else { return nil }
        
        let requiredString = expr.argument("required")?.expression.as(BooleanLiteralExprSyntax.self)?.literal.text
        let required = Bool(requiredString ?? "false") ?? false
        let description = expr.parseDescription()
        
        let type = (expr.argument("valueType") ?? expr.argument("ofType") ?? expr.argument("ofObjectType"))?
            .expression.as(MemberAccessExprSyntax.self)?.trimmedDescription ?? "String.self"
        
        var style = expr.argument("style")?.expression.as(MemberAccessExprSyntax.self)?.trimmedDescription
        switch location {
        case "path":
            style = style ?? ".simple"
        case "query":
            style = style ?? ".form"
        default:
            break
        }
                
        return ParsedParameter(
            name: name,
            location: location,
            description: description,
            required: required,
            type: type,
            style: style
        )
    }
}

internal struct ParsedTag: APIDecl {
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
        return ParsedTag(name: name, summary: summary, description: description)
    }
}
