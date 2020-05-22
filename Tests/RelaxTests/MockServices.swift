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
        let requestType: HTTPRequestMethod = .get
        
        var urlRequest: URLRequest {
            return URLRequest(request: self, baseURL: ExampleService().baseURL)!
        }
    }
    
    struct Put: ServiceRequest {
        let requestType: HTTPRequestMethod = .put
        
        var urlRequest: URLRequest {
            return URLRequest(request: self, baseURL: ExampleService().baseURL)!
        }
    }
    
    struct Post: ServiceRequest {
        let requestType: HTTPRequestMethod = .post
        
        var urlRequest: URLRequest {
            return URLRequest(request: self, baseURL: ExampleService().baseURL)!
        }
    }
    
    struct Patch: ServiceRequest {
        let requestType: HTTPRequestMethod = .patch
        
        var urlRequest: URLRequest {
            return URLRequest(request: self, baseURL: ExampleService().baseURL)!
        }
    }
    
    struct Delete: ServiceRequest {
        let requestType: HTTPRequestMethod = .delete
        
        var urlRequest: URLRequest {
            return URLRequest(request: self, baseURL: ExampleService().baseURL)!
        }
    }
}
