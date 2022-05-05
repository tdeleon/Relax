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
    
    let service = ExampleService()
    
    private func makeSuccess<Request: ServiceRequest>(request: Request) async throws {
        URLProtocolMock.mock = URLProtocolMock.mockResponse()
        
        let result = try await service.request(request, session: session)
        service.checkSuccess(request: request, received: result.request)
    }
    
    func testGet() async throws {
        try await makeSuccess(request: type(of: self.service).Get())
    }
    
    func testPost() async throws {
        try await makeSuccess(request: type(of: self.service).Post())
    }
    
    func testPatch() async throws {
        try await makeSuccess(request: type(of: self.service).Patch())
    }
    
    func testPut() async throws {
        try await makeSuccess(request: type(of: self.service).Put())
    }
    
    func testDelete() async throws {
        try await makeSuccess(request: type(of: self.service).Delete())
    }
    
    func testComplexRequest() async throws {
        try await makeSuccess(request: type(of: self.service).ExampleEndpoint.Complex())
    }
    
    func testNoContentType() async throws {
        try await makeSuccess(request: type(of: self.service).NoContentType())
    }
}
#endif
