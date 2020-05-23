//
//  File.swift
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
    typealias MockHandler = ((URLRequest) -> (HTTPURLResponse, Data?, Error?, TimeInterval))
    
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
        
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        
        if let data = data {
            client?.urlProtocol(self, didLoad: data)
        }
        
        client?.urlProtocolDidFinishLoading(self)
    }
    
    override func stopLoading() {}
}

extension URLProtocolMock {
    static func mockResponse(data: Data?=nil, response: HTTPURLResponse, error: Error?=nil, delay: TimeInterval=0) -> MockHandler {
        return  { request in
            return (response, data, error, delay)
        }
    }
    
    static func mockResponse(data: Data?=nil, httpStatus: Int=200, error: Error?=nil, delay: TimeInterval=0) -> MockHandler {
        let response = HTTPURLResponse(url: URL(string: "http://example.com/")!, statusCode: httpStatus, httpVersion: nil, headerFields: nil)!
        return mockResponse(data: data, response: response, error: error, delay: delay)
    }
    
    static func mockError(requestError: RequestError) -> MockHandler {
        switch requestError {
        case .httpBadRequest(_):
            return mockResponse(httpStatus: 400)
        case .httpNotFound(_):
            return mockResponse(httpStatus: 404)
        case .other(_, let message):
            return mockResponse(error: NSError(domain: "com.relax.test", code: -1, userInfo: [NSLocalizedDescriptionKey: message]))
        case .otherHTTPError(_, let status):
            return mockResponse(httpStatus: status)
        case .httpServerError(_, let status):
            return mockResponse(httpStatus: status)
        case .httpUnauthorized(_):
            return mockResponse(httpStatus: 401)
        case .urlError(_, let error):
            return mockResponse(error: error)
        }
    }
}

extension URLSession {
    static var sessionWithMock: URLSession {
        let configuration = URLSessionConfiguration.default
        configuration.protocolClasses = [URLProtocolMock.self]
        return URLSession(configuration: configuration)
    }
}
