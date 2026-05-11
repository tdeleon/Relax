//
//  RequestSending.swift
//  Relax
//
//  Created by Thomas De Leon on 4/29/26.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import HTTPTypes
import HTTPTypesFoundation

/// A protocol for sending network requests and receiving raw responses
///
/// Use the default implementation, ``URLSessionSender`` to send requests using `URLSession`. For testing, you can use ``MockSender`` to mock
/// responses.
public protocol RequestSending: Sendable {
    
    /// Send a request asynchronously
    /// - Parameter request: The request to send
    /// - Returns: The data and `HTTPResponse` returned by the request
    ///
    func send(_ request: Request, options: SendOptions?) async throws -> (Data, HTTPResponse)
    
    /// Send a request asynchronously, expecting a Decodable response
    /// - Parameters:
    ///   - request: The request to send
    ///   - decoder: The JSON decoder to use
    ///   - options: Options for this request. Any set options will override the `URLSessionConfiguration`
    /// - Returns: The expected Decodable model
    func send<Model: Decodable>(
        _ request: Request,
        decoder: JSONDecoder,
        options: SendOptions?
    )  async throws -> (Model, HTTPResponse)
    
    /// Send a request with a file
    /// - Parameters:
    ///   - request: The request to send
    ///   - file: The URL of the file to send
    ///   - options: Options for this request. Any set options will override the `URLSessionConfiguration`
    /// - Returns: The data and `HTTPResponse` returned by the request
    ///
    /// Data at the provided file URL will be used for the request body. Any existing ``Request/body`` set will be ignored.
    func send(_ request: Request, withFile file: URL, options: SendOptions?) async throws -> (Data, HTTPResponse)
    
    /// Send a request with a file, expecting a Decodable response
    /// - Parameters:
    ///   - request: The request to send
    ///   - file: The URL of the file to send
    ///   - decoder: The JSON decoder to use
    ///   - options: Options for this request. Any set options will override the `URLSessionConfiguration`
    /// - Returns: The expected decodable model
    func send<Model: Decodable>(
        _ request: Request,
        withFile file: URL,
        decoder: JSONDecoder,
        options: SendOptions?
    ) async throws -> (Model, HTTPResponse)
    
    /// Send a download request
    /// - Parameters:
    ///   - request: The request to send
    ///   - options: Options for this request. Any set options will override the `URLSessionConfiguration`
    /// - Returns: The file URL location of the data and `HTTPResponse` returned from the request.
    func sendDownload(_ request: Request, options: SendOptions?) async throws -> (URL, HTTPResponse)
}

/// A protocol for sending requests with URLSession
///
/// Use the default implementation, ``URLSessionSender`` to send requests using `URLSession`. For testing, you can use ``MockSender`` to mock
/// responses.
public protocol URLSessionRequestSending {
    /// Send a request with a delegate
    /// - Parameters:
    ///   - request: The request to send
    ///   - delegate: A delegate to recieve task events, such as progress.
    /// - Returns: The data and `HTTPResponse` returned by the request.
    func send(
        _ request: Request,
        delegate: any URLSessionTaskDelegate,
        options: SendOptions?
    ) async throws -> (Data, HTTPResponse)
    
    /// Send a request with a file and delegate
    /// - Parameters:
    ///   - request: The request to send
    ///   - file: A URL of a file to send as the request body.
    ///   - delegate: A delegate to receive task events, such as progress.
    /// - Returns: The data and `HTTPResponse` returned by the request.
    func send(
        _ request: Request,
        withFile file: URL,
        delegate: any URLSessionTaskDelegate,
        options: SendOptions?
    ) async throws -> (Data, HTTPResponse)
    
    /// Send a request with a streaming response
    /// - Parameters:
    ///   - request: The request to send
    ///   - delegate: A delegate to receive task events, such as progress.
    /// - Returns: An `AsyncSequence` of data and the `HTTPResponse`.
    func sendStreaming(
        _ request: Request,
        delegate: (any URLSessionTaskDelegate)?,
        options: SendOptions?
    ) async throws -> (URLSession.AsyncBytes, HTTPResponse)
    
    /// Send a download request with a delegate
    /// - Parameters:
    ///   - request: The request to send.
    ///   - delegate: A delegate to receive task events, such as progress.
    /// - Returns: The file URL location of the data and `HTTPResponse` returned from the request.
    func sendDownload(
        _ request: Request,
        delegate: any URLSessionTaskDelegate,
        options: SendOptions?
    ) async throws -> (URL, HTTPResponse)
}

/// The default implementation for sending Requests
///
/// This implementation of the ``RequestSending`` protocol uses an instance of `URLSession` to send network requests.
public struct URLSessionSender: RequestSending {
    /// The session to use for transport
    public let session: URLSession
    
    /// Create a sender to send requests
    /// - Parameter session: The session to use for transport
    public init(session: URLSession = .shared) {
        self.session = session
    }
    
    public func send(_ request: Request, options: SendOptions? = nil) async throws -> (Data, HTTPResponse) {
        if let body = request.body {
            if let options, options.hasSetOptions, var urlRequest = request.urlRequest {
                urlRequest.apply(options: options)
                return try await session.upload(for: urlRequest, from: body)
            } else {
                return try await session.upload(for: request.httpRequest, from: body)
            }
        } else {
            if let options, options.hasSetOptions, var urlRequest = request.urlRequest {
                urlRequest.apply(options: options)
                return try await session.data(for: urlRequest)
            } else {
                return try await session.data(for: request.httpRequest)
            }
        }
    }
    
    public func send(
        _ request: Request,
        withFile file: URL,
        options: SendOptions? = nil
    ) async throws -> (Data, HTTPResponse) {
        if let options, options.hasSetOptions, var urlRequest = request.urlRequest {
            urlRequest.apply(options: options)
            return try await session.upload(for: urlRequest, fromFile: file)
        } else {
            return try await session.upload(for: request.httpRequest, fromFile: file)
        }
    }
    
    public func sendDownload(_ request: Request, options: SendOptions? = nil) async throws -> (URL, HTTPResponse) {
        try await session.download(for: request.httpRequest)
    }
}

extension URLSessionSender: URLSessionRequestSending {
    public func send(
        _ request: Request,
        delegate: any URLSessionTaskDelegate,
        options: SendOptions? = nil
    ) async throws -> (Data, HTTPResponse) {
        if let body = request.body {
            if let options, options.hasSetOptions, var urlRequest = request.urlRequest {
                urlRequest.apply(options: options)
                return try await session.upload(for: urlRequest, from: body, delegate: delegate)
            } else {
                return try await session.upload(for: request.httpRequest, from: body, delegate: delegate)
            }
        } else {
            if let options, options.hasSetOptions, var urlRequest = request.urlRequest {
                urlRequest.apply(options: options)
                return try await session.data(for: urlRequest, delegate: delegate)
            } else {
                return try await session.data(for: request.httpRequest, delegate: delegate)
            }
        }
    }
    
    public func send(
        _ request: Request,
        withFile file: URL,
        delegate: any URLSessionTaskDelegate,
        options: SendOptions? = nil
    ) async throws -> (Data, HTTPResponse) {
        if let options, options.hasSetOptions, var urlRequest = request.urlRequest {
            urlRequest.apply(options: options)
            return try await session.upload(for: urlRequest, fromFile: file, delegate: delegate)
        }else {
            return try await session.upload(for: request.httpRequest, fromFile: file, delegate: delegate)
        }
    }
    
    public func sendStreaming(
        _ request: Request,
        delegate: (any URLSessionTaskDelegate)? = nil,
        options: SendOptions? = nil
    ) async throws -> (URLSession.AsyncBytes, HTTPResponse) {
        if let options, options.hasSetOptions, var urlRequest = request.urlRequest {
            urlRequest.apply(options: options)
            let response = try await session.bytes(for: urlRequest, delegate: delegate)
            guard let httpResponse = (response.1 as? HTTPURLResponse)?.httpResponse
            else { throw URLError(.badServerResponse) }
            
            return (response.0, httpResponse)
        } else {
            return try await session.bytes(for: request.httpRequest, delegate: delegate)
        }
    }

    public func sendDownload(
        _ request: Request,
        delegate: any URLSessionTaskDelegate,
        options: SendOptions? = nil
    ) async throws -> (URL, HTTPResponse) {
        if let options, options.hasSetOptions, var urlRequest = request.urlRequest {
            urlRequest.apply(options: options)
            let response = try await session.download(for: urlRequest, delegate: delegate)
            guard let httpResponse = (response.1 as? HTTPURLResponse)?.httpResponse
            else { throw URLError(.badServerResponse) }
            
            return (response.0, httpResponse)
        } else {
            return try await session.download(for: request.httpRequest, delegate: delegate)
        }
    }
}

extension URLSession {
    internal func data(
        for request: URLRequest,
        delegate: URLSessionTaskDelegate? = nil
    ) async throws -> (Data, HTTPResponse) {
        let response: (data: Data, urlResponse: URLResponse) = try await data(for: request, delegate: delegate)
        guard let httpResponse = (response.urlResponse as? HTTPURLResponse)?.httpResponse
        else { throw URLError(.badServerResponse) }
        
        return (response.data, httpResponse)
    }
    
    internal func upload(
        for request: URLRequest,
        from body: Data,
        delegate: URLSessionTaskDelegate? = nil
    ) async throws -> (Data, HTTPResponse) {
        let response: (data: Data, urlResponse: URLResponse) = try await upload(
            for: request,
            from: body,
            delegate: delegate
        )
        guard let httpResponse = (response.urlResponse as? HTTPURLResponse)?.httpResponse
        else { throw URLError(.badServerResponse) }
        
        return (response.data, httpResponse)
    }
    
    internal func upload(
        for request: URLRequest,
        fromFile file: URL,
        delegate: URLSessionTaskDelegate? = nil
    ) async throws -> (Data, HTTPResponse) {
        let response: (data: Data, urlResponse: URLResponse) = try await upload(
            for: request,
            fromFile: file,
            delegate: delegate
        )
        guard let httpResponse = (response.urlResponse as? HTTPURLResponse)?.httpResponse
        else { throw URLError(.badServerResponse) }
        
        return (response.data, httpResponse)
    }
}
