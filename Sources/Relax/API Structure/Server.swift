//
//  Server.swift
//  Relax
//
//  Created by Thomas De Leon on 2/19/26.
//

import Foundation

struct User: Codable {
    let name: String
}

struct UserError: Codable {
    let error: String
}

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
    
    var paths: [Path] {
        Path("/users") {
            Path.Operation(.get) {
                Response(.success) {
                    Response.Content.jsonDictionary()
                }
                Self.defaultErrorResponse
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

public struct Server: Sendable {
    let name: String?
    let url: String
    let description: String?
    let variables: [String: Variable]
    
    public struct Variable: Hashable, @unchecked Sendable {
        let name: String
        let type: Any.Type
        let defaultValue: Any?
        let description: String?
        
        public func hash(into hasher: inout Hasher) {
            hasher.combine(name)
            hasher.combine(description)
            hasher.combine(String(describing: type))
        }
        
        public static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.name == rhs.name
            && lhs.description == rhs.description
            && String(describing: lhs.type) == String(describing: rhs.type)
        }
        
        public init<T: CustomStringConvertible>(
            _ name: String,
            type: T.Type, defaultValue: T? = nil,
            description: StaticString? = nil
        ) {
            self.name = name
            self.type = type
            self.defaultValue = defaultValue
            self.description = description == nil ? nil : "\(description!)"
        }
        
        public init<T: RawRepresentable>(
            _ name: String,
            type: T.Type,
            defaultValue: T? = nil,
            description: StaticString? = nil
        ) where T.RawValue == String {
            self.init(name: name, type: type, defaultValue: defaultValue, description: description)
        }
        
        public init<T: RawRepresentable>(
            _ name: String,
            type: T.Type,
            defaultValue: T? = nil,
            description: StaticString? = nil
        ) where T.RawValue == CustomStringConvertible {
            self.init(name: name, type: type, defaultValue: defaultValue, description: description)
        }
        
        internal init(name: String, type: Any.Type, defaultValue: Any? = nil, description: StaticString? = nil) {
            self.name = name
            self.type = type
            self.defaultValue = defaultValue
            self.description = description == nil ? nil : "\(description!)"
        }
    }
    
    internal init(_ name: String, url: String, description: String?, variables: [String: Variable]) {
        self.name = name
        self.url = url
        self.description = description
        self.variables = variables
    }
    
    /// <#Description#>
    /// - Parameters:
    ///   - name: Name for server
    ///   - url: Base URL for server
    ///   - description: Description of server
    ///   - variables: <#variables description#>
    public init(_ name: String, url: StaticString, description: String? = nil, @Builder variables: () -> [String: Variable]) {
        self.init(name, url: "\(url)", description: description, variables: variables())
    }
    
    public init(_ name: String, url: String, description: String? = nil) {
        self.init(name, url: url, description: description, variables: [:])
    }
    
    public init(_ name: String, url: URL, description: String? = nil) {
        self.init(name, url: url.absoluteString, description: description)
    }
}

extension Server {
    @resultBuilder
    public enum Builder {
        public static func buildBlock() -> [String: Variable] {
            [:]
        }
        
        public static func buildPartialBlock(
            first: [String : Server.Variable]
        ) -> [String : Server.Variable] {
            first
        }
        
        public static func buildPartialBlock(
            accumulated: [String : Server.Variable], next: [String : Server.Variable]
        ) -> [String : Server.Variable] {
            accumulated.merging(next) { _, new in new }
        }
        
        @available(*, unavailable, message: "Use explicit #Server() to define servers")
        public static func buildOptional(
            _ component: [String : Server.Variable]?
        ) -> [String : Server.Variable] {
            component ?? [:]
        }
        
        @available(*, unavailable, message: "Use explicit #Server() to define servers")
        public static func buildEither(
            first component: [String : Server.Variable]
        ) -> [String : Server.Variable] {
            component
        }
        
        @available(*, unavailable, message: "Use explicit #Server() to define servers")
        public static func buildEither(
            second component: [String : Server.Variable]
        ) -> [String : Server.Variable] {
            component
        }
        
        @available(*, unavailable, message: "Use explicit #Server() to define servers")
        public static func buildArray(
            _ components: [[String : Server.Variable]]
        ) -> [String : Server.Variable] {
            components.flatMap { $0 }.reduce(into: [:]) { $0[$1.key] = $1.value }
        }
        
        @available(*, unavailable, message: "Use explicit #Server() to define servers")
        public static func buildLimitedAvailability(
            _ component: [String : Server.Variable]
        ) -> [String : Server.Variable] {
            component
        }
        
        public static func buildExpression(_ expression: Variable) -> [String : Server.Variable] {
            [expression.name: expression]
        }
        
//        public static func buildExpression<T: CustomStringConvertible>(
//            _ expression: (String, T)
//        ) -> [String : ServerDescription.Variable] {
//            [expression.0: Variable(
//                name: expression.0,
//                type: type(of: expression.1),
//                defaultValue: expression.1,
//                description: nil
//            )]
//        }
//        
//        public static func buildExpression<T: CustomStringConvertible>(
//            _ expression: (String, T.Type)
//        ) -> [String : ServerDescription.Variable] {
//            [expression.0: Variable(name: expression.0, type: expression.1, defaultValue: nil, description: nil)]
//        }
    }
}

