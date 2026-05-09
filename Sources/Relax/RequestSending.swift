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
    func send(_ request: Request) async throws -> (Data, HTTPResponse)
    
    /// Send a request with a file
    /// - Parameters:
    ///   - request: The request to send
    ///   - file: The URL of the file to send
    /// - Returns: The data and `HTTPResponse` returned by the request
    ///
    /// Data at the provided file URL will be used for the request body. Any existing ``Request/body`` set will be ignored.
    func send(_ request: Request, withFile file: URL) async throws -> (Data, HTTPResponse)
    
    /// Send a download request
    /// - Parameter request: The request to send
    /// - Returns: The file URL location of the data and `HTTPResponse` returned from the request.
    func sendDownload(_ request: Request) async throws -> (URL, HTTPResponse)
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
    func send(_ request: Request, delegate: any URLSessionTaskDelegate) async throws -> (Data, HTTPResponse)
    
    /// Send a request with a file and delegate
    /// - Parameters:
    ///   - request: The request to send
    ///   - file: A URL of a file to send as the request body.
    ///   - delegate: A delegate to receive task events, such as progress.
    /// - Returns: The data and `HTTPResponse` returned by the request.
    func send(
        _ request: Request,
        withFile file: URL,
        delegate: any URLSessionTaskDelegate
    ) async throws -> (Data, HTTPResponse)
    
    /// Send a request with a streaming response
    /// - Parameters:
    ///   - request: The request to send
    ///   - delegate: A delegate to receive task events, such as progress.
    /// - Returns: An `AsyncSequence` of data and the `HTTPResponse`.
    func sendStreaming(
        _ request: Request,
        delegate: (any URLSessionTaskDelegate)?
    ) async throws -> (URLSession.AsyncBytes, HTTPResponse)
    
    /// Send a download request with a delegate
    /// - Parameters:
    ///   - request: The request to send.
    ///   - delegate: A delegate to receive task events, such as progress.
    /// - Returns: The file URL location of the data and `HTTPResponse` returned from the request.
    func sendDownload(_ request: Request, delegate: any URLSessionTaskDelegate) async throws -> (URL, HTTPResponse)
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
    
    public func send(_ request: Request) async throws -> (Data, HTTPResponse) {
        if let body = request.body {
            return try await session.upload(for: request.httpRequest, from: body)
        } else {
            return try await session.data(for: request.httpRequest)
        }
    }
    
    public func send(_ request: Request, withFile file: URL) async throws -> (Data, HTTPResponse) {
        try await session.upload(for: request.httpRequest, fromFile: file)
    }
    
    public func sendDownload(_ request: Request) async throws -> (URL, HTTPResponse) {
        try await session.download(for: request.httpRequest)
    }
}

extension URLSessionSender: URLSessionRequestSending {
    public func send(_ request: Request, delegate: any URLSessionTaskDelegate) async throws -> (Data, HTTPResponse) {
        if let body = request.body {
            return try await session.upload(for: request.httpRequest, from: body, delegate: delegate)
        } else {
            return try await session.data(for: request.httpRequest, delegate: delegate)
        }
    }
    
    public func send(
        _ request: Request,
        withFile file: URL,
        delegate: any URLSessionTaskDelegate
    ) async throws -> (Data, HTTPResponse) {
        try await session.upload(for: request.httpRequest, fromFile: file, delegate: delegate)
    }
    
    public func sendStreaming(
        _ request: Request,
        delegate: (any URLSessionTaskDelegate)? = nil
    ) async throws -> (URLSession.AsyncBytes, HTTPResponse) {
        try await session.bytes(for: request.httpRequest, delegate: delegate)
    }
    

    public func sendDownload(
        _ request: Request,
        delegate: any URLSessionTaskDelegate
    ) async throws -> (URL, HTTPResponse) {
        try await session.download(for: request.httpRequest, delegate: delegate)
    }
}
