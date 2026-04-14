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
    enum Region: String {
        case east
        case west
    }
    var servers: [Server] {
        Server("Prod", url: "https://prod.example.com")
        Server("Stage", url: "https://stage.example.com")
        Server("Other", url: "https://{region}.example.com") {
            Server.Variable("region", type: Region.self, defaultValue: .east)
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
    
    nonisolated static let defaultErrorResponse = Response(.default, summary: "Default error response", returning: ErrorResponse.self) {
        "The default error response for all operations"
    }
    
    nonisolated static let navigationTag = Tag("nav")
    
    var paths: [Path] {
        Path("/users/{id}", summary: "User path") {
            Path.Operation(.get, summary: "Get user by ID") {
                Response(.success) {
                    Response.Content.jsonDictionary()
                }
                Response(.success, returning: String.self)
                Self.defaultErrorResponse
            } description: {
                "A very long description of the /users/{id} path."
            }
        } parameters: {
            Parameter("id", ofType: Int.self, in: .path)
        } tags: {
            Tag("nav", summary: "summary") {
                "Navigation endpoints"
            }
        } description: {
            "A longer description of the /users/{id} path."
        }
        
        Path("/user/{id}", summary: "Short summary") {
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
                Response(.success, returning: User.self)
                Response(.default, returning: UserError.self)
            }
            Path.Operation(.post) {
                Response(.success) {
                    
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
                Response(.default, summary: "Default Response", payload: .bytes) {
                    "Description"
                }
                Response(payload: .bytes)
                Response(.success, summary: "On Success") {
                    Response.Content(.applicationJSON, payload: .bytes)
                    Response.Content.data()
                    Response.Content.json(String.self)
                } description: {
                    """
                    This is a description of the success response
                    operation.
                    """
                }
            } description: {
                "Long description of the patch operation"
            }
        } description: {
            "Fetch a user by ID"
        }
    }
}
