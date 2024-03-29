//
//  MockServices.swift
//  
//
//  Created by Thomas De Leon on 5/21/20.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
@testable import Relax

enum ExampleService: Service {
    static let baseURL: URL = URL(string: "https://www.example.com")!
    
    static var session: URLSession = .shared
    
    @RequestBuilder<ExampleService>
    static var get: Request {
        Request.HTTPMethod.get
    }
    
    enum BasicRequests: Endpoint {
        typealias Parent = ExampleService
        
        static let path = "basic"
        
        @RequestBuilder<BasicRequests>
        static var get: Request {
            Request.HTTPMethod.get
        }
        
        @RequestBuilder<BasicRequests>
        static var put: Request {
            Request.HTTPMethod.put
        }
        
        @RequestBuilder<BasicRequests>
        static var post: Request {
            Request.HTTPMethod.post
        }
        
        @RequestBuilder<BasicRequests>
        static var patch: Request {
            Request.HTTPMethod.patch
        }
        
        @RequestBuilder<BasicRequests>
        static var delete: Request {
            Request.HTTPMethod.delete
        }
    }
    
    enum ComplexRequests: Endpoint {
        typealias Parent = ExampleService
        static let path = "complex"
        
        static var sharedProperties: Request.Properties {
            Headers {
                Header.authorization(.basic, value: "secret")
                Header.contentType("application/json")
            }
        }
        
        @RequestBuilder<ComplexRequests>
        static var complex: Request {
            Request.HTTPMethod.get
            PathComponents {
                "suf fix"
            }
        }
        
        enum SubComplex: Endpoint {
            static let path = "sub"
            
            typealias Parent = ComplexRequests
            
            static var sharedProperties: Request.Properties {
                Headers {
                    Header.cacheControl("no-cache")
                }
            }
            
            @RequestBuilder<SubComplex>
            static var sub: Request {
                Request.HTTPMethod.get
            }
            
        }
    }
    
    enum ConfigTest: Endpoint {
        typealias Parent = ExampleService
        static let path = "configtest"
        
        static var configuration: Request.Configuration {
            .init(parseHTTPStatusErrors: true)
        }
        
        static let request = Request(.get, parent: ConfigTest.self)
    }
    
    enum Users: Endpoint {
        typealias Parent = ExampleService
        static let path = "users"
        
        struct User: Codable, Hashable {
            var name: String
        }
        
        static let getRequest = Request(.get, parent: Users.self)

        static func get() async throws -> [User] {
            try await getRequest
                .send(session: Parent.session)
        }
        
        static func get(_ name: String) async throws -> User? {
            try await Request(.get, parent: Users.self) {
                PathComponents { name }
            }
            .send(session: Parent.session)
        }
        
        static func add(_ user: User) async throws {
            try await Request(.put, parent: Users.self) {
                Body(user)
            }
            .send(session: Parent.session)
        }
        
        static func add(_ name: String) async throws {
            try await add(User(name: name))
        }
    }
}

struct BadURLService: Service {
    static let baseURL: URL = URL(string: "a://@@")!
    
    @RequestBuilder<BadURLService>
    static var get: Request {
        Request.HTTPMethod.get
    }
    
    @RequestBuilder<BadURLService>
    static var request: Request {
        Request.HTTPMethod.get
        Headers {
            Header.authorization(.basic, value: "a")
            Header.contentType("ab")
        }
    }
}

enum InheritService: Service {
    static let baseURL = URL(string: "https://example.com")!
    static var configuration: Request.Configuration = Request.Configuration(allowsCellularAccess: false)
    static let session: URLSession = URLSession(configuration: .ephemeral)
    static let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()
    
    static let iso8601Encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }()
    
    enum User: Endpoint {
        static var path: String = "users"
        typealias Parent = InheritService
        
        static let get = Request(.get, parent: User.self)
        
        struct Response: Codable, Hashable {
            var date: Date
        }
    }
}
