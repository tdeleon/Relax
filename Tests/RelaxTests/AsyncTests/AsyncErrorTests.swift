//
//  AsyncErrorTests.swift
//  
//
//  Created by Thomas De Leon on 11/11/21.
//

#if !os(watchOS) && swift(>=5.5)
import XCTest
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
@testable import Relax

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
final class AsyncErrorTests: ErrorTest {
    
    private func requestError(expected: RequestError) async {
        URLProtocolMock.mock = URLProtocolMock.mockError(requestError: expected)
        
        do {
            _ = try await request.send(session: session, parseHTTPStatusErrors: true)
            XCTFail("Should fail")
        } catch {
            XCTAssertEqual(error as? RequestError, expected)
        }
    }
    
    func testHttpError() async throws {
        await requestError(expected: httpError)
    }
    
    func testURLError() async {
        await requestError(expected: urlError)
    }
    
    func testDecodingError() async {
        URLProtocolMock.mock = URLProtocolMock.mockError(requestError: decodingError)
        do {
            let _: TestItem = try await request.send(session: session)
            XCTFail("Should fail")
        } catch {
            if case .decoding(_, _) = (error as? RequestError) { return }
            XCTFail("Wrong error")
        }
    }
    
    func testOtherError() async {
        await requestError(expected: otherError)
    }
}
#endif
