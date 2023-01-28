//
//  RequestErrorTests.swift
//  
//
//  Created by Thomas De Leon on 1/24/23.
//

import XCTest
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
@testable import Relax

final class RequestErrorTests: XCTestCase {
    let request = Request(.get, url: URL(string: "https://example.com")!)

    func testLocalizedDescription() throws {
        let urlError = URLError(.badURL)
        XCTAssertEqual(RequestError.urlError(request: request, error: urlError).localizedDescription, urlError.localizedDescription)
        
        enum Coding: String, CodingKey { case test }
        let decodingError = DecodingError.dataCorrupted(.init(codingPath: [Coding.test], debugDescription: "test"))
        XCTAssertEqual(RequestError.decoding(request: request, error: decodingError).localizedDescription, decodingError.localizedDescription)
        
        let httpError = try XCTUnwrap(RequestError.HTTPError.mock(404, request: request))
        XCTAssertEqual(RequestError.httpStatus(request: request, error: httpError).localizedDescription, httpError.localizedDescription)
        
        let message = "This is a test"
        XCTAssertEqual(RequestError.other(request: request, message: message).localizedDescription, message)
    }
    
    func testEquality() {
        let urlError = RequestError.urlError(request: request, error: URLError(.badURL))
        let otherError = RequestError.other(request: request, message: "Testing...")
        let httpError = RequestError.httpStatus(request: request, error: .mock(404, request: request)!)
        
        XCTAssertEqual(urlError, urlError)
        XCTAssertNotEqual(urlError, httpError)
        XCTAssertEqual(httpError, httpError)
        XCTAssertNotEqual(httpError, otherError)
        XCTAssertEqual(otherError, otherError)
    }

}
