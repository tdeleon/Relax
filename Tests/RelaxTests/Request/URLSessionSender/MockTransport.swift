//
//  File.swift
//  Relax
//
//  Created by Thomas De Leon on 5/14/26.
//

import Foundation
import Testing
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import HTTPTypes

@testable import Relax

struct MockTransport: Transport {
    private static func notCalledIssue() { Issue.record("Should not have been called.") }
    
    //MARK: Call handlers
    
    var dataForRequestCalled: (@Sendable (
        _ request: URLRequest,
        _ delegate: (any URLSessionTaskDelegate)?
    ) -> Void) = { _, _ in
        Self.notCalledIssue()
    }
    
    var uploadForRequestCalled: (@Sendable (
        _ request: URLRequest,
        _ body: Data,
        _ delegate: (any URLSessionTaskDelegate)?
    ) -> Void) = { _, _, _
        in Self.notCalledIssue()
    }
    
    var uploadForRequestWithFileCalled: (@Sendable (
        _ request: URLRequest,
        _ file: URL,
        _ delegate: (any URLSessionTaskDelegate)?
    ) -> Void) = { _, _, _ in
        Self.notCalledIssue()
    }
    
    var bytesForRequestCalled: (@Sendable (
        _ request: URLRequest,
        _ delegate: (any URLSessionTaskDelegate)?
    ) -> Void) = { _, _ in
        Self.notCalledIssue()
    }
    
    var downloadForRequestCalled: (@Sendable (
        _ request: URLRequest,
        _ delegate: (any URLSessionTaskDelegate)?
    ) -> Void) = { _, _ in
        Self.notCalledIssue()
    }
    
    var response: @Sendable () -> (Data, HTTPResponse)
        
    enum ExpectedCall {
        case dataForRequest
        case uploadForRequest
        case uploadForRequestFile
        case bytesForRequest
        case downloadForRequest
    }
    
    //MARK: Initialization
    
    init(
        request: Request,
        file: URL? = nil,
        options: SendOptions? = nil,
        delegate: URLSessionTaskDelegate? = nil,
        expected: ExpectedCall,
        confirmation: Confirmation,
        response: @Sendable @escaping () -> (Data, HTTPResponse) = { (Data(), HTTPResponse(status: .ok)) }
    ) {
        self.response = response

        // Setup the handler to verify and confirm confirmation for the expected function call. All other handlers
        // will record an issue if called.
        switch expected {
        case .dataForRequest:
            dataForRequestCalled = { urlRequest, delegate in
                Self.verify(
                    request,
                    options: options,
                    delegate: delegate,
                    matches: (urlRequest: urlRequest, body: nil, file: nil, delegate: delegate),
                    in: .dataForRequest,
                    confirmation: confirmation
                )
            }
        case .uploadForRequest:
            uploadForRequestCalled = { urlRequest, body, delegate in
                Self.verify(
                    request,
                    options: options,
                    delegate: delegate,
                    matches: (urlRequest: urlRequest, body: body, file: nil, delegate: delegate),
                    in: .uploadForRequest,
                    confirmation: confirmation
                )
            }
        case .uploadForRequestFile:
            uploadForRequestWithFileCalled = { urlRequest, receivedFile, delegate in
                Self.verify(
                    request,
                    file: file,
                    options: options,
                    delegate: delegate,
                    matches: (urlRequest: urlRequest, body: nil, file: receivedFile, delegate: delegate),
                    in: .uploadForRequestFile,
                    confirmation: confirmation
                )
            }
        case .bytesForRequest:
            bytesForRequestCalled = { urlRequest, delegate in
                Self.verify(
                    request,
                    options: options,
                    delegate: delegate,
                    matches: (urlRequest: urlRequest, body: nil, file: nil, delegate: delegate),
                    in: .bytesForRequest,
                    confirmation: confirmation
                )
            }
        case .downloadForRequest:
            downloadForRequestCalled = { urlRequest, delegate in
                Self.verify(
                    request,
                    options: options,
                    delegate: delegate,
                    matches: (urlRequest: urlRequest, body: nil, file: nil, delegate: delegate),
                    in: .downloadForRequest,
                    confirmation: confirmation
                )
            }
        }
    }
    
    //MARK: Verification Helper
    
    private static func verify(
        _ request: Request,
        file: URL? = nil,
        options: SendOptions?,
        delegate: URLSessionTaskDelegate?,
        matches received: (
            urlRequest: URLRequest?,
            body: Data?,
            file: URL?,
            delegate: URLSessionTaskDelegate?
        ),
        in function: ExpectedCall,
        confirmation: Confirmation
    ) {
        // HTTPRequest should always match
        #expect(received.urlRequest?.httpRequest == request.httpRequest)
        
        // Match the received body against the request body
        // downloads have no separate body parameter; body is set on the URLRequest
        if function != .downloadForRequest, file == nil {
            #expect(received.body == request.body)
        }
        
        // Match the URLRequest body against the request body
        if function != .uploadForRequest, file == nil {
            // Uploads have a separate body parameter; body is not set on the URLRequest
            #expect(received.urlRequest?.httpBody == request.body)
        }
        
        // Match the received file URL against any original file URL (for send with file URL)
        #expect(received.file == file)
        
        // if options were set, verify they were applied to the URLRequest
        if let options {
            // compare options
            received.urlRequest?.verify(options: options)
        }
        
        confirmation.confirm()
    }
    
    //MARK: - Transport Implementation
    
    func data(for request: URLRequest, delegate: (any URLSessionTaskDelegate)?) async throws -> (Data, HTTPResponse) {
        dataForRequestCalled(request, delegate)
        return response()
    }
    
    func upload(
        for request: URLRequest,
        from body: Data,
        delegate: (any URLSessionTaskDelegate)?
    ) async throws -> (Data, HTTPResponse) {
        uploadForRequestCalled(request, body, delegate)
        return response()
    }
    
    func upload(
        for request: URLRequest,
        with file: URL,
        delegate: (any URLSessionTaskDelegate)?
    ) async throws -> (Data, HTTPResponse) {
        uploadForRequestWithFileCalled(request, file, delegate)
        return response()
    }
    
    #if !canImport(FoundationNetworking)
    func bytes(
        for request: URLRequest,
        delegate: (any URLSessionTaskDelegate)?
    ) async throws -> (URLSession.AsyncBytes, HTTPResponse) {
        bytesForRequestCalled(request, delegate)
        throw URLError(.unknown)
    }
    #endif

    func download(for request: URLRequest, delegate: (any URLSessionTaskDelegate)?) async throws -> (URL, HTTPResponse) {
        downloadForRequestCalled(request, delegate)
        return (URL.temporaryDirectory, HTTPResponse(status: .ok))
    }
}
