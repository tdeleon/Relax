//
//  Service+Testing.swift
//  
//
//  Created by Thomas De Leon on 5/22/20.
//

#if !os(watchOS)
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import XCTest
@testable import Relax

extension Service {
    func checkSuccess(request: ServiceRequest, received: URLRequest) {
        // check request method type
        XCTAssertEqual(received.httpMethod, request.httpMethod.rawValue)
        
        // check headers
        for header in request.headers {
            XCTAssertEqual(received.value(forHTTPHeaderField: header.key), header.value)
        }
        
        // check content type
        XCTAssertEqual(request.contentType?.rawValue, received.value(forHTTPHeaderField: "Content-Type"))
        
        // check body
        XCTAssertEqual(request.body, received.httpBody)
        
        // Break URL into components
        if let urlString = received.url?.absoluteString,
            let components = URLComponents(string: urlString) {
            // query items
            XCTAssertEqual(components.queryItems ?? [URLQueryItem](), request.queryParameters)
            
            // path
            var requestPath = request.pathComponents.joined(separator: "/")
            if !requestPath.isEmpty {
                requestPath = "/" + requestPath
            }
            
            // base
            XCTAssertEqual(components.path, requestPath)
            if let scheme = components.scheme,
                let host = components.host {
                let baseURL = self.baseURL.absoluteString
                XCTAssertEqual("\(scheme)://\(host)", baseURL)
            }
        }
    }
}
#endif
