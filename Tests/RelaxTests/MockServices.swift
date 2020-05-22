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
        
        static var urlRequest: URLRequest {
            return URLRequest(request: Get(), baseURL: ExampleService().baseURL)!
        }
    }
}
