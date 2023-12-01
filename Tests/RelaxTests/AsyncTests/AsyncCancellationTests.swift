//
//  AsyncCancellationTests.swift
//  
//
//  Created by Thomas De Leon on 7/17/23.
//

#if swift(>=5.5)
import XCTest
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import URLMock
@testable import Relax

final class AsyncCancellationTests: XCTestCase {
    var session: URLSession!
    
    override func setUpWithError() throws {
        session = URLMock.session(.mock(delay: 5))
    }
    
    // Tasks cancelled immediately return a CancellationError, since the URLSession task hasn't been started yet
    func testImmediateCancellation() throws {
        let expectation = self.expectation(description: "Cancellation")
        let task = Task {
            do {
                try await ExampleService.get
                    .send(session: session)
                XCTFail()
            } catch is CancellationError {
                expectation.fulfill()
            } catch {
                XCTFail()
            }
        }
        task.cancel()
        waitForExpectations(timeout: 2)
    }
    
    // Tasks cancelled after a delay return a URLError.cancelled, since the URLSession task is already in progress
    func testDelayedCancellation() throws {
        let expectation = self.expectation(description: "Expected cancellation")
        let task = Task {
            do {
                try await ExampleService.get
                    .send(session: session)
                XCTFail()
            } catch RequestError.urlError(_, let urlError) where urlError.code == .cancelled {
                expectation.fulfill()
            } catch {
                XCTFail()
            }
        }
        Thread.sleep(forTimeInterval: 1)
        task.cancel()
        
        waitForExpectations(timeout: 4)
    }
}
#endif
