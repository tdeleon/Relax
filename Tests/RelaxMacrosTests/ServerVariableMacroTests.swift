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

extension Issue {
    @discardableResult static func record(_ failure: TestFailureSpec) -> Self {
        record(
            Comment(rawValue: failure.message),
            sourceLocation: SourceLocation(
                fileID: failure.location.fileID,
                filePath: failure.location.filePath,
                line: failure.location.line,
                column: failure.location.column
            )
        )
    }
}

struct ServerVariableMacroTests {
    let macroSpec = ["ServerVariable": MacroSpec(type: ServerVariableMacro.self)]
    
    let failureHandler: (TestFailureSpec) -> Void = { Issue.record($0) }
    
    typealias ValidType = ServerVariableMacro.ValidType
    
    @Test(arguments: ValidType.types)
    func `Known property type`(type: String) async throws {
        assertMacroExpansion(
            """
            @ServerVariable var domain: \(type)
            """,
            expandedSource:
            """
            var domain: \(type)
            """,
            macroSpecs: macroSpec,
            failureHandler: failureHandler
        )
    }
    
    @Test(arguments: ValidType.types)
    func `Optional known property type`(type: String) async throws {
        assertMacroExpansion(
            """
            @ServerVariable var domain: \(type)?
            """,
            expandedSource:
            """
            var domain: \(type)?
            """,
            macroSpecs: macroSpec,
            failureHandler: failureHandler
        )
    }
    
    @Test(arguments: [
        (ValidType.string, "\"staging\""),
        (ValidType.integer, "42"),
        (ValidType.float, "3.14"),
        (ValidType.double, "2.718"),
        (ValidType.boolean, "true")
    ])
    func `Known property type with default value`(type: String, defaultValue: String) async throws {
        assertMacroExpansion(
            """
            @ServerVariable(default: \(defaultValue)) var domain: \(type)
            """,
            expandedSource:
            """
            var domain: \(type)
            """,
            macroSpecs: macroSpec,
            failureHandler: failureHandler
        )
    }
    
    @Test func `Unknown property type`() async throws {
        assertMacroExpansion(
            """
            @ServerVariable var domain: MyType
            """,
            expandedSource:
            """
            var domain: MyType
            
            private struct __macro_local_23ServerVariableTypeCheckfMu_<T: CustomStringConvertible> {
            }
            
            private typealias __macro_local_6domainfMu__TypeCheck = __macro_local_23ServerVariableTypeCheckfMu_<MyType>
            """,
            macroSpecs: macroSpec,
            failureHandler: failureHandler
        )
    }
    
    @Test func `Unknown property type with default argument`() async throws {
        assertMacroExpansion(
            """
            @ServerVariable(default: UUID()) var domain: UUID
            """,
            expandedSource:
            """
            var domain: UUID
            
            private struct __macro_local_23ServerVariableTypeCheckfMu_<T: CustomStringConvertible> {
            }
            
            private typealias __macro_local_6domainfMu__TypeCheck = __macro_local_23ServerVariableTypeCheckfMu_<UUID>
            
            private let __macro_local_16defaultTypeCheckfMu_: Void = {
                _ = UUID() as UUID
            }()
            """,
            macroSpecs: macroSpec,
            failureHandler: failureHandler
        )
    }
    
    @Test(arguments: [
        (ValidType.string, "123"),
        (ValidType.integer, "\"staging\""),
        (ValidType.float, "\"staging\""),
        (ValidType.double, "\"staging\""),
        (ValidType.boolean, "1")
    ])
    func `Default argument mis-matched type`(type: String, defaultValue: String) async throws {
        assertMacroExpansion(
            """
            @ServerVariable(default: \(defaultValue) var domain: \(type)?
            """,
            expandedSource:
            """
            var domain: \(type)?
            """,
            diagnostics: [
                DiagnosticSpec(
                    message: "Default value type must match property type '\(type)'.",
                    line: 1,
                    column: 26,
                    severity: .error
                )
            ],
            macroSpecs: macroSpec,
            failureHandler: failureHandler
        )
    }
    
    @Test func `Default argument mis-matched type for unknown property type`() async throws {
        assertMacroExpansion(
            """
            @ServerVariable(default: 123) var domain: UUID?
            """,
            expandedSource:
            """
            var domain: UUID?
            
            private struct __macro_local_23ServerVariableTypeCheckfMu_<T: CustomStringConvertible> {
            }
            
            private typealias __macro_local_6domainfMu__TypeCheck = __macro_local_23ServerVariableTypeCheckfMu_<UUID?>
            """,
            diagnostics: [
                DiagnosticSpec(
                    message: "Default value type must match property type 'UUID'.",
                    line: 1,
                    column: 26,
                    severity: .error,
                )
            ],
            macroSpecs: macroSpec,
            failureHandler: failureHandler
        )
    }
}
