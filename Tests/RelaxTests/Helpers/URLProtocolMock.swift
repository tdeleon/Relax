//
//  URLProtocolMock.swift
//  
//
//  Created by Thomas De Leon on 5/22/20.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
@testable import Relax

class URLProtocolMock: URLProtocol {
    typealias MockHandler = ((URLRequest) -> (URLResponse?, Data?, Error?))
    
    static var mock: MockHandler?
    static var delay: TimeInterval = 0
    
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        guard let mock = Self.mock else {
            fatalError("Missing mock - the mock property must be set.")
        }
                
        let (response, data, error) = mock(request)
        if Self.delay > 0 {
            sleep(UInt32(Self.delay))
        }
        guard error == nil else {
            client?.urlProtocol(self, didFailWithError: error!)
            return
        }
        
        if let response = response {
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        }
        
        if let data = data {
            client?.urlProtocol(self, didLoad: data)
        }
        
        client?.urlProtocolDidFinishLoading(self)
    }
    
    override func stopLoading() {}
}



extension URLSession {
    static var sessionWithMock: URLSession {
        let configuration = URLSessionConfiguration.default
        configuration.protocolClasses = [URLProtocolMock.self]
        return URLSession(configuration: configuration)
    }
}
