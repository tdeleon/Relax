//
//  File.swift
//  
//
//  Created by Thomas De Leon on 5/21/20.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
@testable import Relax

struct ExampleService: Service {
    let baseURL: URL = URL(string: "https://www.example.com")!
    
    struct Get: ServiceRequest {
        let httpMethod: HTTPRequestMethod = .get
        
        var urlRequest: URLRequest {
            return URLRequest(request: self, baseURL: ExampleService().baseURL)!
        }
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
}
