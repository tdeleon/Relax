//
//  ServerVariable.swift
//  Relax
//
//  Created by Thomas De Leon on 2/6/26.
//

import SwiftSyntax
import SwiftSyntaxMacros
import SwiftSyntaxBuilder
import SwiftDiagnostics


package struct ServerVariableMacro: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let variableDeclaration = declaration.as(VariableDeclSyntax.self),
              let binding = variableDeclaration.bindings.first,
              let propertyType = binding.typeAnnotation?.type,
              let propertyTypeBase = propertyType.baseName,
              let propertyName = binding.pattern.firstToken(viewMode: .sourceAccurate)?.text
        else { return [] }
        
        var declarations = [DeclSyntax]()
        
        // check property type
        if !ValidType.isValid(propertyTypeBase) {
            // for other types, add a struct/typealias to check at compile time
            declarations.append(contentsOf: propertyTypeCheck(for: propertyName, type: propertyType, in: context))
        }
        
        if case let .argumentList(arguments) = node.arguments,
           let defaultArgument = arguments.first(where: { $0.label?.text == "default" }) {
            // for known types, check that the default argument matches the property type
            if let matching = matching(defaultArgument.expression, expected: propertyTypeBase) {
                if !matching {
                    // known type that doesn't match property type
                    diagnoseTypeMismatch(defaultArgument, expected: propertyTypeBase, in: context)
                }
            } else {
                // if other type, use compile time check
                declarations.append(
                    defaultArgumentTypeCheck(for: defaultArgument.expression, propertyType: propertyType, in: context)
                )
            }
        }
        
        return declarations
    }
    
    enum ValidType {
        static let string = "String"
        static let integer = "Int"
        static let float = "Float"
        static let double = "Double"
        static let boolean = "Bool"
        
        static func isValid(_ type: String?) -> Bool {
            types.contains { $0 == type }
        }
        
        static let types = [Self.string, Self.integer, Self.float, Self.double, Self.boolean]
    }
    
    private static func propertyTypeCheck(
        for name: String,
        type: TypeSyntax,
        in context: MacroExpansionContext
    ) -> [DeclSyntax] {
        let structName = context.makeUniqueName("ServerVariableTypeCheck")
        return [
            DeclSyntax("private struct \(structName)<T: CustomStringConvertible> {}"),
            DeclSyntax("private typealias \(context.makeUniqueName(name))_TypeCheck = \(structName)<\(type)>")
        ]
    }
    
    private static func defaultArgumentTypeCheck(
        for defaultArgument: ExprSyntax,
        propertyType: TypeSyntax,
        in context: MacroExpansionContext
    ) -> DeclSyntax {
        DeclSyntax(
            """
            private let \(context.makeUniqueName("defaultTypeCheck")): Void = {
                _ = \(defaultArgument) as \(propertyType)
            }()
            """
        )
    }
    
    private static func matching(_ exprType: ExprSyntax, expected: String) -> Bool? {
        switch Syntax(exprType).as(SyntaxEnum.self) {
        case .stringLiteralExpr: expected == ValidType.string
        case .integerLiteralExpr: expected == ValidType.integer
        case .floatLiteralExpr: expected == ValidType.float || expected == ValidType.double
        case .booleanLiteralExpr: expected == ValidType.boolean
        default: nil
        }
    }
    
    private static func diagnoseTypeMismatch(
        _ element: LabeledExprListSyntax.Element,
        expected: String,
        in context: MacroExpansionContext
    ) {
        context.diagnose(
            Diagnostic(
                node: Syntax(element.expression),
                message: DefaultTypeMismatchMessage(expectedType: expected)
            )
        )
    }
}

extension TypeSyntax {
    var baseName: String? {
        if let identifierType = self.as(IdentifierTypeSyntax.self) {
            return identifierType.name.text
        } else if let optionalType = self.as(OptionalTypeSyntax.self) {
            return optionalType.wrappedType.as(IdentifierTypeSyntax.self)?.name.text
        } else {
            return nil
        }
    }
}

extension ServerVariableMacro {
    struct DefaultTypeMismatchMessage: DiagnosticMessage {
        let expectedType: String

        var diagnosticID: SwiftDiagnostics.MessageID {
            .init(domain: "ServerVariableMacro", id: "default_value_type_mismatch")
        }
        let severity: SwiftDiagnostics.DiagnosticSeverity = .error
        
        var message: String {
            "Default value type must match property type '\(expectedType)'."
        }
    }
}
