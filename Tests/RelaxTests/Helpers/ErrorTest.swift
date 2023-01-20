//
//  ErrorTest.swift
//  
//
//  Created by Thomas De Leon on 1/18/23.
//

import XCTest
@testable import Relax

class ErrorTest: XCTestCase {
    var session: URLSession!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        session = .sessionWithMock
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        session = nil
        URLProtocolMock.mock = nil
    }
    
    struct TestItem: Codable {
        let name: String
    }
    
    let request = ExampleService.get
    
    var httpError: RequestError {
        .httpStatus(request: request, error: .mock(400, request: request)!)
    }
    
    var urlError: RequestError {
        .urlError(request: request, error: .init(.badURL))
    }
    
    var decodingError: RequestError {
        enum TestKey: String, CodingKey {
            case test
        }
        let error = DecodingError.dataCorrupted(.init(codingPath: [TestKey.test], debugDescription: "failed"))
        return .decoding(request: request, error: error)
    }
    
    var otherError: RequestError {
        .other(request: request, message: "Failure")
    }
}
