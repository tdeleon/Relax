//
//  CombineRequestTests.swift
//  
//
//  Created by Thomas De Leon on 5/21/20.
//

#if os(macOS) || os(iOS) || os(tvOS)
import XCTest
import Combine
import MockURLSession
@testable import Relax

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
final class CombineRequestTests: XCTestCase {
    var cancellable: AnyCancellable?
    
    var session: URLSession!
        
    override class func setUp() {
        
    }
    
    override func tearDown() {
        cancellable = nil
        session = nil
    }
    
    private func makeSuccess<Request: ServiceRequest>(request: Request) throws {
        let expectation = self.expectation(description: "Expect")
        session = MockURLSession()
        cancellable = ExampleService().request(request, session: session)
            .sink(receiveCompletion: { (completion) in
                switch completion {
                case .failure(let error):
                    XCTFail("Request failed with error - \(error)")
                case .finished:
                    break
                }
                expectation.fulfill()
            }, receiveValue: { (received) in
                XCTAssertEqual(received.request.httpMethod, request.requestType.rawValue)
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
    
}
#endif
