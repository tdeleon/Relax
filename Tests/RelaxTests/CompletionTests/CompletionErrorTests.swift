//
//  CompletionErrorTests.swift
//  
//
//  Created by Thomas De Leon on 5/21/20.
//

import XCTest
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
@testable import Relax

final class CompletionErrorTests: ErrorTest {
        
    private func requestError(expected: RequestError) throws {
        let expectation = self.expectation(description: "Expect")
        URLProtocolMock.mock = URLProtocolMock.mockError(requestError: expected)
        request.send(session: session) { result in
            switch result {
            case .failure(let receivedError):
                XCTAssertEqual(receivedError, expected)
            case .success(_):
                XCTFail("Expected to fail with error")
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1)
    }
    
    func testHTTPError() throws {
        try requestError(expected: httpError)
    }
    
    func testURLError() throws {
        #if !os(watchOS)
        try requestError(expected: urlError)
        #endif
    }
    
    func testDecodingError() throws {
        URLProtocolMock.mock = URLProtocolMock.mockError(requestError: decodingError)
        let expectation = self.expectation(description: "Expect")
        
        request.send(decoder: JSONDecoder()) { (result: Result<Request.ResponseModel<TestItem>, RequestError>) in
            defer { expectation.fulfill() }
            switch result {
            case .failure(let error):
                if case .decoding = error { break }
                XCTFail("wrong error")
            case .success:
                XCTFail("No error")
            }
        }
        waitForExpectations(timeout: 1)
    }
    
    func testOtherError() throws {
        #if !os(watchOS)
        try requestError(expected: otherError)
        #endif
    }
}
