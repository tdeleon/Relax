//
//  AsyncErrorTests.swift
//  
//
//  Created by Thomas De Leon on 11/11/21.
//

#if swift(>=5.5)
import XCTest
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import URLMock
@testable import Relax

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
final class AsyncErrorTests: ErrorTest {
    
    private func requestError(expected: RequestError) async {
        URLMock.response = .mock(error: expected)
        
        do {
            _ = try await request.send(session: session)
            XCTFail("Should fail")
        } catch {
            XCTAssertEqual(error as? RequestError, expected)
        }
    }
    
    func testHttpError() async throws {
        await requestError(expected: httpError)
    }
    
    func testURLError() async throws {
        #if os(watchOS)
        throw XCTSkip("Not supported on watchOS")
        #else
        await requestError(expected: urlError)
        #endif
    }
    
    func testDecodingError() async {
        URLMock.response = .mock()
        do {
            let _: TestItem = try await request.send(session: session)
            XCTFail("Should fail")
        } catch {
            if case .decoding(_, _) = (error as? RequestError) { return }
            XCTFail("Wrong error")
        }
    }
    
    func testOtherError() async throws {
        #if os(watchOS)
        throw XCTSkip("Not supported on watchOS")
        #else
        await requestError(expected: otherError)
        #endif
    }
}
#endif
