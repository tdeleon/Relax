//
//  MockSenderTests.swift
//  Relax
//
//  Created by Thomas De Leon on 5/15/26.
//

import Foundation
import Testing
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import HTTPTypes

@testable import Relax

struct MockSenderTests {
    
    struct User: Codable, Hashable, Sendable {
        let id: Int
    }

    let request = Request(.get, url: URL(string: "https://example.com/")!)
    
    @Test func `Initializing a mock`() async throws {
        let data = try #require("Test".data(using: .utf8))
        let response = HTTPResponse(status: .ok)
        let delay: TimeInterval = 8
        let error = URLError(.badURL)
        
        let mock = MockSender(response: { (data, response) }, delay: delay, error: error)
        
        #expect(mock.response().0 == data)
        #expect(mock.response().1 == response)
        #expect(mock.delay == delay)
        #expect(mock.error as? URLError == error)
    }

    @Test func `Convenience returning codable`() async throws {
        let user = User(id: 1)
        let userData = try JSONEncoder().encode(user)
        let status = HTTPResponse.Status.accepted
        let headers = HTTPFields {
            HTTPField(name: .accept, value: "application/json")
        }
        let delay = TimeInterval(3)
        
        let mock = try MockSender.returning(status, object: user, headers: headers, delay: delay)
        
        #expect(mock.response().0 == userData)
        #expect(mock.response().1 == HTTPResponse(status: status, headerFields: headers))
        #expect(mock.delay == delay)
        #expect(mock.error == nil)
    }
    
    @Test func `Convenience returning data`() async throws {
        let data = try #require("Test".data(using: .utf8))
        let status = HTTPResponse.Status.accepted
        let headers = HTTPFields {
            HTTPField(name: .accept, value: "application/json")
        }
        let delay = TimeInterval(3)
        
        let mock = MockSender.returning(status, data: data, headers: headers, delay: delay)
        
        #expect(mock.response().0 == data)
        #expect(mock.response().1 == HTTPResponse(status: status, headerFields: headers))
        #expect(mock.delay == delay)
        #expect(mock.error == nil)
    }
    
    @Test func `Send request`() async throws {
        let data = try #require("Result".data(using: .utf8))
        let mock = MockSender.returning(data: data)
                
        let (receivedData, httpResponse) = try await mock.send(request)
        
        #expect(receivedData == data)
        #expect(httpResponse.status == .ok)
    }
    
    @Test func `Send request expecting a codable response`() async throws {
        let user = User(id: 3)
        let data = try JSONEncoder().encode(user)
        let mock = MockSender.returning(data: data)
                
        let (receivedUser, httpResponse) = try await mock.send(request, decoding: User.self)
        
        #expect(receivedUser == user)
        #expect(httpResponse.status == .ok)
    }
    
    @Test func `Send with file`() async throws {
        let data = try #require("Upload".data(using: .utf8))
        
        let mock = MockSender.returning(data: data)
        let (receivedData, _) = try await mock.send(request, withFile: URL.temporaryDirectory)
        #expect(receivedData == data)
    }
    
    @Test func `Send download`() async throws {
        let data = try #require("Result".data(using: .utf8))
        let mock = MockSender.returning(data: data)
        
        let (file, _) = try await mock.sendDownload(request)
        
        let receivedData = try Data(contentsOf: file)
        #expect(receivedData == data)
    }
    
    @Test func `Send download expecting error`() async throws {
        let error = URLError(.networkConnectionLost)
        let mock = MockSender.returning(error: error)
        
        await #expect(throws: error) {
            _ = try await mock.sendDownload(request)
        }
    }
    
    @Test func `Send expecting error`() async throws {
        let error = URLError(.badURL)
        let mock = MockSender.returning(error: error)
        
        await #expect(throws: error) {
            _ = try await mock.send(request)
        }
    }
}
