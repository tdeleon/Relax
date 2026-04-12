//
//  APIMacroTests.swift
//  Relax
//
//  Created by Thomas De Leon on 4/7/26.
//

import Testing
import SwiftSyntaxMacros
import SwiftSyntaxMacroExpansion
import SwiftSyntaxMacrosGenericTestSupport
#if canImport(RelaxMacros)
@testable import RelaxMacros
#endif

struct APIMacroTests {

    let macroSpec = ["API": MacroSpec(type: APIMacro.self)]
    
    let failureHandler: (TestFailureSpec) -> Void = { Issue.record($0) }
    
    @Test func test() async throws {
        assertMacroExpansion(
            """
            @API
            struct MyAPI {
                var servers: [Server] {
                    Server("Prod", url: "https://stage.example.com", description: "Staging server") {
                        Server.Variable("region", type: Region.self, defaultValue: .east, description: "The server region")
                    }
                    Server("Stage", url: "https://stage.example.com")
                }
                
                var security: [SecurityScheme] {
                    SecurityScheme.apiKey("key", in: .header) {
                        "An api key"
                    }
                    SecurityScheme.http(.basic) {
                        "An http basic scheme"
                    }
                    SecurityScheme.oauth2(metadataURL: "https://oauth.example.com/metadata") {
                        OAuthFlow.password(tokenURL: "https://oauth.example.com/token")
                    } description: {
                        "A custom OAuth2 scheme"
                    }
                }
                
                var paths: [Path] {
                    Path("/users") {
                        
                    }
                }
            }
            """,
            expandedSource:
            """
            struct MyAPI {
                var servers: [Server] {
                    Server("Prod", url: "https://stage.example.com", description: "Staging server") {
                        Server.Variable("region", type: Region.self, defaultValue: .east, description: "The server region")
                    }
                    Server("Stage", url: "https://stage.example.com")
                }
                
                var security: [SecurityScheme] {
                    SecurityScheme.apiKey("key", in: .header) {
                        "An api key"
                    }
                    SecurityScheme.http(.basic) {
                        "An http basic scheme"
                    }
                    SecurityScheme.oauth2(metadataURL: "https://oauth.example.com/metadata") {
                        OAuthFlow.password(tokenURL: "https://oauth.example.com/token")
                    } description: {
                        "A custom OAuth2 scheme"
                    }                
                }
                
                var paths: [Path] {
                    Path("/users") {
                        
                    }
                }
            }
            """,
            macroSpecs: macroSpec,
            failureHandler: failureHandler
        )
    }
}
