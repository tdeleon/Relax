//
//  RestAPIMacro.swift
//
//
//  Created by Thomas De Leon on 12/27/23.
//

import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct RestAPIURLMacro: ExtensionMacro {
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        let decl: DeclSyntax =
        """
        extension \(type.trimmed): APIComponent {}
        """
        
        guard let extensionDecl = decl.as(ExtensionDeclSyntax.self) else {
            return []
        }
        return [extensionDecl]
    }
}

extension RestAPIURLMacro: MemberMacro {
    public static func expansion(
        of node: SwiftSyntax.AttributeSyntax,
        providingMembersOf declaration: some SwiftSyntax.DeclGroupSyntax,
        in context: some SwiftSyntaxMacros.MacroExpansionContext
    ) throws -> [SwiftSyntax.DeclSyntax] {
        guard let arguments = node.arguments?.as(LabeledExprListSyntax.self) else {
            return []
        }
        let decl: DeclSyntax =
        """
        static let baseURL: URL = URL(string: \(raw: arguments.trimmedDescription))!
        """
        return [decl]
    }
}

public struct RestAPIMacro: ExtensionMacro {
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        let decl: DeclSyntax =
        """
        extension \(type.trimmed): APIComponent {}
        """
        
        guard let extensionDecl = decl.as(ExtensionDeclSyntax.self) else {
            return []
        }
        return [extensionDecl]
    }
}
