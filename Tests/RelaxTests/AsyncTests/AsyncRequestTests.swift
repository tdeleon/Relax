//
//  File.swift
//  
//
//  Created by Thomas De Leon on 11/11/21.
//

import XCTest
@testable import Relax

@available(iOS 15.0, macOS 12.0, *)
final class AsyncRequestTests: XCTestCase {
    var session: URLSession!
    
    override func setUpWithError() throws {
        session = URLSession.sessionWithMock
    }
    
    override func tearDownWithError() throws {
        session = nil
        URLProtocolMock.mock = nil
    }
    
    let service = ExampleService()
    
    private func makeSuccess<Request: ServiceRequest>(request: Request) async throws {
        URLProtocolMock.mock = URLProtocolMock.mockResponse()
        
        let result = try await service.request(request)
        service.checkSuccess(request: request, received: result.request)
    }
    
    func testGet() async throws {
        try await makeSuccess(request: type(of: self.service).Get())
    }
    
    func testPost() async throws {
        try await makeSuccess(request: type(of: self.service).Get())
    }
    
    func testPatch() async throws {
        try await makeSuccess(request: type(of: self.service).Get())
    }
    
    func testPut() async throws {
        try await makeSuccess(request: type(of: self.service).Get())
    }
    
    func testDelete() async throws {
        try await makeSuccess(request: type(of: self.service).Get())
    }
    
    func testComplexRequest() async throws {
        try await makeSuccess(request: type(of: self.service).NoContentType())
    }
}
