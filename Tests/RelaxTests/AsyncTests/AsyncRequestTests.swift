//
//  File.swift
//  
//
//  Created by Thomas De Leon on 11/11/21.
//

#if os(macOS) || os(iOS) || os(tvOS) // Async has not been implemented in FoundationNetworking (Linux/Windows) yet
//#if !os(watchOS) && swift(>=5.5) - uncomment when support is added
import XCTest
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
@testable import Relax

@available(iOS 15.0, macOS 12.0, tvOS 15.0, *)
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
#endif
