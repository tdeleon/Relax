//
//  File.swift
//  
//
//  Created by Thomas De Leon on 11/11/21.
//

#if !os(watchOS) && swift(>=5.5)
import XCTest
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
@testable import Relax

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
final class AsyncRequestTests: XCTestCase {
    var session: URLSession!
    
    override func setUpWithError() throws {
        session = URLSession.sessionWithMock
    }
    
    override func tearDownWithError() throws {
        session = nil
        URLProtocolMock.mock = nil
    }
    
    let service = ExampleService.self
    
    private func makeSuccess(request: some Request) async throws {
        URLProtocolMock.mock = URLProtocolMock.mockResponse()
        
        let result = try await request.send(session: session)
        XCTAssertEqual(request.urlRequest, result.request)
    }
    
    func testGet() async throws {
        try await makeSuccess(request: self.service.Get())
    }
    
    func testPost() async throws {
        try await makeSuccess(request: self.service.Post())
    }
    
    func testPatch() async throws {
        try await makeSuccess(request: self.service.Patch())
    }
    
    func testPut() async throws {
        try await makeSuccess(request: self.service.Put())
    }
    
    func testDelete() async throws {
        try await makeSuccess(request: self.service.Delete())
    }
    
    func testComplexRequest() async throws {
        try await makeSuccess(request: self.service.ExampleEndpoint.Complex())
    }
    
    func testNoContentType() async throws {
        try await makeSuccess(request: self.service.NoContentType())
    }
}
#endif
