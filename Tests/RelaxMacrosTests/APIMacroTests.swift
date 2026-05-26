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
    
    @Test(.disabled()) func test() async throws {
        assertMacroExpansion(
            """
            @API
            struct MyAPI {
                var servers: [Server] {
                    Server("Prod", url: "https://{region}.example.com", description: "Staging server") {
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
                
                var endpoints: [Endpoint] {
                    Endpoint("/users/{id}", summary: "User path") {
                        Path.Operation(.get) {
                            Response(.code(500), summary: "Summary") {
                                Response.Content.jsonDictionary()
                                Response.Content.text(.utf8)
                                Response.Content(.applicationJSON, payload: .json(String.self))
                            } description: {
                                "An error response returning a JSON dictionary"
                            }
                        }
                    } parameters: {
                        Parameter.cookie("Cookie", valueType: Int.self, description: "Description", required: true)
                        Parameter.header("Header", valueType: String.self, description: "Description", required: true)
                        Parameter.path("Path", ofType: Int.self, style: .label, description: "Description")
                        Parameter.query("QueryObject", ofObjectType: String.self, style: .deepObject, description: "Description", required: true)
                        Parameter.query("Query", ofType: Int.self, style: .deepObject, description: "Description", required: true)
                        Parameter.queryString("Query", contentType: .applicationFormURLEncoded, description: "Description", required: true)
                    } tags: {
                        Tag("nav", summary: "summary") {
                            "Description of the nav tag"
                        }
                        "tag2"
                    } description: {
                        "A longer description of the /users/{id} path."
                    }
                }
            }
            """,
            expandedSource:
            """
            struct MyAPI {
                var servers: [Server] {
                    Server("Prod", url: "https://{region}.example.com", description: "Staging server") {
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
                
                var endpoints: [Endpoint] {
                    Endpoint("/users/{id}", summary: "User path") {
                        Endpoint.Operation(.get) {
                            Response(.code(500), summary: "Summary") {
                                Response.Content.jsonDictionary()
                                Response.Content.text(.utf8)
                                Response.Content(.applicationJSON, payload: .json(String.self))
                            } description: {
                                "An error response returning a JSON dictionary"
                            }
                        }
                    } parameters: {
                        Parameter("id", ofType: Int.self, in: .path, description: "Description", required: true)
                        Parameter.cookie("Cookie", valueType: Int.self, description: "Description", required: true)
                        Parameter.header("Header", valueType: String.self, description: "Description", required: true)
                        Parameter.path("Path", ofType: Int.self, style: .label, description: "Description")
                        Parameter.query("QueryObject", ofObjectType: String.self, style: .deepObject, description: "Description", required: true)
                        Parameter.query("Query", ofType: Int.self, style: .deepObject, description: "Description", required: true)
                        Parameter.queryString("Query", contentType: .applicationFormURLEncoded, description: "Description", required: true)
                    } tags: {
                        Tag("nav", summary: "summary") {
                            "Description of the nav tag"
                        }
                        "tag2"
                    } description: {
                        "A longer description of the /users/{id} path."
                    }
                }
            }
            """,
            macroSpecs: macroSpec,
            failureHandler: failureHandler
        )
    }
}
