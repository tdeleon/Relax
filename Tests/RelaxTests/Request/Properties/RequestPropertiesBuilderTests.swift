//
//  RequestPropertiesBuilderTests.swift
//  
//
//  Created by Thomas De Leon on 1/24/23.
//

import XCTest
@testable import Relax

final class RequestPropertiesBuilderTests: XCTestCase {
    func testBuildEmpty() {
        @RequestProperties.Builder
        func empty() -> RequestProperties {}
        XCTAssertEqual(empty(), RequestProperties.empty)
    }
    
    let expectedProperties = RequestProperties(
        headers: Headers(value: ["key": "value"]),
        queryItems: QueryItems(value: [.init(name: "name", value: "value")]),
        pathComponents: PathComponents(value: ["test"]),
        body: Body(value: "Test".data(using: .utf8))
    )
    
    func testBuild() {
        @RequestProperties.Builder
        var properties: RequestProperties {
            expectedProperties.pathComponents
            expectedProperties.queryItems
            expectedProperties.headers
            expectedProperties.body
        }
        
        XCTAssertEqual(properties, expectedProperties)
        
    }
    
    func testBuildOptional() {
        @RequestProperties.Builder
        func properties(include: Bool) -> RequestProperties {
            if include {
                expectedProperties.headers
            }
        }
        XCTAssertEqual(properties(include: true), .empty.setting(expectedProperties.headers))
        XCTAssertEqual(properties(include: false), .empty)
    }

    func testBuildEither() {
        @RequestProperties.Builder
        func properties(include: Bool) -> RequestProperties {
            if include {
                expectedProperties.headers
            }
            else {
                expectedProperties.pathComponents
            }
        }
        XCTAssertEqual(properties(include: true), .from(expectedProperties.headers))
        XCTAssertEqual(properties(include: false), .from(expectedProperties.pathComponents))
    }
    
    func testBuildArray() {
        let path1 = PathComponents(value: ["first"])
        let path2 = PathComponents(value: ["second"])
        let paths = [path1, path2]
        @RequestProperties.Builder
        var properties: RequestProperties {
            for path in paths {
                path
            }
        }
        XCTAssertEqual(properties, .from(path1).adding(path2))
    }
    
    func testBuildRequestProperties() {
        @RequestProperties.Builder
        var properties: RequestProperties {
            expectedProperties
        }
        XCTAssertEqual(properties, expectedProperties)
    }
}
