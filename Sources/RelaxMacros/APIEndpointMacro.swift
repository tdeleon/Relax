//
//  File.swift
//  
//
//  Created by Thomas De Leon on 1/3/24.
//

import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftDiagnostics

package struct APIEndpointMacro: ExtensionMacro {
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        
        // Get the parent generic argument
        guard let parent = node.attributeName.as(IdentifierTypeSyntax.self)?
            .genericArgumentClause?.as(GenericArgumentClauseSyntax.self)?
            .arguments
            .description else {
            return []
        }
        
        // Get path parameter argument
        guard let path = node
            .arguments?.as(LabeledExprListSyntax.self)?
            .first?.expression.as(StringLiteralExprSyntax.self)?
            .segments.trimmedDescription
        else {
            // The public declaration requires this parameter so it will never be empty; no need to diagnose an error
            return []
        }
        
        // Check that the path isn't empty
        guard !(path.trimmingCharacters(in: .whitespacesAndNewlines)).isEmpty else {
            // The path is empty- diagnose an error
            let error = Diagnostic(node: node, message: RelaxMacroDiagnostic.invalidPath)
            context.diagnose(error)
            return []
        }
        
        // Define the output extension
        let decl: DeclSyntax =
        """
        extension \(type.trimmed): Endpoint {
            typealias Parent = \(raw: parent)
            static let path: String = \"\(raw: path)\"
        }
        """
        
        guard let extensionDecl = decl.as(ExtensionDeclSyntax.self) else { return [] }
        
        return [extensionDecl]
    }
}
