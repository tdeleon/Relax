//
//  AsyncCancellationTests.swift
//  
//
//  Created by Thomas De Leon on 7/17/23.
//

#if swift(>=5.5)
import Foundation
import Testing
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import URLMock
@testable import Relax

@Suite("Test async cancellation")
struct AsyncCancellationTests {
    let session = URLMock.session(.mock(delay: 5))
    
    @Test("Cancel task immediately")
    func testImmediateCancellation() throws {
        let task = Task {
            await confirmation("CancellationError should be thrown") { confirmation in
                do {
                    try await ExampleService.get
                        .send(session: session)
                    Issue.record()
                } catch is CancellationError {
                    confirmation.confirm()
                } catch {
                    Issue.record()
                }
            }
        }
        task.cancel()
    }
    
    #if !os(Windows) && !os(Linux)
    // Disable on Windows/Linux- test delay does not seem to be simulated properly
    @Test("Cancel task after delay")
    func testDelayedCancellation() throws {
        let task = Task {
            await confirmation("URLSession task is in progress- URLError.cancelled should be thrown") { confirmation in
                do {
                    try await ExampleService.get
                        .send(session: session)
                    Issue.record()
                } catch RequestError.urlError(_, let urlError) where urlError.code == .cancelled {
                    confirmation.confirm()
                } catch {
                    Issue.record()
                }
            }
        }
        Thread.sleep(forTimeInterval: 1)
        task.cancel()
    }
    #endif
}
#endif
