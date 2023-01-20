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

    func testAppend() {
        let components = PathComponents {
            component2
        }
        
        var final = [component1]
        components.append(to: &final)
        
        XCTAssertEqual(final, [component1, component2])
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
        let components = PathComponents {
            component1
            component2
            componentEmpty
        }
        XCTAssertEqual(components.baseValue, [component1, component2])
    }

}
