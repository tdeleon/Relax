//
//  ServerVariableMacroTests.swift
//  Relax
//
//  Created by Thomas De Leon on 2/6/26.
//

import Testing
import SwiftSyntaxMacros
import SwiftSyntaxMacroExpansion
import SwiftSyntaxMacrosGenericTestSupport
#if canImport(RelaxMacros)
@testable import RelaxMacros
#endif

struct VariableMacroTests {
    let macroSpec = ["Variable": MacroSpec(type: VariableMacro.self)]
    
    let failureHandler: (TestFailureSpec) -> Void = { Issue.record($0) }
        
    @Test(arguments: [
        ("String", "\"prod\""),
        ("Int", "80"),
        ("Float", "3.1"),
        ("Double", "3.1"),
        ("Bool", "true"),
        ("Region", ".west"),
        ("Region", "Region.east")
    ])
    func `Normal macro expansion`(type: Any, defaultValue: String) async throws {
        assertMacroExpansion(
            """
            #Variable(\"prod\", ofType: \(type).self, defaultValue: \(defaultValue), description: "a description")
            """,
            expandedSource:
            """
            ServerDescription.Variable(name: "prod", type: \(type).self, defaultValue: \(defaultValue), description: "a description")
            """,
            macroSpecs: macroSpec,
            failureHandler: failureHandler
        )
        
        assertMacroExpansion(
            """
            #Variable(\"prod\", ofType: \(type).self, description: "a description")
            """,
            expandedSource:
            """
            ServerDescription.Variable(name: "prod", type: \(type).self, defaultValue: nil, description: "a description")
            """,
            macroSpecs: macroSpec,
            failureHandler: failureHandler
        )
        
        assertMacroExpansion(
            """
            #Variable(\"prod\", ofType: \(type).self, defaultValue: \(defaultValue))
            """,
            expandedSource:
            """
            ServerDescription.Variable(name: "prod", type: \(type).self, defaultValue: \(defaultValue), description: nil)
            """,
            macroSpecs: macroSpec,
            failureHandler: failureHandler
        )
    }
    
    @Test func `Non-literal default values should return a diagnostic`() async throws {
        assertMacroExpansion(
            """
            #Variable(\"prod\", ofType: String.self, defaultValue: nonLiteral, description: "a description")
            """,
            expandedSource:
            """
            ()
            """,
            diagnostics: [
                DiagnosticSpec(
                    message: "Default value must be a literal expression (i.e. \"prod\", 80, etc).",
                    line: 1,
                    column: 54,
                    severity: .error,
                )
            ],
            macroSpecs: macroSpec,
            failureHandler: failureHandler
        )
    }
}
