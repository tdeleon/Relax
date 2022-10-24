//
//  MockServices.swift
//  
//
//  Created by Thomas De Leon on 5/21/20.
//

#if !os(watchOS)
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
@testable import Relax

//extension ServiceRequest {
//    var urlRequest: URLRequest {
//        URLRequest(request: self, baseURL: ExampleService().baseURL)!
//    }
//}

struct CoinCap: Service {
    static let baseURL = URL(string: "https://api.coincap.io/v2")!
    
    enum Assets: Endpoint {
        typealias Parent = CoinCap
        static let path = "assets"
        
        func getAll() async throws -> GetAll.Response {
            try await GetAll().send()
        }
        
        struct Get: Request {
            typealias Parent = Assets
            let httpMethod: HTTPRequestMethod = .get
            @PathComponent var ID: String
        }
        
        struct GetAll: Request {
            typealias Parent = Assets
            let httpMethod: HTTPRequestMethod = .get
            
            @QueryItem("search") var search: String?
            @QueryItem("ids") var IDs: String?
            @QueryItem("limit") var limit: Int?
            @QueryItem("offset") var offset: Int?
            
            init(search: String? = nil, IDs: String? = nil, limit: Int? = nil, offset: Int? = nil) {
                self.search = search
                self.IDs = IDs
                self.limit = limit
                self.offset = offset
            }
            
            struct Response: Codable {
                let id: String
                let symbol: String
            }
        }
    }
}

enum ExampleService: Service {
    static let baseURL: URL = URL(string: "https://www.example.com")!
    
    struct Get: Request {
        typealias Parent = ExampleService
        
        let httpMethod: HTTPRequestMethod = .get
    }
    
    struct Put: Request {
        typealias Parent = ExampleService
        let httpMethod: HTTPRequestMethod = .put
    }
    
    struct Post: Request {
        typealias Parent = ExampleService
        let httpMethod: HTTPRequestMethod = .post
    }
    
    struct Patch: Request {
        typealias Parent = ExampleService
        let httpMethod: HTTPRequestMethod = .patch
    }
    
    struct Delete: Request {
        typealias Parent = ExampleService
        let httpMethod: HTTPRequestMethod = .delete
    }
    
    enum ExampleEndpoint: Endpoint {
        typealias Parent = ExampleService
        static let path = "example"
        enum Keys {
            static let key = "key"
        }
        
        struct Complex: Request {
            typealias Parent = ExampleService
            
            let endpoint = ExampleEndpoint.self
            let httpMethod: HTTPRequestMethod = .get
            let pathPrefix: String = "prefix"
            let pathSuffix: String = "suffix"
            let headers: [String : String] = [Keys.key: "value"]
            let body: Data? = try? JSONSerialization.data(withJSONObject: ["body"], options: [])
        }
    }
    
    struct NoContentType: Request {
        typealias Parent = ExampleService
        
        static var baseURL: URL = URL(string: "https://example.com/")!
        
        let httpMethod: HTTPRequestMethod = .get
        
        var contentType: RequestContentType? = nil
    }
    
}

struct BadURLService: Service {
    static let baseURL: URL = URL(string: "a://@@")!
    
    struct Get: Request {
        typealias Parent = BadURLService
        let httpMethod: HTTPRequestMethod = .get
    }
}

struct User: Codable, Hashable {
    let name: String
}

#endif
