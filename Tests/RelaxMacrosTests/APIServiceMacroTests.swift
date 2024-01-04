//
//  APIServiceMacroTests.swift
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

final class APIServiceMacroTests: XCTestCase {
    #if canImport(RelaxMacros)
    let testMacros: [String: Macro.Type] = [
        "APIService": APIServiceMacro.self
    ]
    #endif
    
    func testValid() throws {
        #if canImport(RelaxMacros)
        assertMacroExpansion(
            """
            @APIService("https://example.com/")
            enum TestService {
            }
            """,
            expandedSource: """
            enum TestService {
            }
            
            extension TestService: APIComponent {
                static let baseURL: URL = URL(string: "https://example.com/")!
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func testInvalidURL() throws {
        #if canImport(RelaxMacros)
        assertMacroExpansion(
            """
            @APIService("https:// .com")
            enum TestService {
            }
            """,
            expandedSource: """
            enum TestService {
            }
            """,
            diagnostics: [.init(message: RelaxMacroDiagnostic.invalidBaseURL.message, line: 1, column: 1)],
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
}
