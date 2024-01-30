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
    
    #if swift(>=5.9)
    // fulfillment(of:) only available on swift 5.9+
    func testOverrideSession() async throws {
        let expectation = self.expectation(description: "Mock received")
        let expectedSession = URLMock.session(.mock { _ in
            expectation.fulfill()
        })
        
        let override = Request(.get, parent: InheritService.User.self, session: expectedSession)
        try await override.send()
        
        await fulfillment(of: [expectation], timeout: 1)
    }
    
    func testOverrideSessionOnSendAsync() async throws {
        let expectation = self.expectation(description: "Mock received")
        let expectedSession = URLMock.session(.mock { _ in
            expectation.fulfill()
        })
        try await InheritService.User.get.send(session: expectedSession)
        
        await fulfillment(of: [expectation], timeout: 1)
    }
    #endif
    
    func testOverrideDecoderOnSend() async throws {
        let model = InheritService.User.Response(date: Date())
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let session = URLMock.session(.mock(model, encoder: encoder))
        
        // send request - the defined JSONDecoder on InheritService has 8601 date decoding strategy
        let _: InheritService.User.Response = try await InheritService.User.get.send(session: session)
        
        do {
            // send request, overriding the inherited decoder with default - should fail to parse
            let _: InheritService.User.Response = try await InheritService.User.get.send(decoder: JSONDecoder(), session: session)
            XCTFail("Should have failed")
        } catch {
            XCTAssertTrue(error is RequestError)
        }
    }
}
#endif
