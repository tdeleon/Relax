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

extension ServiceRequest {
    var urlRequest: URLRequest {
        URLRequest(request: self, baseURL: ExampleService().baseURL)!
    }
}

struct ExampleService: Service {
    let baseURL: URL = URL(string: "https://www.example.com")!
    
    struct Get: ServiceRequest {
        let httpMethod: HTTPRequestMethod = .get
    }
    
    struct Put: ServiceRequest {
        let httpMethod: HTTPRequestMethod = .put
        
        var urlRequest: URLRequest {
            return URLRequest(request: self, baseURL: ExampleService().baseURL)!
        }
    }
    
    struct Post: ServiceRequest {
        let httpMethod: HTTPRequestMethod = .post
        
        var urlRequest: URLRequest {
            return URLRequest(request: self, baseURL: ExampleService().baseURL)!
        }
    }
    
    struct Patch: ServiceRequest {
        let httpMethod: HTTPRequestMethod = .patch
        
        var urlRequest: URLRequest {
            return URLRequest(request: self, baseURL: ExampleService().baseURL)!
        }
    }
    
    struct Delete: ServiceRequest {
        let httpMethod: HTTPRequestMethod = .delete
        
        var urlRequest: URLRequest {
            return URLRequest(request: self, baseURL: ExampleService().baseURL)!
        }
    }
    
    enum ExampleEndpoint: Endpoint {
        static let path = "example"
        enum Keys {
            static let key = "key"
        }
        
        struct Complex: ServiceRequest {
            let endpoint = ExampleEndpoint.self
            let httpMethod: HTTPRequestMethod = .get
            
            let pathComponents = ["path", "components"]
            let queryParameters: [URLQueryItem] = [URLQueryItem(name: "first", value: "firstValue")]
            let headers: [String : String] = [Keys.key: "value"]
            let body: Data? = try? JSONSerialization.data(withJSONObject: ["body"], options: [])
        }
    }
    
    struct NoContentType: ServiceRequest {
        let httpMethod: HTTPRequestMethod = .get
        
        var contentType: RequestContentType? = nil
    }
    
}

struct BadURLService: Service {
    let baseURL: URL = URL(string: "a://@@")!
    
    struct Get: ServiceRequest {
        let httpMethod: HTTPRequestMethod = .get
    }
}

#endif
