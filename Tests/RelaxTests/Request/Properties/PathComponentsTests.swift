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
    let component3 = 3
    let componentEmpty = ""
    
    func testAddOperator() {
        let path1 = PathComponents(value: [component1])
        let path2 = PathComponents(value: [component2])
        
        XCTAssertEqual((path1 + path2).value, (path1.value + path2.value))
    }

    func testAppend() {
        let components1 = PathComponents { component1 }
        let components2 = PathComponents { component2 }
        
        XCTAssertEqual(components1 + components2, PathComponents(value: [component1, component2]))
    }
    
    func testBuildEmpty() {
        let empty = PathComponents {}
        XCTAssertTrue(empty.value.isEmpty)
    }
    
    func testBuildOptional() {
        @PathComponents.Builder
        func components(_ include: Bool) -> PathComponents {
            if include {
                component1
            }
        }
        XCTAssertEqual(components(true).value, [component1])
        XCTAssertTrue(components(false).value.isEmpty)
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
        XCTAssertEqual(components(true).value, [component1])
        XCTAssertEqual(components(false).value, [component2])
    }
    
    func testBuildArray() {
        let items = [component1, component2]
        let components = PathComponents {
            for item in items {
                item
            }
        }
        XCTAssertEqual(components.value, items)
    }

    func testBuilder() {
        let path = PathComponents(value: [component2])
        let components = PathComponents {
            component1
            component2
            componentEmpty
            component3
            nil
            path
            [component1, component2]
        }
        XCTAssertEqual(components.value, [component1, component2, component3.description, component2, component1, component2])
    }
    
    func testBuildLimitedAvailability() {
        let components = PathComponents {
            if #available(*) {
                component1
            }
        }
        XCTAssertEqual(components, PathComponents(value: [component1]))
    }

}
