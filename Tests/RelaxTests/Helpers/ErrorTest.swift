//
//  ErrorTest.swift
//  
//
//  Created by Thomas De Leon on 1/18/23.
//

import XCTest
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import URLMock
@testable import Relax

class ErrorTest: XCTestCase {
    var session: URLSession!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        session = .mock()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        session = nil
    }
    
    struct TestItem: Codable {
        let name: String
    }
    
    let request = ExampleService.get.setting(.init(parseHTTPStatusErrors: true))
    
    var httpError: RequestError {
        .httpStatus(request: request, error: .mock(400, request: request)!)
    }
    
    var urlError: RequestError {
        .urlError(request: request, error: .init(.badURL))
    }
    
    var otherError: RequestError {
        .other(request: request, message: "Failure")
    }
}
