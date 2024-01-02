//
//  APIServiceMacro.swift
//
//
//  Created by Thomas De Leon on 12/27/23.
//

import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftDiagnostics
import Foundation

public struct APIServiceMacro: ExtensionMacro {
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        guard let urlString = node
            .arguments?.as(LabeledExprListSyntax.self)?
            .first?.expression.as(StringLiteralExprSyntax.self)?
            .segments
            .first?.trimmedDescription else {
            let error = Diagnostic(node: node, message: RelaxMacroDiagnostic.invalidBaseURL)
            context.diagnose(error)
            return []
        }
        
        // check that the URL will be valid
        guard URL(string: urlString) != nil else {
            let error = Diagnostic(node: node, message: RelaxMacroDiagnostic.invalidBaseURL)
            context.diagnose(error)
            return []
        }
        
        let decl: DeclSyntax =
        """
        extension \(type.trimmed): APIComponent {
            static let baseURL: URL = URL(string: \"\(raw: urlString)\")!
        }
        """
        
        guard let extensionDecl = decl.as(ExtensionDeclSyntax.self) else {
            return []
        }
        return [extensionDecl]
    }
}
