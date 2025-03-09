//
//  CombineTests.swift
//  
//
//  Created by Thomas De Leon on 5/20/20.
//

#if canImport(Combine)
import XCTest
import Combine
import URLMock
@testable import Relax

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
final class CombineErrorTests: ErrorTest {
    var cancellable: AnyCancellable?
    
    override func tearDown() {
        super.tearDown()
        cancellable = nil
    }
        
    @MainActor private func requestError(expected: RequestError) throws {
        let expectation = self.expectation(description: "Expect")
        URLMock.response = .mock(error: expected)
        cancellable = request.send(session: session)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let receivedError):
                    XCTAssertEqual(receivedError, expected)
                case .finished:
                    break
                }
                expectation.fulfill()
            }, receiveValue: { _ in
                XCTFail("Expected to fail with an error")
            })
        
        waitForExpectations(timeout: 1)
    }
    
    @MainActor func testHTTPError() throws {
        try requestError(expected: httpError)
    }
    
    @MainActor func testURLError() throws {
        #if os(watchOS)
        throw XCTSkip("Not supported on watchOS")
        #else
        try requestError(expected: urlError)
        #endif
    }
    
    @MainActor func testDecodingError() throws {
        URLMock.response = .mock()
        let expectation = self.expectation(description: "Expect")

        cancellable = request.send(session: session)
            .sink { completion in
                defer { expectation.fulfill() }
                switch completion {
                case .failure(let receivedError):
                    if case .decoding(_, _) = receivedError { break }
                    XCTFail("Wrong error")
                case .finished:
                    break
                }
            } receiveValue: { (item: TestItem) in
                XCTFail("Expected to fail")
            }
        
        waitForExpectations(timeout: 1)
    }
}
#endif
