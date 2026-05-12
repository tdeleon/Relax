////
////  AsyncErrorTests.swift
////  
////
////  Created by Thomas De Leon on 11/11/21.
////
//
//#if swift(>=5.5)
//import XCTest
//#if canImport(FoundationNetworking)
//@preconcurrency import FoundationNetworking
//#endif
//import URLMock
//@testable import Relax
//
//@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
//final class AsyncErrorTests: ErrorTest {
//    
//    private func requestError(expected: RequestError) async {
//        let session = URLMock.session()
//        URLMock.response = .mock(error: expected)
//        
//        do {
//            _ = try await request.send(session: session)
//            XCTFail("Should fail")
//        } catch {
//            XCTAssertEqual(error as? RequestError, expected)
//        }
//    }
//    
//    func testHttpError() async throws {
//        throw XCTSkip("To be fixed in rewrite")
//
//        await requestError(expected: httpError)
//    }
//    
//    func testURLError() async throws {
//        throw XCTSkip("To be fixed in rewrite")
//
//        #if os(watchOS)
//        throw XCTSkip("Not supported on watchOS")
//        #else
//        await requestError(expected: urlError)
//        #endif
//    }
//    
//    func testDecodingError() async {
//        URLMock.response = .mock()
//        do {
//            let _: TestItem = try await request.send(session: URLMock.session())
//            XCTFail("Should fail")
//        } catch {
//            if case .decoding(_, _) = (error as? RequestError) { return }
//            XCTFail("Wrong error")
//        }
//    }
//    
//    func testOtherError() async throws {
//        throw XCTSkip("To be fixed in rewrite")
//
//        #if os(watchOS)
//        throw XCTSkip("Not supported on watchOS")
//        #else
//        await requestError(expected: otherError)
//        #endif
//    }
//}
//#endif
