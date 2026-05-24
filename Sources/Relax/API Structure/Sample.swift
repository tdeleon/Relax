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
        SecurityScheme.apiKey("api-key", in: .header) {
            "An API key scheme"
        }
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
    
    nonisolated static let defaultErrorResponse = Response.json(kind: .serverError, returning: ErrorResponse.self) {
        "The default error response for all operations"
    }
    
    nonisolated static let navigationTag = Tag("nav")
    
    var paths: [Path] {
        Path("/users/{id}", summary: "User path", group: "users") {
            Path.Operation(.get) {
                Response(.ok)
            } body: {
                ["userID": "123"]
            }

            Path.Operation(.post, bodyParameter: .json(User.self, name: "user")) {
                Response(.created)
            }
            
            Path.Operation(.get, bodyParameter: .string(name: "user name"), summary: "Find a user by name") {
                Response.json(.ok, returning: User.self)
            }
            Path.Operation(.get, bodyParameter: .json(User.self, name: "user"), summary: "Get user by ID") {
                Response.json(.ok, returning: String.self, summary: "Summary") {
                    "A response with a JSON payload"
                }
                Response.jsonDictionary(code: 500, summary: "summary") {
                    "An error response returning a JSON dictionary"
                }
                Response.json(.ok, returning: String.self) {
                    "Success response"
                }
                Self.defaultErrorResponse
            } tags: {
                "abc"
            } description: {
                "A very long description of the /users/{id} path."
            }

            Path.Operation(.get, bodyParameter: .data(name: "abc")) {
                Response(.ok)
            } parameters: {
                Parameter.path("hello")
            } tags: {
                Tag("abc")
            } servers: {
                Server("test", url: URL(string: "https://test.com")!)
            } description: {
                
            }


            Path.Operation(.post, summary: "Add a new user") {
                // payload
                Response(.ok, summary: "hello")
                Response(.ok, accept: .wildcard)
                Response(.ok)
                
                Response(.ok, summary: "hello") {
                    "This is a longer description"
                }
                
                // decodable
                Response.json(.ok, returning: User.self, summary: "Summary")
                
                Response.json(.ok, returning: User.self) {
                    " desc"
                }
                
                Response.text(.ok)
            }
        } parameters: {
            Parameter.path("id", ofType: Int.self, description: "User ID")
        } description: {
            "A longer description of the /users/{id} path."
        }
        
        Path("/user/{id}", summary: "Short summary", group: "users") {
            Path.Operation(.get) {
                Response(.ok)
            } parameters: {
                Parameter.path("id", ofType: Int.self, description: "The user ID")
                Parameter.query("name", ofObjectType: String.self, description: "The user name", required: true)
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
                Response.json(.ok, returning: User.self)
            }
            Path.Operation(.post) {
                Response(.ok) {
                    
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
                Response.data(.ok) {
                    "Success response"
                }
            } description: {
                "Long description of the patch operation"
            }
        }
    }
}
