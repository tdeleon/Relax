//
//  CompletionErrorTests.swift
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

final class CompletionErrorTests: XCTestCase {
    var session: URLSession!
    
    override class func setUp() {
        
    }
    
    override func tearDown() {
        session = nil
    }
    
    private func requestError(error: RequestError) throws {
        let expectation = self.expectation(description: "Expect")
        session = MockURLSession(requestError: error)
        ExampleService().request(ExampleService.Get(), session: session) { (result) in
            switch result {
            case .failure(let receivedError):
                XCTAssertEqual(error, receivedError)
            case .success(_):
                XCTFail("Expected to fail with error")
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 3)
    }
    
    func testBadRequestError() throws {
        try requestError(error: RequestError.badRequest(request: ExampleService.Get().urlRequest))
    }
    
    func testUnauthorizedError() throws {
        try requestError(error: RequestError.unauthorized(request: ExampleService.Get().urlRequest))
    }
    
    func testNotFoundError() throws {
        try requestError(error: RequestError.notFound(request: ExampleService.Get().urlRequest))
    }
    
    func testServerError() throws {
        try requestError(error: RequestError.serverError(request: ExampleService.Get().urlRequest, status: 500))
    }
    
    func testOtherHTTPError() throws {
        try requestError(error: RequestError.otherHTTP(request: ExampleService.Get().urlRequest, status: 999))
    }
    
    func testURLError() throws {
        try requestError(error: RequestError.urlError(request: ExampleService.Get().urlRequest, error: URLError(.badURL)))
    }
    
    func testNoResponseError() throws {
        try requestError(error: RequestError.noResponse(request: ExampleService.Get().urlRequest))
    }
    
    func testOtherError() throws {
        try requestError(error: RequestError.other(request: ExampleService.Get().urlRequest, message: "Other error occurred"))
    }
    
}
#endif
