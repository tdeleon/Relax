//
//  AsyncErrorTests.swift
//  
//
//  Created by Thomas De Leon on 11/11/21.
//

import XCTest
@testable import Relax

@available(iOS 15.0, macOS 12.0.0, *)
final class AsyncErrorTests: XCTestCase {
    var session: URLSession!
    
    override func setUpWithError() throws {
        session = URLSession.sessionWithMock
    }
    
    override func tearDownWithError() throws {
        session = nil
        URLProtocolMock.mock = nil
    }
    
    let method = ExampleService.Get()
    
    private func requestError(expected: RequestError) async {
        URLProtocolMock.mock = URLProtocolMock.mockError(requestError: expected)
        
        do {
            _ = try await ExampleService().request(ExampleService.Get(), session: session)
            XCTFail("Should fail")
        } catch {
            XCTAssertEqual(error as? RequestError, expected)
        }
    }
    
    func testBadRequestError() async {
        await requestError(expected: .httpBadRequest(request: URLRequest(request: method, baseURL: ExampleService().baseURL)!))
    }
    
    func testUnauthorizedError() async {
        await requestError(expected: .httpUnauthorized(request: method.urlRequest))
    }
    
    func testNotFoundError() async {
        await requestError(expected: .httpNotFound(request: method.urlRequest))
    }
    
    func testServerError() async {
        await requestError(expected: .httpServerError(request: method.urlRequest, httpStatus: 500))
    }
    
    func testOtherHTTPError() async {
        await requestError(expected: .otherHTTPError(request: method.urlRequest, httpStatus: 999))
    }
    
    func testURLError() async {
        let expectedError = URLError(.badURL)
        let testRequest = ExampleService.Get()
        URLProtocolMock.mock = URLProtocolMock.mockError(requestError: .urlError(request: testRequest.urlRequest, error: expectedError))
        do {
            _ = try await ExampleService().request(testRequest, session: session)
            XCTFail("Should fail")
        } catch {
            if case let .urlError(_, urlError) = error as? RequestError {
                XCTAssertEqual(urlError.code, expectedError.code)
            } else {
                XCTFail("Wrong error type")
            }
        }
        
    }
}
