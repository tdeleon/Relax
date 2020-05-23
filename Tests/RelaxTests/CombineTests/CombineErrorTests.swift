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
        cancellable = ExampleService().request(ExampleService.Get(), session: session)
            .sink(receiveCompletion: { (completion) in
                switch completion {
                case .failure(let receivedError):
                    XCTAssertEqual(receivedError, error)
                    break
                case .finished:
                    break
                }
                expectation.fulfill()
            }, receiveValue: { (received) in
                XCTFail("Expected to fail with an error")
            })
        
        waitForExpectations(timeout: 3)
    }
    
    func testBadRequestError() throws {
        try requestError(error: RequestError.httpBadRequest(request: URLRequest(request: ExampleService.Get(), baseURL: ExampleService().baseURL)!))
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
        try requestError(error: RequestError.urlError(request: ExampleService.Get().urlRequest, error: URLError(.badURL)))
    }
    
}
#endif
