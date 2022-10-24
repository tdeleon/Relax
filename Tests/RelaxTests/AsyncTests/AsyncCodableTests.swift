//
//  File.swift
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
final class AsyncCodableTests: XCTestCase {
    var session: URLSession!
    
    override func setUpWithError() throws {
        session = URLSession.sessionWithMock
    }
    
    override func tearDownWithError() throws {
        session = nil
        URLProtocolMock.mock = nil
    }
    
    let service = ExampleService()
    
    func testGet() async throws {
        let sampleModel = User(name: "test")
        URLProtocolMock.mock = URLProtocolMock.mockResponse(model: sampleModel)
        
        let user: User = try await ExampleService.Get().send()
        XCTAssertEqual(user, sampleModel)
        
    }
}
#endif
