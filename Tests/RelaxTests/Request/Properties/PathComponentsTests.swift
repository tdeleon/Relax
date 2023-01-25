//
//  PathComponentsTests.swift
//  
//
//  Created by Thomas De Leon on 1/18/23.
//

import XCTest
@testable import Relax

final class PathComponentsTests: XCTestCase {
    
    let component1 = "first"
    let component2 = "second"
    let componentEmpty = ""
    
    func testAddOperator() {
        let path1 = PathComponents(value: [component1])
        let path2 = PathComponents(value: [component2])
        
        XCTAssertEqual((path1 + path2).baseValue, (path1.baseValue + path2.baseValue))
    }

    func testAppend() {
        let components1 = PathComponents { component1 }
        let components2 = PathComponents { component2 }
        
        XCTAssertEqual(components1 + components2, PathComponents(value: [component1, component2]))
    }
    
    func testBuildEmpty() {
        let empty = PathComponents {}
        XCTAssertTrue(empty.baseValue.isEmpty)
    }
    
    func testBuildOptional() {
        @PathComponents.Builder
        func components(_ include: Bool) -> PathComponents {
            if include {
                component1
            }
        }
        XCTAssertEqual(components(true).baseValue, [component1])
        XCTAssertTrue(components(false).baseValue.isEmpty)
    }
    
    func testBuildEither() {
        @PathComponents.Builder
        func components(_ include: Bool) -> PathComponents {
            if include {
                component1
            }
            else {
                component2
            }
        }
        XCTAssertEqual(components(true).baseValue, [component1])
        XCTAssertEqual(components(false).baseValue, [component2])
    }
    
    func testBuildArray() {
        let items = [component1, component2]
        let components = PathComponents {
            for item in items {
                item
            }
        }
        XCTAssertEqual(components.baseValue, items)
    }

    func testBuilder() {
        let path = PathComponents(value: [component2])
        let components = PathComponents {
            component1
            component2
            componentEmpty
            path
            [component1, component2]
        }
        XCTAssertEqual(components.baseValue, [component1, component2, component2, component1, component2])
    }

}
