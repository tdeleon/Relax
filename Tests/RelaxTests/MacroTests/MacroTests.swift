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
                static let baseURL: URL = URL(string: "https://example.com/")!
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
}
