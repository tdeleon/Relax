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
        @Request.Properties.Builder
        func empty() -> Request.Properties {}
        XCTAssertEqual(empty(), Request.Properties.empty)
    }
    
    let expectedProperties = Request.Properties(
        headers: Headers(value: ["key": "value"]),
        queryItems: QueryItems(value: [.init(name: "name", value: "value")]),
        pathComponents: PathComponents(value: ["test"]),
        body: Body(value: "Test".data(using: .utf8))
    )
    
    func testBuild() {
        @Request.Properties.Builder
        var properties: Request.Properties {
            expectedProperties.pathComponents
            expectedProperties.queryItems
            expectedProperties.headers
            expectedProperties.body
        }
        
        XCTAssertEqual(properties, expectedProperties)
        
    }
    
    func testBuildOptional() {
        @Request.Properties.Builder
        func properties(include: Bool) -> Request.Properties {
            if include {
                expectedProperties.headers
            }
        }
        XCTAssertEqual(properties(include: true), .empty.setting(expectedProperties.headers))
        XCTAssertEqual(properties(include: false), .empty)
    }

    func testBuildEither() {
        @Request.Properties.Builder
        func properties(include: Bool) -> Request.Properties {
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
        @Request.Properties.Builder
        var properties: Request.Properties {
            for path in paths {
                path
            }
        }
        XCTAssertEqual(properties, .from(path1).adding(path2))
    }
    
    func testBuildRequestProperties() {
        @Request.Properties.Builder
        var properties: Request.Properties {
            expectedProperties
        }
        XCTAssertEqual(properties, expectedProperties)
    }
    
    func testBuildLimitedAvailability() {
        @Request.Properties.Builder
        var properties: Request.Properties {
            if #available(*) {
                expectedProperties
            }
        }
        XCTAssertEqual(properties, expectedProperties)
    }
}
