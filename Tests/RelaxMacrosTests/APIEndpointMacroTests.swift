//
//  APIEndpointMacroTests.swift
//
//
//  Created by Thomas De Leon on 12/27/23.
//

import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest
#if canImport(RelaxMacros)
@testable import RelaxMacros
#endif

final class APIEndpointMacroTests: XCTestCase {
    #if canImport(RelaxMacros)
    let testMacros: [String: Macro.Type] = [
        "APIEndpoint": APIEndpointMacro.self
    ]
    #endif
    func testAPIEndpoint() throws {
        #if canImport(RelaxMacros)
        assertMacroExpansion(
            """
            @APIEndpoint<MyService>("path")
            enum TestService {
            }
            """,
            expandedSource: """
            enum TestService {
            }
            
            extension TestService: Endpoint {
                typealias Parent = MyService
                static let path: String = "path"
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func testAPIEndpointNoParent() throws {
        #if canImport(RelaxMacros)
        assertMacroExpansion(
            """
            @APIEndpoint("path")
            enum TestService {
            }
            """,
            expandedSource: """
            enum TestService {
            }
            """,
            diagnostics: [
                DiagnosticSpec(
                    message: RelaxMacroDiagnostic.missingParent.message,
                    line: 1,
                    column: 1,
                    fixIts: [
                        FixItSpec(message: RelaxFixItMessage.missingParent.message)
                    ]
                )
            ],
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func testAPIEndpointInvalidPath() throws {
        #if canImport(RelaxMacros)
        assertMacroExpansion(
            """
            @APIEndpoint<Parent>("")
            enum TestService {
            }
            """,
            expandedSource: """
            enum TestService {
            }
            """,
            diagnostics: [.init(message: RelaxMacroDiagnostic.invalidPath.message, line: 1, column: 1)],
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
}

