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
import MockURLSession
@testable import Relax

final class CompletionRequestTests: XCTestCase {
    var session: URLSession!
    
    override class func setUp() {
        
    }
    
    override func tearDown() {
        session = nil
    }
    
    private func makeSuccess<Request: ServiceRequest>(request: Request) throws {
        let expectation = self.expectation(description: "Expect")
        session = MockURLSession()
        ExampleService().request(request, session: session) { (result) in
            switch result {
            case .failure(let error):
                XCTFail("Request failed with error - \(error)")
            case .success(let received):
                XCTAssertEqual(received.request.httpMethod, request.httpMethod.rawValue)
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
}
#endif
