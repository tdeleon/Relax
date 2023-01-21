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
    typealias MockHandler = ((URLRequest) -> (URLResponse?, Data?, Error?, TimeInterval))
    
    static var mock: MockHandler?
    
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        guard let mock = URLProtocolMock.mock else {
            fatalError("Missing mock - the mock property must be set.")
        }
                
        let (response, data, error, delay) = mock(request)
        
        guard error == nil else {
            client?.urlProtocol(self, didFailWithError: error!)
            return
        }
        
        sleep(UInt32(delay))
        
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
