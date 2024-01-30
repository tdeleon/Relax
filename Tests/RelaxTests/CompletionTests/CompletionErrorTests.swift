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
import URLMock
@testable import Relax

final class CompletionErrorTests: ErrorTest {
        
    private func requestError(expected: RequestError) throws {
        let expectation = self.expectation(description: "Expect")
        URLMock.response = .mock(error: expected)
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
        #if os(watchOS)
        throw XCTSkip("Not supported on watchOS")
        #else
        try requestError(expected: urlError)
        #endif
    }
    
    func testDecodingError() throws {
        URLMock.response = .mock()
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
        #if os(watchOS)
        throw XCTSkip("Not supported on watchOS")
        #else
        try requestError(expected: otherError)
        #endif
    }
}
