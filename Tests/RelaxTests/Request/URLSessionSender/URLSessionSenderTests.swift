//
//  URLSessionSenderTests.swift
//  Relax
//
//  Created by Thomas De Leon on 5/13/26.
//

import Foundation
import Testing
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import HTTPTypes

@testable import Relax

struct URLSessionSenderTests {
    let url = URL(string: "https://example.com/")!
    let options: SendOptions = {
        #if canImport(FoundationNetworking)
        SendOptions(
            cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
            timeoutInterval: 10,
            httpShouldHandleCookies: false,
            allowsCellularAccess: false,
            networkServiceType: .avStreaming
        )
        #else
        SendOptions(
            cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
            timeoutInterval: 10,
            httpShouldHandleCookies: false,
            allowsCellularAccess: false,
            networkServiceType: .avStreaming,
            allowsConstrainedNetworkAccess: false,
            allowsExpensiveNetworkAccess: false
        )
        #endif
    }()
    
    struct Item: Codable, Hashable {
        let date: Date
    }
    
    struct User: Codable, Hashable {
        let id: Int
    }
    
    @Test func `Send a request`() async throws {
        let request = Request(.get, url: url)
        
        try await confirmation { confirmation in
            let transport = MockTransport(
                request: request,
                options: options,
                expected: .dataForRequest,
                confirmation: confirmation
            )
            _ = try await URLSessionSender(transport: transport).send(request, options: options)
        }
    }
    
    @Test func `Send a request expecing a decodable response`() async throws {
        let request = Request(.get, url: url)
        let dateString = "2026-05-15T18:51:14+00:00"
        
        let expectedDate = try Date(dateString, strategy: .iso8601)
        
        let encoded = try JSONSerialization.data(withJSONObject: ["date": dateString])
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        try await confirmation { confirmation in
            let transport = MockTransport(
                request: request,
                options: options,
                expected: .dataForRequest,
                confirmation: confirmation
            ) { (encoded, HTTPResponse(status: .ok)) }
            
            let (receivedDate, _) = try await URLSessionSender(transport: transport)
                .send(request, decoding: Item.self, with: decoder, options: options)
            #expect(receivedDate == Item(date: expectedDate))
        }
    }
    
    @Test func `Send a request expecing a decodable response with a body`() async throws {
        let request = Request(.get, url: url) {
            Body { "Test" }
        }
        let user = User(id: 1)
        let encoded = try JSONEncoder().encode(user)
        
        try await confirmation { confirmation in
            let transport = MockTransport(
                request: request,
                options: options,
                expected: .uploadForRequest,
                confirmation: confirmation
            ) { (encoded, HTTPResponse(status: .ok)) }
            
            let (receivedUser, _) = try await URLSessionSender(transport: transport)
                .send(request, decoding: User.self, options: options)
            #expect(receivedUser == user)
        }
    }
    
    @Test func `Send a request with a body`() async throws {
        let request = Request(.get, url: url) {
            Body { "Test" }
        }
        
        try await confirmation { confirmation in
            let transport = MockTransport(
                request: request,
                options: options,
                expected: .uploadForRequest,
                confirmation: confirmation
            )
            _ = try await URLSessionSender(transport: transport).send(request, options: options)
        }
    }

    @Test func `Send a request with a file URL`() async throws {
        let request = Request(.get, url: url) {
            Body { "Test" }
        }
        let fileURL = URL.temporaryDirectory.appending(path: "test.txt")
        try await confirmation { confirmation in
            let transport = MockTransport(
                request: request,
                file: fileURL,
                options: options,
                expected: .uploadForRequestFile,
                confirmation: confirmation
            )
            _ = try await URLSessionSender(transport: transport).send(request, withFile: fileURL, options: options)
        }
    }
    
    @Test func `Send a download request`() async throws {
        let request = Request(.get, url: url)
        try await confirmation { confirmation in
            let transport = MockTransport(
                request: request,
                options: options,
                expected: .downloadForRequest,
                confirmation: confirmation
            )
            _ = try await URLSessionSender(transport: transport).sendDownload(request, options: options)
        }
    }
    
    @Test func `Send a download request with a body`() async throws {
        let request = Request(.get, url: url) {
            Body { "Test" }
        }
        try await confirmation { confirmation in
            let transport = MockTransport(
                request: request,
                options: options,
                expected: .downloadForRequest,
                confirmation: confirmation
            )
            _ = try await URLSessionSender(transport: transport).sendDownload(request, options: options)
        }
    }
}
