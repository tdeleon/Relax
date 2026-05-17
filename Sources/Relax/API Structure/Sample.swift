//
//  Sample.swift
//  Relax
//
//  Created by Thomas De Leon on 4/1/26.
//

import Foundation

struct User: Codable {
    let name: String
}

struct UserError: Codable {
    let error: String
}

extension Tag {
    static let nav = Tag("nav")
}

@API
struct MyAPI: API {
    static let name = ""
    public enum Region: String {
        case east
        case west
    }
    var servers: [Server] {
        Server("Prod", url: "https://prod.example.com")
        Server("Stage", url: "https://stage.example.com", description: "Staging server")
        Server("Regional", url: "https://{region}.example.com", description: "Regional server") {
            Server.Variable("region", type: Region.self, defaultValue: .east, description: "The region to use")
        }
    }
    
    var security: [SecurityScheme] {
        SecurityScheme.http(.basic)
        SecurityScheme.oauth2(metadataURL: "https://oauth.example.com/metadata") {
            OAuthFlow.password(tokenURL: "https://oauth.example.com/token")
        } description: {
            "A custom OAuth2 scheme"
        }
    }
    
    struct ErrorResponse: Codable, Sendable {
        let error: String
    }
    
    nonisolated static let defaultErrorResponse = Response.default("Default error response", returning: ErrorResponse.self) {
        "The default error response for all operations"
    }
    
    nonisolated static let navigationTag = Tag("nav")
    
    var paths: [Path] {
        Path("/users/{id}", summary: "User path", group: "users") {
            Path.Operation(.get, summary: "Get user by ID") {
                Response(.ok, payload: .json(String.self), summary: "Summary") {
                    "A response with a JSON payload"
                }
                Response(kind: .clientError, summary: "Client errors") {
                    
                }
                
                Response(code: 500, summary: "Summary") {
                    Response.Content.jsonDictionary()
                } description: {
                    "An error response returning a JSON dictionary"
                }
                Response(.ok, returning: String.self) {
                    "Success response"
                }
                Self.defaultErrorResponse
            } description: {
                "A very long description of the /users/{id} path."
            }
        } parameters: {
            Parameter.cookie("Cookie", valueType: Int.self, description: "Description", required: true)
        } description: {
            "A longer description of the /users/{id} path."
        }
        
        Path("/user/{id}", summary: "Short summary", group: "users") {
            Path.Operation(.get) {
                
            } security: {
                SecurityScheme.http(.basic)
            } servers: {
                Server("main", url: "https://main.example.com/")
            }
        } parameters: {
            Parameter.query("id", ofType: Int.self)
        } servers: {
            Server("test", url: "https://test.com/")
            Server("test", url: "https://test.com/")
        } description: {
            "Longer description here."
        }
        
        Path("/users/{id}") {
            Path.Operation(.get) {
                Response(.ok, returning: User.self)
                Response.default(returning: UserError.self)
                Response(.ok, payload: .json(String.self)) {
                    ""
                }
                Response.default {
                    Response.Content(.applicationJSON, payload: .bytes)
                } description: {
                    "Default response"
                }
            }
            Path.Operation(.post) {
                Response(.ok) {
                    
                } description: {
                    
                }
            } parameters: {
                Parameter.path("id", ofType: String.self)
                Parameter.query("uuids", ofType: [UUID].self)
            }
            
            Path.Operation(.delete, summary: "short summary") {
                
            } description: {
                "Longer description here"
                "adfsf"
            }

            Path.Operation(.patch, summary: "Patch a user") {
                Response.default(payload: .bytes, summary: "Default Response") {
                    "Description"
                }
                Response(.ok, payload: .bytes)
                Response(.ok, summary: "On Success") {
                    Response.Content(.applicationJSON, payload: .bytes)
                    Response.Content.data()
                    Response.Content.json(String.self)
                    Response.Content(.applicationJSON, payload: .json(String.self))
                } description: {
                    """
                    This is a description of the success response
                    operation.
                    """
                }
            } description: {
                "Long description of the patch operation"
            }
        }
    }
}
