//
//  ServerMacro+ExpressionMacro.swift
//  Relax
//
//  Created by Thomas De Leon on 2/22/26.
//

import Foundation
import SwiftSyntax
import SwiftSyntaxMacros

extension ServerMacro: ExpressionMacro {
    package static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) throws -> SwiftSyntax.ExprSyntax {
        // get name (required)
        // get url template (required)
        // get description
        // get arguments
        
        guard let name = node.arguments.first(where: { $0.label?.text == "name" }) else {
            return ""
        }
        guard let urlTemplate = node.arguments.first(where: { $0.label?.text == "url" }) else {
            return ""
        }
        
        let description = node.arguments.first(where: { $0.label?.text == "description" })
        
        return ExprSyntax(
            """
            ServerDefinition("\(name)", url: \(urlTemplate), description:
            """
        )
    }
}
