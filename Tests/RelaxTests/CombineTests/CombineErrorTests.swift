//
//  CombineTests.swift
//  
//
//  Created by Thomas De Leon on 5/20/20.
//

#if os(macOS) || os(iOS) || os(tvOS)
import XCTest
import Combine
@testable import Relax

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
final class CombineErrorTests: XCTestCase {
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
    
    private func requestError(error: RequestError) throws {
        let expectation = self.expectation(description: "Expect")
        URLProtocolMock.mock = URLProtocolMock.mockError(requestError: error)
        cancellable = ExampleService.Get().send(session: session)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let receivedError):
                    XCTAssertEqual(receivedError, error)
                case .finished:
                    break
                }
                expectation.fulfill()
            }, receiveValue: { _ in
                XCTFail("Expected to fail with an error")
            })
        
        waitForExpectations(timeout: 1)
    }
    
    func testBadRequestError() throws {
        try requestError(error: .httpBadRequest(request: ExampleService.Get().urlRequest))
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
    
    func testURLError() throws {
        let expectation = self.expectation(description: "URLError")
        let expectedError = URLError(.badURL)
        URLProtocolMock.mock = URLProtocolMock.mockError(requestError: .urlError(request: ExampleService.Get().urlRequest, error: expectedError))
        cancellable = ExampleService.Get().send(session: session)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let requestError):
                    if case let .urlError(_, urlError) = requestError {
                        XCTAssertEqual(urlError.code, expectedError.code)
                    } else {
                        XCTFail("Wrong error type")
                    }
                case .finished:
                    break
                }
                expectation.fulfill()
            }, receiveValue: { _ in
                XCTFail("Expected failure")
            })
        waitForExpectations(timeout: 1)
    }
    
    func testBadURL() throws {
        let expectation = self.expectation(description: "Bad URL")
        cancellable = BadURLService.Get().send(session: session)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let requestError):
                    if case let .urlError(_, urlError) = requestError {
                        XCTAssertEqual(urlError.code, URLError.badURL)
                    } else {
                        XCTFail("Wrong error type")
                    }
                case .finished:
                    break
                }
                expectation.fulfill()
            }, receiveValue: { _ in
                XCTFail("Expected failure")
            })
        waitForExpectations(timeout: 1)
    }
}
#endif
