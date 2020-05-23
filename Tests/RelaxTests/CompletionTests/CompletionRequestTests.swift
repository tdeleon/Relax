//
//  CompletionRequestTests.swift
//  
//
//  Created by Thomas De Leon on 5/21/20.
//

#if !os(watchOS)
import XCTest
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
@testable import Relax

final class CompletionRequestTests: XCTestCase {
    var session: URLSession!
    
    override func setUp() {
        let configuration = URLSessionConfiguration.default
        configuration.protocolClasses = [URLProtocolMock.self]
        session = URLSession(configuration: configuration)
    }
    
    override func tearDown() {
        session = nil
        URLProtocolMock.mock = nil
    }
    
    private func makeSuccess<Request: ServiceRequest>(request: Request) throws {
        let expectation = self.expectation(description: "Expect")
        URLProtocolMock.mock = { request in
            let response = HTTPURLResponse(url: URL(string: "http://example.com/")!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, nil, nil,0)
        }
        let service = ExampleService()
        service.request(request, session: session) { (result) in
            switch result {
            case .failure(let error):
                XCTFail("Request failed with error - \(error)")
            case .success(let received):
                service.checkSuccess(request: request, received: received.request)
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 3)
    }
    
    func testGet() throws {
        try makeSuccess(request: ExampleService.Get())
    }
    
    func testPost() throws {
        try makeSuccess(request: ExampleService.Post())
    }
    
    func testPatch() throws {
        try makeSuccess(request: ExampleService.Patch())
    }
    
    func testPut() throws {
        try makeSuccess(request: ExampleService.Put())
    }
    
    func testDelete() throws {
        try makeSuccess(request: ExampleService.Delete())
    }
    
    func testComplexRequest() throws {
        try makeSuccess(request: ExampleService.Complex())
    }
    
    func testNoContentType() throws {
        try makeSuccess(request: ExampleService.NoContentType())
    }
}
#endif
