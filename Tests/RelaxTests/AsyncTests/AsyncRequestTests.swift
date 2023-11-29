//
//  AsyncRequestTests.swift
//  
//
//  Created by Thomas De Leon on 11/11/21.
//

#if swift(>=5.5)
import XCTest
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import URLMock
@testable import Relax

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
final class AsyncRequestTests: XCTestCase {
    var session: URLSession!
    
    override func setUpWithError() throws {
        session = URLMock.session()
    }
    
    override func tearDownWithError() throws {
        session = nil
    }
    
    let service = ExampleService.self
    
    private func makeSuccess(request: Request) async throws {
        URLMock.response = .mock()
        
        let result = try await request.send(session: session)
        XCTAssertEqual(request.urlRequest, result.request.urlRequest)
    }
    
    func testGet() async throws {
        try await makeSuccess(request: service.get)
    }
    
    func testPost() async throws {
        try await makeSuccess(request: service.BasicRequests.post)
    }
    
    func testPatch() async throws {
        try await makeSuccess(request: service.BasicRequests.patch)
    }
    
    func testPut() async throws {
        try await makeSuccess(request: service.BasicRequests.put)
    }
    
    func testDelete() async throws {
        try await makeSuccess(request: service.BasicRequests.delete)
    }
    
    func testComplexRequest() async throws {
        try await makeSuccess(request: service.ComplexRequests.complex)
    }
}
#endif
