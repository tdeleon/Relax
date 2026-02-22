//
//  ServerMacroTests.swift
//  Relax
//
//  Created by Thomas De Leon on 2/21/26.
//

import Foundation
import Testing
import SwiftSyntaxMacroExpansion
import SwiftSyntaxMacrosGenericTestSupport

@testable import RelaxMacros

struct ServerMacroTests {
    let macroSpec = ["Server": MacroSpec(type: ServerMacro.self)]
    
    let failureHandler: (TestFailureSpec) -> Void = { Issue.record($0) }
    
    @Test func `Standard template variables`() async throws {
        assertMacroExpansion(
            """
            @Server("https://{domain}{region}.example.com:{port}")
            public struct MyServer {
                enum Region: String {
                    case west
                    case east
                }
                let domain: String = "prod"
                let region = .west
                let port: Int
            }
            """,
            expandedSource:
            """
            public struct MyServer {
                enum Region: String {
                    case west
                    case east
                }
                let domain: String = "prod"
                let region = .west
                let port: Int
            }
            
            extension MyServer: Server {
                private static func __requireCSC<T>(_ value: T) where T: CustomStringConvertible {
                }
            
                public var url: URL {
                    Self.__requireCSC(domain)
                    Self.__requireCSC(region)
                    Self.__requireCSC(port)
            
                    return URL(string: "https://\\(domain)\\(region).example.com:\\(port)") ?? URL(string: "https://invalid.invalid")!
                }
            }
            """,
            macroSpecs: macroSpec,
            failureHandler: failureHandler
        )
    }
    
    @Test(arguments: ["open ", "public ", "package ", "internal ", "", "fileprivate ", "private "])
    func `Computed URL property access level matches the declaration`(level: String) async throws {
        assertMacroExpansion(
            """
            @Server("https://{domain}.example.com")
            \(level)struct MyServer {
                let domain: String = "prod"
            }
            """,
            expandedSource:
            """
            \(level)struct MyServer {
                let domain: String = "prod"
            }
            
            extension MyServer: Server {
                private static func __requireCSC<T>(_ value: T) where T: CustomStringConvertible {
                }
            
                \(level)var url: URL {
                    Self.__requireCSC(domain)
            
                    return URL(string: "https://\\(domain).example.com") ?? URL(string: "https://invalid.invalid")!
                }
            }
            """,
            macroSpecs: macroSpec,
            failureHandler: failureHandler
        )
    }
    
    @Test func `Properties not matching template variables should be ignored`() async throws {
        assertMacroExpansion(
            """
            @Server("https://{domain}.example.com")
            public struct MyServer {
                let domain: String = "prod"
                let port: Int
            }
            """,
            expandedSource:
            """
            public struct MyServer {
                let domain: String = "prod"
                let port: Int
            }
            
            extension MyServer: Server {
                private static func __requireCSC<T>(_ value: T) where T: CustomStringConvertible {
                }
            
                public var url: URL {
                    Self.__requireCSC(domain)
            
                    return URL(string: "https://\\(domain).example.com") ?? URL(string: "https://invalid.invalid")!
                }
            }
            """,
            macroSpecs: macroSpec,
            failureHandler: failureHandler
        )
    }
    
    @Test func `Template variables require a matching property`() async throws {
        assertMacroExpansion(
            """
            @Server("https://{domain}.example.com:{port}")
            public struct MyServer {
                let domain: String = "prod"
            }
            """,
            expandedSource:
            """
            public struct MyServer {
                let domain: String = "prod"
            }
            
            extension MyServer: Server {
                private static func __requireCSC<T>(_ value: T) where T: CustomStringConvertible {
                }
            
                public var url: URL {
                    Self.__requireCSC(domain)
            
                    return URL(string: "https://\\(domain).example.com:\\(port)") ?? URL(string: "https://invalid.invalid")!
                }
            }
            """,
            diagnostics: [
                DiagnosticSpec(
                    message: "Template placeholder variable 'port' must have a corresponding property with the same name.",
                    line: 1,
                    column: 9,
                    fixIts: [
                        FixItSpec(message: "Add property 'port'.")
                    ]
                )
            ],
            macroSpecs: macroSpec,
            failureHandler: failureHandler
        )
    }
    
    @Test func `Template variable with matching optional property is not allowed`() async throws {
        assertMacroExpansion(
            """
            @Server("https://{domain}.example.com:{port}")
            public struct MyServer {
                let domain: String?
            }
            """,
            expandedSource:
            """
            public struct MyServer {
                let domain: String?
            }
            
            extension MyServer: Server {
                private static func __requireCSC<T>(_ value: T) where T: CustomStringConvertible {
                }
            
                public var url: URL {
                    Self.__requireCSC(domain)
            
                    return URL(string: "https://\\(domain).example.com:\\(port)") ?? URL(string: "https://invalid.invalid")!
                }
            }
            """,
            diagnostics: [
                DiagnosticSpec(
                    message: "Properties backing template placeholder variables must not be optional.",
                    line: 3,
                    column: 17
                ),
                DiagnosticSpec(
                    message: "Template placeholder variable 'port' must have a corresponding property with the same name.",
                    line: 1,
                    column: 9,
                    fixIts: [
                        FixItSpec(message: "Add property 'port'.")
                    ]
                )
            ],
            macroSpecs: macroSpec,
            failureHandler: failureHandler
        )
    }
    
    @Test func `Duplicate template variables not allowed`() async throws {
        assertMacroExpansion(
            """
            @Server("https://{domain}{domain}.example.com:{port}")
            public struct MyServer {
                let domain: String = "prod"
                let port: Int
            }
            """,
            expandedSource:
            """
            public struct MyServer {
                let domain: String = "prod"
                let port: Int
            }
            """,
            diagnostics: [
                DiagnosticSpec(
                    message: "Template must not have duplicate placeholder variables.",
                    line: 1,
                    column: 9
                )
            ],
            macroSpecs: macroSpec,
            failureHandler: failureHandler
        )
    }
}
