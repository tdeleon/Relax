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

public struct APIEndpointMacro: ExtensionMacro {
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        guard let path = node
            .arguments?.as(LabeledExprListSyntax.self)?
            .first?.expression.as(StringLiteralExprSyntax.self)?
            .segments.trimmedDescription,
              !path.isEmpty
        else {
            let error = Diagnostic(node: node, message: RelaxMacroDiagnostic.invalidPath)
            context.diagnose(error)
            return []
        }
        guard let parent = node.attributeName.as(IdentifierTypeSyntax.self)?
            .genericArgumentClause?.as(GenericArgumentClauseSyntax.self)?
            .arguments
            .description else {
            let fixIt = FixIt.replace(
                message: RelaxFixItMessage.missingParent,
                oldNode: Syntax(node),
                newNode: FixItRewriter().visit(node)
            )
            let error = Diagnostic(node: node, message: RelaxMacroDiagnostic.missingParent, fixIt: fixIt)
            context.diagnose(error)

            return []
        }
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
    
    final private class FixItRewriter: SyntaxRewriter {
        override func visitAny(_ node: Syntax) -> Syntax? {
            guard let attributeName = node.as(IdentifierTypeSyntax.self),
                  attributeName.genericArgumentClause == nil
            else { return node }
            let listSyntax = GenericArgumentListSyntax {
                GenericArgumentSyntax(argument: TypeSyntax(stringLiteral: "<#APIComponent#>"))
            }
            let placeholder = GenericArgumentClauseSyntax(arguments: listSyntax)
            guard let genericDecl = placeholder.as(GenericArgumentClauseSyntax.self) else { return node }
            var newAttributeName = attributeName
            newAttributeName.genericArgumentClause = genericDecl
            return newAttributeName.as(Syntax.self)
        }
    }
}
