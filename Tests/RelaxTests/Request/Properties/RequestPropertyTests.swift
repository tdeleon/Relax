//
//  RequestPropertyTests.swift
//  
//
//  Created by Thomas De Leon on 1/22/23.
//

import XCTest
@testable import Relax

final class RequestPropertyTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    let testURL = URL(string: "https://example.com")!
    
    func testAdd() {
        let first = RequestProperties(headers: .init(value: ["first": "value"]))
        let second = RequestProperties(queryItems: .init(value: [.init(name: "second", value: "value")]))
        
        let combined = first + second
        
        XCTAssertEqual(combined.headers, first.headers)
        XCTAssertEqual(combined.queryItems, second.queryItems)
    }

    func testBuildEmpty() {
        @RequestPropertiesBuilder
        func empty() -> RequestProperties {}
        XCTAssertEqual(empty(), RequestProperties.empty)
    }
    
    func testBuild() {
        let expectedProperties = RequestProperties(
            headers: Headers(value: ["key": "value"]),
            queryItems: QueryItems(value: [.init(name: "name", value: "value")]),
            pathComponents: PathComponents(value: ["test"]),
            body: Body(value: "Test".data(using: .utf8))
        )
        
        @RequestPropertiesBuilder
        var properties: RequestProperties {
            expectedProperties.pathComponents
            expectedProperties.queryItems
            expectedProperties.headers
            expectedProperties.body
        }
        
        XCTAssertEqual(properties, expectedProperties)
        
    }
    
}
