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

/// A class which returns a mocked response for all requests made.
///
/// This class subclasses `URLProtocol` in order to return a mocked response instead of using the network.
public final class URLMock: URLProtocol {
    /// The mock object used to return the response
    ///
    /// Set this property to provide the response you want to be returned to `URLSession` clients using ``URLMock``.
    /// - Important: Setting this property will apply to all instances of `URLSession` using ``URLMock``.
    public static var response: MockResponse = .mock()
    
    override public class func canInit(with request: URLRequest) -> Bool { true }
    
    override public class func canonicalRequest(for request: URLRequest) -> URLRequest { request }
    
    override public func startLoading() {
        do {
            // Call the onReceive closure first, if set. This will notify the caller
            try Self.response.onReceive?(request)
            // call the response handler to get the desired response from the MockResponse
            let response = try Self.response.responseHandler(request)
            // Sleep for any set delay
            if Self.response.delay > 0 {
                sleep(UInt32(Self.response.delay))
            }
            
            // Call did failWithError for an error
            guard response.error == nil else {
                client?.urlProtocol(self, didFailWithError: response.error!)
                return
            }
            
            // call normal loading methods
            client?.urlProtocol(self, didReceive: response.httpURLResponse, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: response.data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            // catch an error from onReceive or the responseHandler
            fatalError("\(error)")
        }
    }
    
    override public func stopLoading() {}
}

extension URLMock {
    /// A `URLSession` configured to return mock responses.
    /// - Parameters:
    ///   - mockResponse: The mock response to return. The default is `.mock()`, an empty response with a `204` HTTP status code.
    ///   - configuration: The configuration for the session. The default is `URLSessionConfiguration.ephemeral`
    ///   - delegate: The delegate for the session. The default is `nil`.
    ///   - delegateQueue: The delegateQueue for the session. The default is `nil`.
    /// - Returns: A session configured to return mock responses.
    ///
    /// Any request made using this session will use the ``URLMock`` class for responses, which will return a mock response without using the network.
    /// ``URLMock`` will be set as the `protocolClasses` property for the `URLSessionConfiguration`.
    ///
    /// Pass in the desired response for all requests to the `response` parameter, which defaults to a response with an HTTP status code of `200`, an empty
    /// data object (`Data()`) and no error. You can change the mocked response at any time after the session is created by setting the
    /// `URLProtocol.mock` property.
    public static func session(
        _ mockResponse: MockResponse = .mock(),
        configuration: URLSessionConfiguration = .ephemeral,
        delegate: URLSessionDelegate? = nil,
        delegateQueue: OperationQueue? = nil
    ) -> URLSession {
        let sessionConfiguration = configuration
        sessionConfiguration.protocolClasses = [URLMock.self]
        Self.response = mockResponse
        return URLSession(configuration: configuration, delegate: delegate, delegateQueue: delegateQueue)
    }
}
