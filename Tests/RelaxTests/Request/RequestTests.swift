//
//  RequestTests.swift
//  
//
//  Created by Thomas De Leon on 1/18/23.
//

import XCTest
@testable import Relax

final class RequestTests: XCTestCase {
    
    let sampleURL = URL(string: "https://example.com/")!

    func testBasic() throws {
        let method = Request.HTTPMethod.post
        
        let request = Request(method, url: sampleURL)
        XCTAssertEqual(request._properties, .empty)
        XCTAssertEqual(request.httpMethod, method)
        XCTAssertEqual(request.url, sampleURL)
        XCTAssertEqual(request.headers, [:])
        XCTAssertEqual(request.queryItems, [])
        XCTAssertEqual(request.pathComponents, [])
        XCTAssertNil(request.body)
        XCTAssertEqual(request.configuration, .default)
    }
    
    func testQueryParameters() {
        let method = Request.HTTPMethod.patch
        let query = URLQueryItem(name: "first", value: "value")
        let request = Request(method, url: sampleURL) {
            QueryItems {
                query
            }
        }
        XCTAssertEqual(request.queryItems, [query])
    }
    
    func testURL() {
        let pathComponent = "test"
        let query = URLQueryItem(name: "first", value: "value")
        let request = Request(.get, url: sampleURL) {
            PathComponents {
                pathComponent
            }
            QueryItems {
                query
            }
        }
        
        var expectedComponents = URLComponents(url: sampleURL.appendingPathComponent(pathComponent), resolvingAgainstBaseURL: true)
        expectedComponents?.queryItems = [query]
        
        XCTAssertEqual(request.url, expectedComponents?.url)
    }
    
    func testBuilder() {
        let properties = RequestProperties(
            headers: .init(value: ["first": "second"]),
            queryItems: .init(value: [.init(name: "name", value: "value")]),
            pathComponents: .init(value: ["path"]),
            body: .init(value: "test".data(using: .utf8))
        )
        
        let method = Request.HTTPMethod.get
        
        @RequestBuilder<ExampleService>
        var request: Request {
            method
            properties.headers
            properties.queryItems
            properties.pathComponents
            properties.body
        }
        
        XCTAssertEqual(request.configuration, ExampleService.configuration)
        XCTAssertEqual(request.httpMethod, method)
        XCTAssertEqual(request._properties, properties)
    }
    
}