//
//  APIMacro.swift
//  Relax
//
//  Created by Thomas De Leon on 4/1/26.
//

import Foundation

import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftDiagnostics

package struct APIMacro: ExtensionMacro {
    package static func expansion(
        of node: SwiftSyntax.AttributeSyntax,
        attachedTo declaration: some SwiftSyntax.DeclGroupSyntax,
        providingExtensionsOf type: some SwiftSyntax.TypeSyntaxProtocol,
        conformingTo protocols: [SwiftSyntax.TypeSyntax],
        in context: some SwiftSyntaxMacros.MacroExpansionContext
    ) throws -> [SwiftSyntax.ExtensionDeclSyntax] {
        // TOP LEVEL
        // parse name
        //declaration.as(StructDeclSyntax.self)?.name.identifier?.name = "MyAPI"
        //declaration.identifier.text
        let declarationName = declaration.as(StructDeclSyntax.self)?.name.identifier?.name
        
        // decl list
        // declaration.memberBlock.members.compactMap { $0.decl.as(VariableDeclSyntax.self) }
        let members = declaration.memberBlock.members.compactMap { $0.decl.as(VariableDeclSyntax.self) }
        
        // parse servers
//        let serverDecl = members.first { member in
//            member.bindings.first { binding in
//                binding.pattern.as(IdentifierPatternSyntax.self)?.identifier.text == "servers" &&
//                binding.typeAnnotation?.type.as(ArrayTypeSyntax.self)?.element.as(IdentifierTypeSyntax.self)?.name.text == "Server"
//            } != nil
//        }
        
        let servers = parseServers(members, in: context)
        
        // parse security
        let securityFunctionCallExpr = parseComputedResultBuilder(members, identifier: "security", type: "SecurityScheme")

        
        // parse paths
        let pathsFunctionCallExpr = parseComputedResultBuilder(members, identifier: "paths", type: "Path")
        
        return []
    }
    
    internal static func parseComputedResultBuilder(_ variableMembers: [VariableDeclSyntax], identifier: String, type: String) -> (expr: CodeBlockItemListSyntax, lines: [FunctionCallExprSyntax])? {
        let pattern = variableMembers.compactMap { decl in
            decl.bindings.first { binding in
                binding.pattern.as(IdentifierPatternSyntax.self)?.identifier.text == identifier &&
                binding.typeAnnotation?.type.as(ArrayTypeSyntax.self)?.element.as(IdentifierTypeSyntax.self)?.name.text == type
            }
        }.first
        
        let closure = pattern?.accessorBlock?.accessors.as(CodeBlockItemListSyntax.self)
        let items = closure?.compactMap {
            $0.item.as(FunctionCallExprSyntax.self)
        }
        
        guard let closure, let items else { return nil }
        
        return (closure, items)
    }
    
    internal static func parseServers(_ members: [VariableDeclSyntax], in context: MacroExpansionContext) -> [ServerDecl] {
        var servers = [ServerDecl]()
        guard let functionCallExpr = parseComputedResultBuilder(members, identifier: "servers", type: "Server") else {
            //TODO: Diagnose missing servers
            return []
        }
        
        functionCallExpr.lines.forEach {
            guard let server = ServerDecl.parse($0, in: context) else { return }
            servers.append(server)
        }
        
        if servers.isEmpty {
            context.diagnose(
                Diagnostic(node: functionCallExpr.expr, message: MacroExpansionErrorMessage("At least one Server is required."))
            )
        }
        
        return servers
    }
}

extension FunctionCallExprSyntax {
    func argument(_ name: String) -> LabeledExprListSyntax.Element? {
        arguments.first { $0.label?.text == name }
    }
}
