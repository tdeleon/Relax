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
    ///   - decoding: The decodable type expected in the response
    ///   - decoder: The JSON decoder to use
    ///   - options: Options for this request. Any set options will override the `URLSessionConfiguration`
    /// - Returns: The decodable decoded from the response and the HTTP response received
    func send<Model: Decodable>(
        _ request: Request,
        decoding: Model.Type,
        with decoder: JSONDecoder,
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
    ///   - options: Options for this request. Any set options will override the `URLSessionConfiguration`
    /// - Returns: The data and `HTTPResponse` returned by the request.
    func send(
        _ request: Request,
        delegate: any URLSessionTaskDelegate,
        options: SendOptions?
    ) async throws -> (Data, HTTPResponse)
    
    /// Send a request asynchronously, expecting a Decodable response
    /// - Parameters:
    ///   - request: The request to send
    ///   - decoding: The decodable type expected in the response
    ///   - decoder: The JSON decoder to use
    ///   - delegate: A delegate to recieve task events, such as progress.
    ///   - options: Options for this request. Any set options will override the `URLSessionConfiguration`
    /// - Returns: The decodable decoded from the response and the HTTP response received
    func send<Model: Decodable>(
        _ request: Request,
        decoding: Model.Type,
        with decoder: JSONDecoder,
        delegate: any URLSessionTaskDelegate,
        options: SendOptions?
    )  async throws -> (Model, HTTPResponse)
    
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
}

/// The default implementation for sending Requests
///
/// This implementation of the ``RequestSending`` protocol uses an instance of `URLSession` to send network requests.
public struct URLSessionSender: RequestSending {
    private let transport: Transport
    
    /// Create a sender to send requests
    /// - Parameter session: The session to use for transport
    public init(session: URLSession = .shared) {
        self.transport = URLSessionTransport(session: session)
    }
    
    internal init(transport: Transport) {
        self.transport = transport
    }
    
    public func send(_ request: Request, options: SendOptions? = nil) async throws -> (Data, HTTPResponse) {
        try await _send(request: request, delegate: nil, options: options)
    }
    
    public func send<Model: Decodable>(
        _ request: Request,
        decoding: Model.Type,
        with decoder: JSONDecoder = JSONDecoder(),
        options: SendOptions?
    ) async throws -> (Model, HTTPResponse) {
        try await _send(request: request, decoder: decoder, delegate: nil, options: options)
    }
    
    public func send(
        _ request: Request,
        withFile file: URL,
        options: SendOptions? = nil
    ) async throws -> (Data, HTTPResponse) {
        try await _send(request: request, file: file, delegate: nil, options: options)
    }

    public func sendDownload(_ request: Request, options: SendOptions? = nil) async throws -> (URL, HTTPResponse) {
        try await _sendDownload(request: request, delegate: nil, options: options)
    }
}

extension URLSessionSender: URLSessionRequestSending {
    public func send(
        _ request: Request,
        delegate: any URLSessionTaskDelegate,
        options: SendOptions? = nil
    ) async throws -> (Data, HTTPResponse) {
        try await _send(request: request, delegate: delegate, options: options)
    }
    
    public func send<Model>(
        _ request: Request,
        decoding: Model.Type,
        with decoder: JSONDecoder = JSONDecoder(),
        delegate: any URLSessionTaskDelegate,
        options: SendOptions?
    ) async throws -> (Model, HTTPTypes.HTTPResponse) where Model : Decodable {
        try await _send(request: request, decoder: decoder, delegate: delegate, options: options)
    }
    
    public func send(
        _ request: Request,
        withFile file: URL,
        delegate: any URLSessionTaskDelegate,
        options: SendOptions? = nil
    ) async throws -> (Data, HTTPResponse) {
        try await _send(request: request, file: file, delegate: delegate, options: options)
    }
    
    public func sendDownload(
        _ request: Request,
        delegate: any URLSessionTaskDelegate,
        options: SendOptions? = nil
    ) async throws -> (URL, HTTPResponse) {
        try await _sendDownload(request: request, delegate: delegate, options: options)
    }
    
    public func sendStreaming(
        _ request: Request,
        delegate: (any URLSessionTaskDelegate)? = nil,
        options: SendOptions? = nil
    ) async throws -> (URLSession.AsyncBytes, HTTPResponse) {
        try await transport.bytes(for: try request.urlRequest(applying: options), delegate: delegate)
    }
}

extension URLSessionSender {
    private func _send(
        request: Request,
        delegate: URLSessionTaskDelegate?,
        options: SendOptions?
    ) async throws -> (Data, HTTPResponse) {
        let urlRequest = try request.urlRequest(applying: options)
        if let body = request.body {
            return try await transport.upload(for: urlRequest, from: body, delegate: delegate)
        } else {
            return try await transport.data(for: urlRequest, delegate: delegate)
        }
    }
    
    private func _send<Model: Decodable>(
        request: Request,
        decoder: JSONDecoder = JSONDecoder(),
        delegate: URLSessionTaskDelegate?,
        options: SendOptions?
    ) async throws -> (Model, HTTPResponse) {
        let (data, response) = try await _send(request: request, delegate: delegate, options: options)
        let decoded = try decoder.decode(Model.self, from: data)
        return (decoded, response)
    }
    
    private func _send(
        request: Request,
        file: URL,
        delegate: URLSessionTaskDelegate?,
        options: SendOptions?
    ) async throws -> (Data, HTTPResponse) {
        try await transport.upload(for: try request.urlRequest(applying: options), with: file, delegate: delegate)
    }
    
    private func _sendDownload(
        request: Request,
        delegate: URLSessionTaskDelegate?,
        options: SendOptions?
    ) async throws -> (URL, HTTPResponse) {
        var urlRequest = try request.urlRequest(applying: options)
        urlRequest.httpBody = request.body
        return try await transport.download(for: urlRequest, delegate: delegate)
    }
}
