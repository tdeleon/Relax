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
    
    struct ErrorResponse: Codable, Sendable {
        let error: String
    }
    
    nonisolated static let defaultErrorResponse = Response(.default, summary: "Default error response", returning: ErrorResponse.self) {
        "The default error response for all operations"
    }
    
    nonisolated static let navigationTag = Tag("nav")
    
    var paths: [Path] {
        Path("/users") {
            Path.Operation(.get) {
                Response(.success) {
                    Response.Content.jsonDictionary()
                }
                Self.defaultErrorResponse
            } tags: {
                Tag.nav
            }
            
            Path.Operation(.post) {
                Response(.success, payload: .json(String.self))
            }
        }
        
        Path("/user/{id}", summary: "Short summary") {
            Path.Operation(.get) {
                
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
