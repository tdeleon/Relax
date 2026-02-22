//
//  ServerMacro+Diagnostics.swift
//  Relax
//
//  Created by Thomas De Leon on 2/21/26.
//

import Foundation
import SwiftSyntax
import SwiftSyntaxMacros
import SwiftDiagnostics


extension ServerMacro {
    static let domain = String(describing: ServerMacro.self)
    
    enum Diagnostics {
        /// Diagnostic for when a template placeholder variable is missing a matching property
        static func missingProperty(
            _ placeholder: String,
            at node: SyntaxProtocol,
            declaration: some DeclGroupSyntax,
            context: MacroExpansionContext
        ) -> Diagnostic {
            let message = MacroExpansionErrorMessage(
                "Template placeholder variable '\(placeholder)' must have a corresponding property with the same name."
            )
            
            if let newNode = addMissingPropertyMemberBlock(placeholder, for: declaration) {
                let fixIt = FixIt(
                    message: MacroExpansionFixItMessage("Add property '\(placeholder)'."),
                    changes: [FixIt.Change.replace(oldNode: Syntax(declaration.memberBlock), newNode: Syntax(newNode))])
                return Diagnostic(
                    node: node,
                    message: message,
                    fixIt: fixIt)
            } else {
                return Diagnostic(
                    node: node,
                    message: message
                )
            }
        }
        
        /// Diagnostic for optional properties exist which match template placeholder variables
        static func optionalPropertyNotAllowed(type: TypeSyntax, context: MacroExpansionContext) -> Diagnostic {
            Diagnostic(
                node: type,
                message: MacroExpansionErrorMessage(
                    "Properties backing template placeholder variables must not be optional."
                )
            )
        }
        
        /// Diagnostic for when template contains duplicate placeholder variables
        static func duplicateTemplateVariables(
            template: LabeledExprListSyntax.Element,
            context: MacroExpansionContext
        ) -> Diagnostic {
            Diagnostic(
                node: template,
                message: MacroExpansionErrorMessage("Template must not have duplicate placeholder variables.")
            )
        }
        
        /// Create syntax for FixIt to add missing property
        private static func addMissingPropertyMemberBlock(
            _ name: String,
            for declaration: some DeclGroupSyntax
        ) -> MemberBlockSyntax? {
            let propertyDeclaration = DeclSyntax(
                """
                let \(raw: name): String
                """
            )
                .with(\.leadingTrivia, Trivia(pieces: [.newlines(1), .spaces(4)]))
                .with(\.trailingTrivia, Trivia(pieces: [.newlines(1)]))
            
            let newMemberItem = MemberBlockItemSyntax(decl: propertyDeclaration)
            var newMembers = declaration.memberBlock.members
            newMembers.append(newMemberItem)

            return MemberBlockSyntax(
                leftBrace: declaration.memberBlock.leftBrace,
                members: newMembers,
                rightBrace: declaration.memberBlock.rightBrace
            )
        }
    }
}
