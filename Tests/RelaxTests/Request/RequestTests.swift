//
//  RequestTests.swift
//  
//
//  Created by Thomas De Leon on 1/18/23.
//

import XCTest
@testable import Relax

final class RequestTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    let sampleURL = URL(string: "https://example.com/")!

    func testBasic() throws {
        let method = Request.HTTPMethod.post
        
        let request = Request(method, url: sampleURL)
        XCTAssertEqual(request.httpMethod, method)
        XCTAssertEqual(request.url, sampleURL)
        XCTAssertEqual(request.headers, [:])
        XCTAssertEqual(request.queryItems, [])
        XCTAssertEqual(request.pathParameters, [])
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

    
}
