//
//  MacroTests.swift
//  
//
//  Created by Thomas De Leon on 12/27/23.
//

import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

#if !os(Windows) // Macro tests do not currently compile on windows https://github.com/apple/swift/issues/69302
#if canImport(RelaxMacros)
import RelaxMacros
let testMacros: [String: Macro.Type] = [
    "APIService": APIServiceMacro.self
]
#endif

final class MacroTests: XCTestCase {    
    func testRestAPI() throws {
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
}
#endif
