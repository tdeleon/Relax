//
//  MacroTests.swift
//  
//
//  Created by Thomas De Leon on 12/27/23.
//

import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

#if canImport(RelaxMacros)
import RelaxMacros
let testMacros: [String: Macro.Type] = [
    "Service": RestAPIMacro.self
]
#endif

final class MacroTests: XCTestCase {
    func testRestAPIWithBaseURL() throws {
        #if canImport(RelaxMacros)
        assertMacroExpansion(
            """
            @RestAPI("https://example.com/")
            enum TestService {
            }
            """,
            expandedSource: """
            enum TestService {

                static let baseURL: URL = URL(string: "https://example.com/")!
            }

            extension TestService: APIComponent {
            }
            """,
            macros: ["RestAPI": RestAPIURLMacro.self])
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func testRestAPI() throws {
        #if canImport(RelaxMacros)
        assertMacroExpansion(
            """
            @RestAPI
            enum TestService {
            }
            """,
            expandedSource: """
            enum TestService {
            }
            
            extension TestService: APIComponent {
            }
            """,
            macros: ["RestAPI": RestAPIMacro.self])
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
}
