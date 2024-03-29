//
//  RequestPropertiesTests.swift
//  
//
//  Created by Thomas De Leon on 1/24/23.
//

import XCTest
@testable import Relax

final class RequestPropertiesTests: XCTestCase {    
    let headers = Headers(value: ["first": "second"])
    let queryItems = QueryItems(value: [.init(name: "name", value: "value")])
    let pathComponents = PathComponents(value: ["path"])
    let body = Body(value: "Test".data(using: .utf8))
    
    func testPropertyAdd() {
        let otherPath = PathComponents(value: ["second"])
        var updated = pathComponents
        updated += otherPath
        XCTAssertEqual(updated, pathComponents + otherPath)
    }

    func testAddOperator() {
        let first = Request.Properties(headers: .init(value: ["first": "value"]))
        let second = Request.Properties(queryItems: .init(value: [.init(name: "second", value: "value")]))
        
        let combined = first + second
        
        XCTAssertEqual(combined.headers, first.headers)
        XCTAssertEqual(combined.queryItems, second.queryItems)
        
        var updated = first
        updated += second
        XCTAssertEqual(updated, first + second)
    }
    
    func testAdding() {
        let properties = Request.Properties.empty
        
        XCTAssertEqual(properties.adding(headers).headers, headers)
        XCTAssertEqual(properties.adding(queryItems).queryItems, queryItems)
        XCTAssertEqual(properties.adding(pathComponents).pathComponents, pathComponents)
        XCTAssertEqual(properties.adding(body).body, body)
        
        let propertiesAddingPath = properties.adding(pathComponents)
        let secondPath = PathComponents(value: ["second"])
        XCTAssertEqual(propertiesAddingPath.adding(secondPath).pathComponents, pathComponents + secondPath)
    }
    
    func testSetting() {
        let properties = Request.Properties(
            headers: .init(value: ["another": "value"]),
            queryItems: .init(value: [.init(name: "another", value: "query")]),
            pathComponents: .init(value: ["something"]),
            body: .init(value: "something".data(using: .utf8))
        )
        
        XCTAssertEqual(properties.setting(headers).headers, headers)
        XCTAssertEqual(properties.setting(queryItems).queryItems, queryItems)
        XCTAssertEqual(properties.setting(pathComponents).pathComponents, pathComponents)
        XCTAssertEqual(properties.setting(body).body, body)
    }
    
    func testFrom() {
        XCTAssertEqual(Request.Properties.from(headers).headers, headers)
        XCTAssertEqual(Request.Properties.from(queryItems).queryItems, queryItems)
        XCTAssertEqual(Request.Properties.from(pathComponents).pathComponents, pathComponents)
        XCTAssertEqual(Request.Properties.from(body).body, body)
        
        XCTAssertEqual(Request.Properties.from(headers).body, Request.Properties.empty.body)
    }

}
