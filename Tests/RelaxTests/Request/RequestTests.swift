//
//  RequestTests.swift
//  
//
//  Created by Thomas De Leon on 1/18/23.
//

import XCTest
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
@testable import Relax

final class RequestTests: XCTestCase {
    
    let sampleURL = URL(string: "https://example.com/")!
    
    let configuration = Request.Configuration(timeoutInterval: 1)
    
    func testInit() {
        let method = Request.HTTPMethod.post
        let request1 = Request(.post, url: sampleURL, configuration: configuration)
        XCTAssertEqual(request1.httpMethod, method)
        XCTAssertEqual(request1._properties, .empty)
        XCTAssertEqual(request1.configuration, configuration)
        
        let path = "path"
        let request2 = Request(method, url: sampleURL) {
            PathComponents { path }
        }
        XCTAssertEqual(request2._properties.pathComponents.value, [path])
        XCTAssertEqual(request2.httpMethod, method)
        
    }

    func testBasic() throws {
        let method = Request.HTTPMethod.post
        
        let request = Request(method, url: sampleURL)
        XCTAssertEqual(request._properties, .empty)
        XCTAssertEqual(request.httpMethod, method)
        XCTAssertEqual(request.url, sampleURL)
        XCTAssertEqual(request._properties.headers.value, [:])
        XCTAssertEqual(request.queryItems, [])
        XCTAssertEqual(request.pathComponents, [])
        XCTAssertNil(request.body)
        XCTAssertEqual(request.configuration, .default)
    }
    
    func testQueryParameters() {
        let method = Request.HTTPMethod.patch
        let query = URLQueryItem(name: "first", value: "value")
        var request = Request(method, url: sampleURL) {
            QueryItems {
                query
            }
        }
        XCTAssertEqual(request.queryItems, [query])
        let newQuery = URLQueryItem(name: "other", value: "value")
        request.queryItems = [newQuery]
        XCTAssertEqual(request.queryItems, [newQuery])
    }
    
    func testPathComponents() {
        let firstPath = "first"
        var request = Request(.get, url: sampleURL) {
            PathComponents {
                firstPath
            }
        }
        XCTAssertEqual(request.pathComponents, [firstPath])
        let secondPath = "second"
        request.pathComponents = [secondPath]
        XCTAssertEqual(request.pathComponents, [secondPath])
    }
    
    func testHeaders() {
        let header1 = ["name": "value"]
        var request = Request(.get, url: sampleURL) {
            Headers {
                header1
            }
        }
        XCTAssertEqual(request.headers, header1)
        let header2 = ["second": "secondvalue"]
        request.headers = header2
        XCTAssertEqual(request.headers, header2)
    }
    
    func testBody() throws {
        let body1 = try XCTUnwrap("First".data(using: .utf8))
        var request = Request(.get, url: sampleURL) {
            Body {
                body1
            }
        }
        XCTAssertEqual(request.body, body1)
        let body2 = try XCTUnwrap("Second".data(using: .utf8))
        request.body = body2
        XCTAssertEqual(request.body, body2)
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
        let properties = Request.Properties(
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
