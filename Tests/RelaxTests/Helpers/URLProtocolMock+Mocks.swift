//
//  URLProtocolMock+Mocks.swift
//  
//
//  Created by Thomas De Leon on 5/22/20.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
@testable import Relax

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
    
    static func mockResponse<Model: Encodable>(model: Model, httpStatus: Int=200, delay: TimeInterval=0) -> MockHandler {
        mockResponse(data: try? JSONEncoder().encode(model), httpStatus: httpStatus, error: nil, delay: delay)
    }
    
    static func mockError(requestError: RequestError) -> MockHandler {
        switch requestError {
        case .httpStatus(_, let error):
            return mockResponse(httpStatus: error.statusCode)
        case .decoding(_, _):
            return mockResponse(data: Data())
        case .urlError(_, let error):
            return mockResponse(error: error)
        case .other(_, let message):
            return mockResponse(error: NSError(domain: "com.relax.test", code: -1, userInfo: [NSLocalizedDescriptionKey: message]))
        }
    }
}
