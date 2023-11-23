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

/// A `URLProtocol` implementation which uses a mock response for all requests made
public class URLProtocolMock: URLProtocol {
    /// The mock object used to return the response
    public static var response: MockResponse = .mock()
    
    override public class func canInit(with request: URLRequest) -> Bool { true }
    
    override public class func canonicalRequest(for request: URLRequest) -> URLRequest { request }
    
    override public func startLoading() {
        do {
            // Call the onReceive closure first, if set. This will notify the caller
            try Self.response.onReceive?(request)
            // call the response handler to get the desired response from the MockResponse
            let (response, data, error) = try Self.response.responseHandler(request)
            // Sleep for any set delay
            if Self.response.delay > 0 {
                sleep(UInt32(Self.response.delay))
            }
            
            // Call did failWithError for an error
            guard error == nil else {
                client?.urlProtocol(self, didFailWithError: error!)
                return
            }
            
            // call normal loading methods
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            // catch an error from onReceive or the responseHandler
            fatalError("\(error)")
        }
    }
    
    override public func stopLoading() {}
}

extension URLSession {
    /// A URLSession configured to return mock responses.
    /// - Parameters:
    ///   - configuration: The configuration for the session
    ///   - delegate: The delegate for the session
    ///   - delegateQueue: The delegateQueue for the session
    ///   - response: The mock response to return
    /// - Returns: A session configured to return mock responses.
    ///
    /// Any request made using this session will use the `URLProtocolMock` protocol, which will return a mock response without using the network.
    /// Pass in the desired response for all requests to the `response` parameter, which defaults to a response with an HTTP status code of `200`, an empty
    /// data object (`Data()`) and no error. You can change the mocked response at any time after the session is created by setting the
    /// `URLProtocol.mock` property.
    public static func mock(
        configuration: URLSessionConfiguration = .ephemeral,
        delegate: URLSessionDelegate? = nil,
        delegateQueue: OperationQueue? = nil,
        response: URLProtocolMock.MockResponse = .mock()
    ) -> URLSession {
        let sessionConfiguration = configuration
        sessionConfiguration.protocolClasses = [URLProtocolMock.self]
        URLProtocolMock.response = response
        return URLSession(configuration: configuration, delegate: delegate, delegateQueue: delegateQueue)
    }
}
