//
//  ServerDeclaration.swift
//  Relax
//
//  Created by Thomas De Leon on 4/9/26.
//

import Foundation
import SwiftSyntax
import SwiftSyntaxMacros
import SwiftDiagnostics

internal struct ServerDecl: APIDecl {
    let name: String
    let url: String
    let variables: [ServerVariableDecl]
    let description: String?
    
    static func parse(_ expr: FunctionCallExprSyntax, in context: MacroExpansionContext) -> ServerDecl? {
        guard expr.baseName(matches: "Server"),
              let name = expr.arguments.first?.expression.as(StringLiteralExprSyntax.self)?.representedLiteralValue,
              let urlExpr = expr.argument("url")?.expression.as(StringLiteralExprSyntax.self),
              let url = urlExpr.representedLiteralValue
        else { return nil }
        
        let description = expr.parseDescription()
        
        let variables = expr.trailingClosure?.statements
            .compactMap { $0.item.as(FunctionCallExprSyntax.self) }
            .compactMap { ServerVariableDecl.parse($0) } ?? []
        
        let placeholders = url.matches(of: /([^{]+(?=}))/).map { String($0.output.1) }
        
        let matchedVariables = variables.filter {
            guard Set(placeholders).contains($0.name) else {
                if let expr = $0.expr {
                    context.diagnose(
                        Diagnostic(node: expr, message: MacroExpansionWarningMessage("Server Variable \"\($0.name)\" is missing from the URL template; it will be ignored."))
                    )
                }
                return false
            }
            return true
        }
        
        let duplicateVariables = Dictionary(grouping: matchedVariables, by: \.name)
            .filter { $1.count > 1 }
            .flatMap(\.value)
        
        duplicateVariables.forEach {
            if let expr = $0.expr {
                context.diagnose(
                    Diagnostic(node: expr, message: MacroExpansionWarningMessage("Duplicate Server Variable \"\($0.name)\"; only the first will be used."))
                )
            }
        }
        
        let matchedNames = Set(matchedVariables.map(\.name))
        
        let templateOnlyVariables = Set(placeholders).subtracting(matchedNames).map {
            ServerVariableDecl(name: $0, type: "String.self", defaultValue: nil, description: nil, expr: nil)
        }
        
        return ServerDecl(name: name, url: url, variables: variables+templateOnlyVariables, description: description)
    }
}

extension FunctionCallExprSyntax {
    internal func baseName(matches: String) -> Bool {
        calledExpression.trimmedDescription == matches ||
        calledExpression.as(MemberAccessExprSyntax.self)?.base?.trimmedDescription == matches
    }
    
    internal func parseDescription() -> String? {
        trailingClosure?
            .statements.first?
            .item.as(StringLiteralExprSyntax.self)?
            .representedLiteralValue ??
        additionalTrailingClosure(matching: "description")?.first?
            .item.as(StringLiteralExprSyntax.self)?
            .representedLiteralValue ??
        argument("description")?.expression.as(StringLiteralExprSyntax.self)?.representedLiteralValue
    }
    
    internal func additionalTrailingClosure(matching label: String) -> CodeBlockItemListSyntax? {
        additionalTrailingClosures
            .first { $0.label.text == label }?
            .closure
            .statements
    }
}

extension CodeBlockItemListSyntax {
    internal var functionCallExprItems: [FunctionCallExprSyntax] {
        compactMap { $0.item.as(FunctionCallExprSyntax.self) }
    }
    
    internal func functionCallExprItems<T: APIDecl>(mapping: (FunctionCallExprSyntax) -> T?) -> [T] {
        functionCallExprItems.compactMap { mapping($0) }
    }
}

internal struct ServerVariableDecl: Hashable {
    let name: String
    let type: String
    let defaultValue: String?
    let description: String?
    let expr: FunctionCallExprSyntax?
    
    static func parse(_ expr: FunctionCallExprSyntax) -> ServerVariableDecl? {
        guard expr.calledExpression.trimmedDescription == "Server.Variable",
              let name = expr.arguments.first?.expression.as(StringLiteralExprSyntax.self)?.representedLiteralValue,
                let type = expr.argument("type")?.expression.trimmedDescription
        else { return nil }
        
        return ServerVariableDecl(
            name: name,
            type: type,
            defaultValue: expr.argument("defaultValue")?.expression.trimmedDescription,
            description: expr.parseDescription(),
            expr: expr
        )
    }
}

