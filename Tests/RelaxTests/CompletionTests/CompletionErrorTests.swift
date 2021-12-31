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
@testable import Relax

final class CompletionErrorTests: XCTestCase {
    var session: URLSession!
    
    override func setUp() {
        session = URLSession.sessionWithMock
    }
    
    override func tearDown() {
        session = nil
        URLProtocolMock.mock = nil
    }
    
    private func requestError(error: RequestError) throws {
        let expectation = self.expectation(description: "Expect")
        URLProtocolMock.mock = URLProtocolMock.mockError(requestError: error)
        ExampleService().request(ExampleService.Get(), session: session) { result in
            switch result {
            case .failure(let receivedError):
                XCTAssertEqual(error, receivedError)
            case .success(_):
                XCTFail("Expected to fail with error")
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1)
    }
    
    func testBadRequestError() throws {
        try requestError(error: RequestError.httpBadRequest(request: ExampleService.Get().urlRequest))
    }
    
    func testUnauthorizedError() throws {
        try requestError(error: RequestError.httpUnauthorized(request: ExampleService.Get().urlRequest))
    }
    
    func testNotFoundError() throws {
        try requestError(error: RequestError.httpNotFound(request: ExampleService.Get().urlRequest))
    }
    
    func testServerError() throws {
        try requestError(error: RequestError.httpServerError(request: ExampleService.Get().urlRequest, httpStatus: 500))
    }
    
    func testOtherHTTPError() throws {
        try requestError(error: RequestError.otherHTTPError(request: ExampleService.Get().urlRequest, httpStatus: 999))
    }
    
    func testOtherError() throws {
        try requestError(error: RequestError.other(request: ExampleService.Get().urlRequest, message: "Other error occurred"))
    }
    
    func testURLError() throws {
        let expectation = self.expectation(description: "expect")
        let expectedError = URLError(.badURL)
        URLProtocolMock.mock = URLProtocolMock.mockError(requestError: .urlError(request: ExampleService.Get().urlRequest, error: expectedError))
        
        ExampleService().request(ExampleService.Get(), session: session) { result in
            switch result {
            case .failure(let requestError):
                if case let .urlError(_, error) = requestError {
                    XCTAssertEqual(error.code, expectedError.code)
                } else {
                    XCTFail("Wrong error type")
                }
            case .success:
                XCTFail()
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testNonHTTPURLResponse() throws {
        let expectation = self.expectation(description: "expect")
        let expectedError = URLError(.unknown)
        let response = URLResponse(url: URL(string: "https://example.com/")!, mimeType: nil, expectedContentLength: -1, textEncodingName: nil)
        URLProtocolMock.mock = { request in (response, nil, nil, 0) }
        
        ExampleService().request(ExampleService.Get(), session: session) { result in
            switch result {
            case .failure(let requestError):
                if case let .urlError(_, error) = requestError {
                    XCTAssertEqual(error.code, expectedError.code)
                } else {
                    XCTFail("Wrong error type")
                }
            case .success:
                XCTFail()
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
}
#endif
