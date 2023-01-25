//
//  RequestErrorTests.swift
//  
//
//  Created by Thomas De Leon on 1/24/23.
//

import XCTest
@testable import Relax

final class HTTPErrorTests: XCTestCase {
    func response(statusCode: Int) -> Request.Response {
        let request = Request(.get, url: URL(string: "https://example.com")!)
        let urlResponse = HTTPURLResponse(url: request.url!, statusCode: statusCode, httpVersion: nil, headerFields: nil)!
        return (request, urlResponse, Data())
    }
    
    func checkHTTPError(statusCode: Int, type: HTTPError.HTTPErrorType?) throws {
        let response = response(statusCode: statusCode)
        let error = HTTPError(response: response)
        guard let type else {
            XCTAssertNil(error)
            return
        }
        let unwrappedError = try XCTUnwrap(error)
        
        XCTAssertEqual(unwrappedError.type, type)
        XCTAssertEqual(unwrappedError.statusCode, statusCode)
        XCTAssertEqual(unwrappedError.localizedDescription, HTTPURLResponse.localizedString(forStatusCode: statusCode))
        XCTAssertEqual(unwrappedError.response.response, response.response)
        XCTAssertEqual(unwrappedError.response.request, response.request)
        XCTAssertEqual(unwrappedError.response.data, response.data)
        XCTAssertEqual(unwrappedError, unwrappedError)
    }
    
    func testHTTPErrorFromStatusCode() throws {
        for code in 100...399 {
            try checkHTTPError(statusCode: code, type: nil)
        }
        try checkHTTPError(statusCode: 400, type: .badRequest)
        try checkHTTPError(statusCode: 401, type: .unauthorized)
        try checkHTTPError(statusCode: 403, type: .forbidden)
        try checkHTTPError(statusCode: 404, type: .notFound)
        try checkHTTPError(statusCode: 429, type: .tooManyRequests)
        for code in 500...599 {
            try checkHTTPError(statusCode: code, type: .server)
        }
        try checkHTTPError(statusCode: 600, type: .other)
    }
}
