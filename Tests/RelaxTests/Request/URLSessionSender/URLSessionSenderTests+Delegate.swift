//
//  URLSessionSenderTests+Delegate.swift
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

extension URLSessionSenderTests {
    @Test func `Send a request with a delegate`() async throws {
        let request = Request(.get, url: url)
        let delegate = MockDelegate()
        try await confirmation { confirmation in
            let transport = MockTransport(
                request: request,
                options: options,
                delegate: delegate,
                expected: .dataForRequest,
                confirmation: confirmation
            )
            _ = try await URLSessionSender(transport: transport).send(request, delegate: delegate, options: options)
        }
    }
    
    @Test func `Send a request expecing a decodable response and a delegate`() async throws {
        let request = Request(.get, url: url)
        let user = User(id: 1)
        let encoded = try JSONEncoder().encode(user)
        let delegate = MockDelegate()
        try await confirmation { confirmation in
            let transport = MockTransport(
                request: request,
                options: options,
                expected: .dataForRequest,
                confirmation: confirmation
            ) { (encoded, HTTPResponse(status: .ok)) }
            
            let (receivedUser, _) = try await URLSessionSender(transport: transport)
                .send(request, decoding: User.self, delegate: delegate, options: options)
            #expect(receivedUser == user)
        }
    }
    
    @Test func `Send a request expecing a decodable response with a body and a delegate`() async throws {
        let request = Request(.get, url: url) {
            Body { "Test" }
        }
        let user = User(id: 1)
        let encoded = try JSONEncoder().encode(user)
        let delegate = MockDelegate()
        try await confirmation { confirmation in
            let transport = MockTransport(
                request: request,
                options: options,
                expected: .uploadForRequest,
                confirmation: confirmation
            ) { (encoded, HTTPResponse(status: .ok)) }
            
            let (receivedUser, _) = try await URLSessionSender(transport: transport)
                .send(request, decoding: User.self, delegate: delegate, options: options)
            #expect(receivedUser == user)
        }
    }
    
    @Test func `Send a request with a file and delegate`() async throws {
        let request = Request(.get, url: url)
        let delegate = MockDelegate()
        let fileURL = URL.temporaryDirectory.appending(path: "test.txt")
        try await confirmation { confirmation in
            let transport = MockTransport(
                request: request,
                file: fileURL,
                options: options,
                delegate: delegate,
                expected: .uploadForRequestFile,
                confirmation: confirmation
            )
            _ = try await URLSessionSender(transport: transport)
                .send(request, withFile: fileURL, delegate: delegate, options: options)
        }
    }
    
    @Test func `Send a download request with a delegate`() async throws {
        let request = Request(.get, url: url)
        let delegate = MockDelegate()
        try await confirmation { confirmation in
            let transport = MockTransport(
                request: request,
                options: options,
                delegate: delegate,
                expected: .downloadForRequest,
                confirmation: confirmation
            )
            _ = try await URLSessionSender(transport: transport)
                .sendDownload(request, delegate: delegate, options: options)
        }
    }
    #if !canImport(FoundationNetworking)
    @Test func `Send a streaming request with a delegate`() async throws {
        let request = Request(.get, url: url)
        let delegate = MockDelegate()
        await confirmation { confirmation in
            let transport = MockTransport(
                request: request,
                options: options,
                delegate: delegate,
                expected: .bytesForRequest,
                confirmation: confirmation
            )
            _ = try? await URLSessionSender(transport: transport)
                .sendStreaming(request, delegate: delegate, options: options)
        }
    }
    #endif
}

final class MockDelegate: NSObject, URLSessionTaskDelegate {}
