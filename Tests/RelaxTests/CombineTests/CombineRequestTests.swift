//
//  CombineRequestTests.swift
//  
//
//  Created by Thomas De Leon on 5/21/20.
//

#if os(macOS) || os(iOS) || os(tvOS)
import XCTest
import Combine
@testable import Relax

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
final class CombineRequestTests: XCTestCase {
    var cancellable: AnyCancellable?
    
    var session: URLSession!
        
    override func setUp() {
        session = URLSession.sessionWithMock
    }
    
    override func tearDown() {
        cancellable = nil
        session = nil
        URLProtocolMock.mock = nil
    }
    
    private func makeSuccess<Request: ServiceRequest>(request: Request) throws {
        let expectation = self.expectation(description: "Expect")
        URLProtocolMock.mock = URLProtocolMock.mockResponse()
        let service = ExampleService()
        cancellable = service.request(request, session: session)
            .sink(receiveCompletion: { (completion) in
                switch completion {
                case .failure(let error):
                    XCTFail("Request failed with error - \(error)")
                case .finished:
                    break
                }
                expectation.fulfill()
            }, receiveValue: { (received) in
                service.checkSuccess(request: request, received: received.request)
            })
        
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
