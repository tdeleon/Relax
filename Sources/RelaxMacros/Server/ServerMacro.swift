//
//  ServerMacro.swift
//  RelaxMacros
//
//  Created by Thomas De Leon on 2/12/26.
//

import Foundation
import SwiftSyntax
import SwiftSyntaxMacros

package struct ServerMacro: ExtensionMacro {
    package static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        
        guard case let .argumentList(arguments) = node.arguments,
              let templateArgument = arguments.first,
              let template = templateArgument
            .expression.as(StringLiteralExprSyntax.self)?
            .segments.first?.as(StringSegmentSyntax.self)?
            .content.text
        else { return [] }
            
        // get placeholders
        let placeholders = template.matches(of: /([^{]+(?=}))/).map { String($0.output.1) }
        
        guard placeholders.count == Set(placeholders).count else {
            context.diagnose(Diagnostics.duplicateTemplateVariables(template: templateArgument, context: context))
            return []
        }
        
        // get properties
        let properties = properties(for: declaration)
            .filter { property in
                // filter out any properties that are not in the template
                placeholders.contains { $0 == property.name.text }
            }
        
        // check that all template placeholders have a matching, non-optional property
        placeholders.forEach { placeholder in
            validate(
                placeholder,
                against: properties,
                templateArgument: templateArgument,
                declaration: declaration,
                context: context
            )
        }
        
        // convert the template to an interpolated string
        let interpolatedTemplate = convertTemplateToInterpolated(template)
        
        // get the top level access level
        let accessLevel = accessLevel(for: declaration)
        
        // create calls for each property to check CustomStringConvertible conformance
        let propertyCheckCalls = properties.map { property in
            "Self.__requireCSC(\(property.name.text))"
        }.joined(separator: "\n")
        
        // generate the extension
        let decl: DeclSyntax = """
            extension \(type.trimmed): Server {
                private static func __requireCSC<T>(_ value: T) where T: CustomStringConvertible {}
            
                \(raw: accessLevel)var url: URL {
                    \(raw: propertyCheckCalls)
                    
                    return URL(string: \"\(raw: interpolatedTemplate)\") ?? URL(string: "https://invalid.invalid")!
                }
            }
            """
        
        guard let extensionDecl = decl.as(ExtensionDeclSyntax.self) else { return [] }
        
        return [extensionDecl]
    }
    
    private static func properties(for declaration: some DeclGroupSyntax) -> [(name: TokenSyntax, type: TypeSyntax?, defaultExpr: ExprSyntax?)] {
        declaration.memberBlock.members
            .compactMap { $0.decl.as(VariableDeclSyntax.self) }
            .flatMap {
                $0.bindings.compactMap {
                    guard $0.accessorBlock == nil,
                          let identifier = $0.pattern.as(IdentifierPatternSyntax.self)?.identifier
                    else { return nil }
                    return (identifier, $0.typeAnnotation?.type, $0.initializer?.value)
                }
            }
    }
    
    private static func accessLevel(for declaration: some DeclGroupSyntax) -> String {
        let found = declaration.modifiers.first { modifier in
            guard case let .keyword(keyword) = modifier.name.tokenKind else { return false }
            switch keyword {
            case .open, .public, .package, .internal, .fileprivate, .private:
                return true
            default:
                return false
            }
        }
        return found?.name.text.appending(" ") ?? ""
    }
    
    private static func convertTemplateToInterpolated(_ template: String) -> String {
        template.replacing(/\{([^}]+)\}/) { "\\(\($0.output.1))" }
    }
    
    private static func validate(
        _ placeholder: String,
        against properties: [(name: TokenSyntax, type: TypeSyntax?, defaultExpr: ExprSyntax?)],
        templateArgument: LabeledExprListSyntax.Element,
        declaration: some DeclGroupSyntax,
        context: MacroExpansionContext
    ) {
        guard let matching = properties.first(where: { $0.name.text == placeholder }) else {
            context.diagnose(
                Diagnostics.missingProperty(
                    placeholder,
                    at: templateArgument,
                    declaration: declaration,
                    context: context
                )
            )
            return
        }
        
        // Check that property is non-optional
        if let type = matching.type, type.as(OptionalTypeSyntax.self) != nil {
            context.diagnose(Diagnostics.optionalPropertyNotAllowed(type: type, context: context))
            return
        }
    }
}
