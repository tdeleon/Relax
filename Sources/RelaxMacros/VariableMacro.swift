//
//  VariableMacro.swift
//  Relax
//
//  Created by Thomas De Leon on 2/25/26.
//

import SwiftSyntax
import SwiftSyntaxMacros
import SwiftDiagnostics

package struct VariableMacro: ExpressionMacro {
    package static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) throws -> ExprSyntax {
        // Get name and type arguments
        guard let name = node.arguments.first?.expression.as(StringLiteralExprSyntax.self),
              let type = node.arguments.first(where: { $0.label?.text == "ofType" })?
            .expression.as(MemberAccessExprSyntax.self)
        else { return "()" }
        
        // Get the default value argument (if provided)
        let defaultValueExpr = node.arguments.first(where: { $0.label?.text == "defaultValue" })?.expression
        // Check that default values is a literal, otherwise diagnose
        if let defaultValueExpr {
            switch Syntax(defaultValueExpr).as(SyntaxEnum.self) {
            case .stringLiteralExpr, .integerLiteralExpr, .floatLiteralExpr, .booleanLiteralExpr, .memberAccessExpr:
                break
            default:
                let message = MacroExpansionErrorMessage("Default value must be a literal expression (i.e. \"prod\", 80, etc).")
                context.diagnose(Diagnostic(node: defaultValueExpr, message: message))
                return "()"
            }
        }
        
        // Get the description of the default value
        let defaultValue = defaultValueExpr?.description ?? "nil"
        
        // Get description argument
        let description = node.arguments.first(where: { $0.label?.text == "description" })?.expression.description ?? "nil"
        
        // Return the Variable init call expression
        return ExprSyntax("""
        ServerDescription.Variable(name: \(name), type: \(type), defaultValue: \(raw: defaultValue), description: \(raw: description))
        """
        )
    }
}
