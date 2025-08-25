//
//  AsyncCancellationTests.swift
//  
//
//  Created by Thomas De Leon on 7/17/23.
//

#if swift(>=5.5)
import XCTest
#if canImport(FoundationNetworking)
@preconcurrency import FoundationNetworking
#endif
import URLMock
@testable import Relax

@MainActor
final class AsyncCancellationTests: XCTestCase {
    
    // Tasks cancelled immediately return a CancellationError, since the URLSession task hasn't been started yet
    func testImmediateCancellation() async throws {
        throw XCTSkip("To be fixed in rewrite")
        let session = URLMock.session(.mock(delay: 5))
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
        await fulfillment(of: [expectation])
    }
    
    #if !os(Windows) && !os(Linux)
    // Disable on Windows/Linux- test delay does not seem to be simulated properly
    // Tasks cancelled after a delay return a URLError.cancelled, since the URLSession task is already in progress
    func testDelayedCancellation() async throws {
        throw XCTSkip("To be fixed in rewrite")
        let session = URLMock.session(.mock(delay: 5))
        let expectation = self.expectation(description: "Expected cancellation")
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
        try await Task.sleep(for: .seconds(1))
        task.cancel()
        
        await fulfillment(of: [expectation])
    }
    #endif
}
#endif
