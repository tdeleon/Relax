//
//  ErrorTest.swift
//  
//
//  Created by Thomas De Leon on 1/18/23.
//

import XCTest
#if canImport(FoundationNetworking)
@preconcurrency import FoundationNetworking
#endif
import URLMock
@testable import Relax

class ErrorTest: XCTestCase {
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
