//
//  HeaderTests.swift
//  
//
//  Created by Thomas De Leon on 1/18/23.
//

import XCTest
@testable import Relax

final class HeaderTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testInitName() {
        let name = Header.Name("name")
        let header = Header(name, "value")
        XCTAssertEqual(header.name, name.rawValue)
    }

    func testAppend() {
        let original = ["first": "value1", "second": "value2"]
        var headers = original
        let new = Headers(value: ["second": "value3"])
        new.append(to: &headers)
        XCTAssertEqual(headers, original.mergingCommaSeparatedValues(new.baseValue))
    }
    
    func testBuildEmpty() {
        let headers = Headers {}
        XCTAssertTrue(headers.baseValue.isEmpty)
    }
    
    func testBuild() {
        let header1 = Header("first", "value1")
        let header2 = Header("second", "value2")
        let header3 = Header("second", "value3")
        
        let headers = Headers {
            header1
            header2
            header3
        }
        XCTAssertEqual(headers.baseValue, [header1.name: header1.value,
                                           header2.name: "\(header2.value), \(header3.value)"])
        
    }
    
    func testBuildOptional() {
        let header = Header("name", "value")
        
        @Headers.Builder
        func headers(_ shouldInclude: Bool) -> Headers {
            if shouldInclude {
                header
            }
        }
        XCTAssertEqual(headers(true).baseValue, header.dictionary)
        
        XCTAssertTrue(headers(false).baseValue.isEmpty)
    }
    
    func testBuildEither() {
        let header1 = Header("name1", "value1")
        let header2 = Header("name2", "value2")
        
        @Headers.Builder
        func headers(_ include: Bool) -> Headers {
            if include {
                header1
            }
            else {
                header2
            }
        }
        
        XCTAssertEqual(headers(true).baseValue, header1.dictionary)
        XCTAssertEqual(headers(false).baseValue, header2.dictionary)
    }
    
    func testBuildArray() {
        let header1 = Header("name1", "value1")
        let header2 = Header("name2", "value2")
        let header3 = Header("name2", "value3")
        let all = [header1, header2, header3]
        
        let headers = Headers {
            for item in all {
                item
            }
        }
        XCTAssertEqual(headers.baseValue, [header1.name: header1.value,
                                           header2.name: "\(header2.value), \(header3.value)"])
    }
    
    func testBuildDictionary() {
        let header1 = ["first": "value"]
        let header2 = ["second": "value2"]
        let header3 = ["second": "value3"]
        
        let headers = Headers {
            header1
            header2
            header3
        }
        let expected = header1.mergingCommaSeparatedValues(header2)
            .mergingCommaSeparatedValues(header3)
        XCTAssertEqual(headers.baseValue, expected)
    }
}
